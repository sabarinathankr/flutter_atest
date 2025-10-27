import 'package:ate/models/upload_post_model.dart';
import 'package:ate/utils/shared_preference.dart';
import 'package:flutter/material.dart';

import '../../db_connection/DBConnections.dart';

class CreatePostWidget extends StatefulWidget {
  const CreatePostWidget({super.key});

  @override
  State<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _yTLinkController = TextEditingController();

  String _selectedVisibility = 'Private';
  bool _isLoading = false;

  void _clickPublish() {
    uploadDirectToMongo();
  }

  Future<void> uploadDirectToMongo() async {
    String email = await SharedPreferenceHelper.getPreferenceEmail();
    String name = await SharedPreferenceHelper.getPreferenceFullName();

    if (email.isEmpty || name.isEmpty) {
      showMessage('Please login again');
      return;
    }

    String title = _titleController.text.trim();
    if (title.isEmpty) {
      showMessage('Enter title');
      return;
    }

    String description = _descController.text.trim();
    if (description.isEmpty) {
      showMessage('Enter description');
      return;
    }

    String link = _yTLinkController.text.trim();
    if (link.isEmpty) {
      showMessage('Enter YouTube link');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String visibility = _selectedVisibility.toLowerCase();

    UploadPostModel uploadPostModel = UploadPostModel(
      title: title,
      description: description,
      email: email,
      fullName: name,
      youTubeLink: link,
      visibility: visibility,
    );

    DbConnections dbConnections = DbConnections();

    dbConnections.uploadPost(uploadPostModel, (isSuccess, message) {
      setState(() {
        _isLoading = false;
      });

      if (isSuccess) {
        showMessage('Post published successfully!');
        Navigator.pop(context);
      } else {
        showMessage(message ?? 'Failed to publish post');
      }
    });
  }

  // Reusable input field builder
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required TextInputType inputType,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                _buildTextField(
                  label: 'Title',
                  controller: _titleController,
                  inputType: TextInputType.name,
                  icon: Icons.title,
                ),
                _buildTextField(
                  label: 'Description',
                  controller: _descController,
                  inputType: TextInputType.multiline,
                  icon: Icons.description,
                ),
                _buildTextField(
                  label: 'YouTube Link',
                  controller: _yTLinkController,
                  inputType: TextInputType.url,
                  icon: Icons.link,
                ),

                // 🔽 Dropdown for Visibility
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Visibility',
                      prefixIcon: const Icon(Icons.visibility_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedVisibility,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                              value: 'Private', child: Text('Private')),
                          DropdownMenuItem(
                              value: 'Public', child: Text('Public')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedVisibility = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _clickPublish,
                  icon: const Icon(Icons.publish, color: Colors.white),
                  label: const Text(
                    'Publish',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 🔄 Loader Overlay
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  void showMessage(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
