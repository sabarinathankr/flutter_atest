import 'dart:convert';
import 'dart:typed_data';
import 'package:ate/paymentmode.dart';
import 'package:ate/Register.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alphabet_navigation/alphabet_navigation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'DataFile.dart';
import 'Login.dart';
import 'paymentmode.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
    );
  }
}

// Data model for posts
class PostData {
  final String id;
  final String videoId;
  final String title;
  final String description;
  final String author;
  final DateTime timestamp;
  int likes;
  int shares;
  int views;
  bool isLiked;
  bool isBookmarked;
  List<Comment> comments;

  PostData({
    required this.id,
    required this.videoId,
    required this.title,
    required this.description,
    required this.author,
    required this.timestamp,
    this.likes = 0,
    this.shares = 0,
    this.views = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    required this.comments,
  });
}

class Comment {
  final String id;
  final String author;
  final String content;
  final DateTime timestamp;
  int likes;
  bool isLiked;

  Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
  });
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _Amount = TextEditingController();
  List<_SalesData> data = [
    _SalesData('Jan', 35),
    _SalesData('Feb', 28),
    _SalesData('Mar', 34),
    _SalesData('Apr', 32),
    _SalesData('May', 40),
  ];

  // Enhanced post data
  List<PostData> posts = [];
  final List<YoutubePlayerController> _controllers = [];
  Set<int> expandedTiles = {};

  // Search and filter
  TextEditingController _searchController = TextEditingController();
  TextEditingController _commentController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  List<String> _filterOptions = ['All', 'Recent', 'Popular', 'Trending'];
  String Username="";
  Uint8List?  Profilepic;
  late List<String> stringLists=[];
  late List<dynamic> dynamicList=[];
  late List<String> stringtransactionList=[];
  late List<dynamic> transactiondynamicList=[];
  late List<String> userpaymentidstring=[];
  late List<dynamic> userpaymentiddynamic=[];
  late List<String> userpaymentdatestring=[];
  late List<dynamic> userpaymentdatedynamic=[];
  late List<String> userpaymenttimestring=[];
  late List<dynamic> userpaymenttimedynamic=[];
  late List<String> userpaymentmodestring=[];
  late List<dynamic> userpaymentmodedynamic=[];
  bool _isLoading = true;
  File? _selectedFile;
  String? _fileName;
  String? _fileType;
  int userTtlContrib=0;
  @override
  void initState(){

    super.initState();

    _initPostsData();
    _initHive();
    _initControllers();

  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required TextInputType inputfeildtype,
    required IconData icontype,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,

        keyboardType: inputfeildtype,
        decoration: InputDecoration(
          prefixIcon: Icon(icontype),
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _initHive() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('userData');
    if (dataString != null) {
      final data = jsonDecode(dataString);
      setState(() {
        Username = data['FullName'];
        Profilepic = base64Decode(data['Profile']);
        if(data['UsrType'].toString()=="User")
          {
            _hideadmin=true;
          }
        else if(data['UsrType'].toString()=="Admin")
          {
            _hideadmin=false;
          }
        _isLogoutVisible=true;_isLoginVisible=false;

      });
    }
    else
      {
        Username="User";_hideadmin=true;
        Profilepic=base64Decode("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");
      }

    setState(() {
      _isLoading = true;
    });

    try {
      if(dataString!=null)
        {
          blanddb ins = blanddb();
          List<String> userData = await ins.ShowUser();
          Map<String, List<String>> transactionData = await ins.TransactionDetails();
          List<String> amounts = transactionData['amounts']!;// Now returns List<String> directly
          List<String> transactionids = transactionData['transactionIds']!;
          List<String> Transactiondate = transactionData['Transactiondate']!;
          List<String> Transactiontime = transactionData['Transactiontime']!;
          int total = 0;

          for (int i = 0; i < amounts.length; i++) {
            // Extract number part from "RS 1"
            final parts = amounts[i].split(" ");
            if (parts.length > 1) {
              total += int.tryParse(parts[1]) ?? 0;
            }
          }


          print('userData: $userData');
          setState(()  {
            stringLists = userData; // No mapping needed since it's already List<String>
            dynamicList = List<dynamic>.from(stringLists);

            stringtransactionList=amounts;
            transactiondynamicList=List<dynamic>.from(stringtransactionList);
            userpaymentidstring=transactionids;
            userpaymentiddynamic=List<dynamic>.from(userpaymentidstring);
            userpaymentdatestring=Transactiondate;
            userpaymentdatedynamic=List<dynamic>.from(userpaymentdatestring);
            userpaymenttimestring=Transactiontime;
            userpaymenttimedynamic=List<dynamic>.from(userpaymenttimestring);


            _isLoading = false;
            userTtlContrib = total;
          });
        }
        else
          {
            setState(() {
              stringLists = [];
              dynamicList = [];
              stringtransactionList=[];
              transactiondynamicList=[];
              userpaymentidstring=[];
              userpaymentiddynamic=[];
              userpaymentiddynamic=[];userpaymenttimedynamic=[];
              _isLoading = false;
            });
          }



    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        stringLists = [];
        dynamicList = [];
        stringtransactionList=[];
        transactiondynamicList=[];
        userpaymentidstring=[];
        userpaymentiddynamic=[];
        userpaymentiddynamic=[];userpaymenttimedynamic=[];
        _isLoading = false;
      });
    }






    //his seems redundant - see note below

  }

  void _initPostsData() {
    final videoIds = [
      'nM7D8B6aBUY',
      'HPbwEvMwpnk',
      'Rtvax982IDo',
      'jEWU0jLyGnw',
      'BGM3kJoNVIk',
    ];

    final titles = [
      'Flutter Tutorial: Building Beautiful UIs',
      'Advanced Dart Programming Concepts',
      'Mobile App Development Best Practices',
      'State Management in Flutter',
      'Creating Responsive Layouts',
    ];

    final descriptions = [
      'Learn how to create stunning user interfaces with Flutter widgets.',
      'Deep dive into advanced Dart programming concepts and patterns.',
      'Essential best practices for mobile app development in 2024.',
      'Complete guide to state management solutions in Flutter.',
      'Master responsive design techniques for all screen sizes.',
    ];

    final authors = [
      'anbu thanee ellam sethu',
      'anbu thanee ellam sethu',
      'anbu thanee ellam sethu',
      'anbu thanee ellam sethu',
      'anbu thanee ellam sethu',
    ];

    for (int i = 0; i < videoIds.length; i++) {
      posts.add(PostData(
        id: 'post_$i',
        videoId: videoIds[i],
        title: titles[i],
        description: descriptions[i],
        author: authors[i],
        timestamp: DateTime.now().subtract(Duration(hours: i + 1)),
        likes: (i + 1) * 45 + 12,
        shares: (i + 1) * 8 + 3,
        views: (i + 1) * 234 + 56,
        comments: _generateSampleComments(i),
      ));
    }
  }

  List<Comment> _generateSampleComments(int postIndex) {
    return [
      Comment(
        id: 'comment_${postIndex}_1',
        author: 'User${postIndex + 1}',
        content: 'Great content! Really helpful tutorial.',
        timestamp: DateTime.now().subtract(Duration(minutes: 30)),
        likes: 5,
      ),
      Comment(
        id: 'comment_${postIndex}_2',
        author: 'DevFan${postIndex + 2}',
        content: 'Thanks for sharing this. Looking forward to more videos!',
        timestamp: DateTime.now().subtract(Duration(minutes: 15)),
        likes: 3,
      ),
    ];
  }

  void _initControllers() async {


    for (PostData post in posts) {
      _controllers.add(
        YoutubePlayerController(
          initialVideoId: post.videoId,
          flags: YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _searchController.dispose();
    _commentController.dispose();
    super.dispose();
  }
 // bool _isLogoutVisible=true;
  File? _image;
  final _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<String> menuItems = [
    'Remainder',
    'Auto Detect',
    'Report',
    'Notification',
    'Theme',
    'Auto Logout'
  ];

  List<bool> toggleStates = [false, true, false, true, true, false];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Social interaction handlers
  void _toggleLike(int postIndex) {
    setState(() {
      if (posts[postIndex].isLiked) {
        posts[postIndex].likes--;
        posts[postIndex].isLiked = false;
      } else {
        posts[postIndex].likes++;
        posts[postIndex].isLiked = true;
      }
    });
  }

  void _toggleBookmark(int postIndex) {
    setState(() {
      posts[postIndex].isBookmarked = !posts[postIndex].isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(posts[postIndex].isBookmarked
            ? 'Post bookmarked'
            : 'Bookmark removed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _sharePost(int postIndex) {
    setState(() {
      posts[postIndex].shares++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post shared successfully!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showComments(BuildContext context, int postIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCommentsSheet(postIndex),
    );
  }

  void _showShareOptions(BuildContext context, int postIndex) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildShareSheet(postIndex),
    );
  }

  void _addComment(int postIndex) {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        posts[postIndex].comments.add(
          Comment(
            id: 'comment_${postIndex}_${posts[postIndex].comments.length}',
            author: 'You',
            content: _commentController.text.trim(),
            timestamp: DateTime.now(),
          ),
        );
      });
      _commentController.clear();
    }
  }

  void _toggleCommentLike(int postIndex, int commentIndex) {
    setState(() {
      Comment comment = posts[postIndex].comments[commentIndex];
      if (comment.isLiked) {
        comment.likes--;
        comment.isLiked = false;
      } else {
        comment.likes++;
        comment.isLiked = true;
      }
    });
  }

  List<PostData> get filteredPosts {
    List<PostData> filtered = posts;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((post) =>
      post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.author.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'Recent':
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'Popular':
        filtered.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case 'Trending':
        filtered.sort((a, b) => b.views.compareTo(a.views));
        break;
    }

    return filtered;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Post'),
        content: Text('Post creation feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Posts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filterOptions.map((filter) {
            return RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // Admin tab functions
  void _handlePost() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Post button clicked')),
    );
  }

  void _handleHighlight() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Highlight button clicked')),
    );
  }

  void _handleNotify() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notify button clicked')),
    );
  }

  @override
  Widget build(BuildContext context) {


    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeScreen = screenSize.width > 1200;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('ATEST'),
          centerTitle: true,
          elevation: 2,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.rss_feed_outlined), text: 'Post'),
              Tab(icon: Icon(Icons.payment), text: 'Payments'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
              if(_hideadmin==false)
                 Tab(icon: Icon(Icons.admin_panel_settings_sharp), text: 'Admin'),

            ],
            isScrollable: !isTablet,
          ),
        ),
        body: TabBarView(
          children: [
            _buildEnhancedPostTab(screenSize, isTablet),
            _buildPaymentsTab(screenSize, isTablet),
            _buildUserDashboardTab(screenSize, isTablet,isLargeScreen),
            _buildAdminTab(screenSize, isTablet, isLargeScreen),
          ],
        ),

      ),
    );
  }
  String _getFileSizeString(int bytes) {
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return "${size.toStringAsFixed(1)} ${suffixes[i]}";
  }


  // Pick Custom Media Files (with specific extensions)
  Future<void> _pickCustomMediaFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', // Images
          'mp4', 'avi', 'mov', 'wmv', 'flv', 'webm',    // Videos
          'mp3', 'wav', 'aac', 'm4a', 'ogg', 'wma'],    // Audio
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String extension = result.files.single.extension?.toLowerCase() ?? '';
        String fileType;

        if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
          fileType = 'Image';
        } else if (['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'].contains(extension)) {
          fileType = 'Video';
        } else if (['mp3', 'wav', 'aac', 'm4a', 'ogg', 'wma'].contains(extension)) {
          fileType = 'Audio';
        } else {
          fileType = 'Media';
        }

        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
          _fileType = fileType;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  // Clear selected file
  void _clearSelectedFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
      _fileType = null;
    });
  }






  bool _isLogoutVisible=false; bool _isLoginVisible=true;
  bool  _hideadmin=true;
  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          mini: true,
          onPressed: () => _showCreatePostDialog(),
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
          heroTag: "create_post",
        ),
        SizedBox(height: 8),
        FloatingActionButton(
          mini: true,
          onPressed: () => _showFilterDialog(),
          child: Icon(Icons.filter_list),
          backgroundColor: Colors.green,
          heroTag: "filter",
        ),
      ],
    );
  }

  Widget _buildEnhancedPostTab(Size screenSize, bool isTablet) {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search posts...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              SizedBox(height: 12),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filterOptions.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Posts List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32.0 : 12.0,
              vertical: 8.0,
            ),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              final post = filteredPosts[index];
              final originalIndex = posts.indexOf(post);
              final controller = _controllers[originalIndex];

              return Container(
                margin: EdgeInsets.only(bottom: 20.0),
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 800 : double.infinity,
                ),
                child: _buildEnhancedPostCard(post, controller, originalIndex, isTablet),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedPostCard(PostData post, YoutubePlayerController controller, int postIndex, bool isTablet) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isTablet ? 24 : 20,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    post.author[0].toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post.timestamp),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isTablet ? 12 : 10,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$value selected')),
                    );
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'follow', child: Text('Follow ${post.author}')),
                    PopupMenuItem(value: 'hide', child: Text('Hide Post')),
                    PopupMenuItem(value: 'report', child: Text('Report Post')),
                  ],
                ),
              ],
            ),
          ),

          // Post Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  post.description,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),

          // Video Player
          YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: true,
              aspectRatio: 16 / 9,
            ),
            builder: (context, player) => player,
          ),

          // Post Stats
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20.0 : 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                _buildStatChip(Icons.visibility, '${post.views}', Colors.grey),
                SizedBox(width: 8),
                _buildStatChip(Icons.thumb_up, '${post.likes}', Colors.blue),
                SizedBox(width: 8),
                _buildStatChip(Icons.comment, '${post.comments.length}', Colors.green),
                SizedBox(width: 8),
                _buildStatChip(Icons.share, '${post.shares}', Colors.orange),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[300]),

          // Action Buttons
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12.0 : 8.0,
              vertical: 4.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  label: 'Like',
                  color: post.isLiked ? Colors.blue : Colors.grey[600]!,
                  onPressed: () => _toggleLike(postIndex),
                  isTablet: isTablet,
                ),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: 'Comment',
                  color: Colors.grey[600]!,
                  onPressed: () => _showComments(context, postIndex),
                  isTablet: isTablet,
                ),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: Colors.grey[600]!,
                  onPressed: () => _showShareOptions(context, postIndex),
                  isTablet: isTablet,
                ),
                _buildActionButton(
                  icon: post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  label: 'Save',
                  color: post.isBookmarked ? Colors.orange : Colors.grey[600]!,
                  onPressed: () => _toggleBookmark(postIndex),
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 12 : 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isTablet ? 20 : 18, color: color),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSheet(int postIndex) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comments (${posts[postIndex].comments.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Comments List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: posts[postIndex].comments.length,
              itemBuilder: (context, index) {
                final comment = posts[postIndex].comments[index];
                return _buildCommentItem(comment, postIndex, index);
              },
            ),
          ),

          // Add Comment
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.green[100],
                  child: Text('Y', style: TextStyle(color: Colors.green[800])),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () => _addComment(postIndex),
                  icon: Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, int postIndex, int commentIndex) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.purple[100],
            child: Text(
              comment.author[0].toUpperCase(),
              style: TextStyle(color: Colors.purple[800], fontSize: 12),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  comment.content,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _toggleCommentLike(postIndex, commentIndex),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            comment.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 14,
                            color: comment.isLiked ? Colors.blue : Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${comment.likes}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Reply feature coming soon!')),
                        );
                      },
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareSheet(int postIndex) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Share Post',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            children: [
              _buildShareOption(Icons.copy, 'Copy Link', () {
                Navigator.pop(context);
                _sharePost(postIndex);
              }),
              _buildShareOption(Icons.message, 'WhatsApp', () {
                Navigator.pop(context);
                _sharePost(postIndex);
              }),
              _buildShareOption(Icons.email, 'Email', () {
                Navigator.pop(context);
                _sharePost(postIndex);
              }),
              _buildShareOption(Icons.facebook, 'Facebook', () {
                Navigator.pop(context);
                _sharePost(postIndex);
              }),
              _buildShareOption(Icons.telegram, 'Telegram', () {
                Navigator.pop(context);
                _sharePost(postIndex);
              }),
              _buildShareOption(Icons.alternate_email, 'Twitter', () {
                Navigator.pop(context);
                _sharePost(postIndex);
              }),
              _buildShareOption(Icons.camera_alt, 'Instagram', () {
                Navigator.pop(context);
                _sharePost(postIndex);
              }),
              _buildShareOption(Icons.more_horiz, 'More', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('More options coming soon!')),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: Colors.grey[700]),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsTab(Size screenSize, bool isTablet) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
          child: Text(
            "Payment History",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 24 : 20,
            ),
          ),
        ),
        transactiondynamicList.isEmpty
            ? Center(child: Text("No Transactions available"))
            :
        Expanded(
          child: AlphabetNavigation(
            stringList: stringtransactionList,
            dynamicList: transactiondynamicList,
            showSearchField: false,
            dynamicListHeight: 270, // Reset to original height for collapsed state
            searchFieldHintText: "Search here...",
            searchFieldTextStyle: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            searchFieldHintTextStyle: TextStyle(
              color: Colors.grey.shade300,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            searchFieldIcon: Icon(
              Icons.search,
              color: Colors.blue.shade800,
            ),
            searchFieldEndIconColor: Colors.blue.shade800,
            listDirection: ListDirection.left,

            alphabetListBackgroundColor: Colors.tealAccent,
            selectedColor: Colors.white70,
            unselectedColor: Colors.black38,
            circleSelectedBackgroundColor: Colors.blue,
            circleSelectedLetter: false,
            circleBorderRadius: 10.0,
            scrollAnimationCurve: Curves.easeInCubic,
            itemBuilder: (context, index, dynamicList) {
              final isExpanded = expandedTiles.contains(index);
              final item = dynamicList[index];
              final transactionDate = DateTime.now().subtract(Duration(days: index));
              final formattedDate = '${transactionDate.day.toString().padLeft(2, '0')}/'
                  '${transactionDate.month.toString().padLeft(2, '0')}/'
                  '${transactionDate.year}';

              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Main header that's always visible
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              expandedTiles.remove(index);
                            } else {
                              expandedTiles.add(index);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 16.0 : 14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(userpaymentdatedynamic[index].split(" ")[1]),
                              const SizedBox(width: 12),
                              Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: Colors.grey.shade600,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Expandable content
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                          isTablet ? 16.0 : 14.0,
                          0,
                          isTablet ? 16.0 : 14.0,
                          isTablet ? 16.0 : 14.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),

                            // Transaction ID Row
                            _buildInfoRow(
                              'Transaction ID:',
                              userpaymentiddynamic[index],
                              isTablet,
                            ),
                            const SizedBox(height: 8),

                            // Date Row
                            _buildInfoRow(
                              'Date:',
                              userpaymentdatedynamic[index],
                              isTablet,
                            ),
                            const SizedBox(height: 8),

                            // Status Row
                            _buildInfoRow(
                              'Status:',
                              'Completed',
                              isTablet,
                              valueColor: Colors.green,
                              valueWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 8),

                            // Amount Row
                            _buildInfoRow(
                              'Time:',
                              userpaymenttimedynamic[index],
                              isTablet,
                              valueWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [

                                ElevatedButton(
                                    onPressed:()
                                    {
                                      String amount = transactiondynamicList[index].split(" ")[1];
                                      Razorpaybl rxbl = new Razorpaybl();
                                      rxbl.openCheckout(
                                          amount, 8300286065, "abdhulghaani@gmail.com",
                                          "Abdul");
                                    } ,
                                    child: Text("Pay again")),
                                ElevatedButton(
                                    onPressed:()
                                    {

                                    } ,
                                    child: Text("Share")),
                                ElevatedButton(
                                    onPressed:()
                                    {


                                    } ,
                                    child: Text("Download")),
                              ],),
                          ],
                        ),
                      )


                    ],
                  ),
                ),
              );
            },
          ),
        ),

        transactiondynamicList.isEmpty
            ? const Spacer()
            : const SizedBox.shrink(), // Takes up zero space

        Container(
          constraints: BoxConstraints(maxWidth: isTablet ? 800 : double.infinity),
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _Amount, // Separate controller
                    obscureText: false,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.currency_rupee),
                      labelText: "Amount",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16), // Add spacing between fields
                ElevatedButton.icon(
                  onPressed: ()async {
                    final prefs = await SharedPreferences.getInstance();
                    final dataString = prefs.getString('userData');
                    if (dataString != null) {
                      Razorpaybl rxbl = new Razorpaybl();
                      rxbl.openCheckout(
                          _Amount.text, 8300286065, "abdhulghaani@gmail.com",
                          "Abdul");
                      setState(()
                      {

                      });
                    }
                    else
                      {
                        final dialog = AwesomeDialog(
                          context: context,
                          animType: AnimType.leftSlide,
                          dialogType: DialogType.noHeader,
                          // Prevent default header
                          showCloseIcon: false,
                          dismissOnTouchOutside: false,
                          customHeader: Icon(
                            Icons.error,
                            color: Colors.blue,
                            size: 80,
                          ),
                          title: 'Info',
                          desc: 'Please Login Before Pay!',
                        );

                        dialog.show();
                        Future.delayed(Duration(seconds: 2), () {
                          dialog.dismiss(); // Close the dialog

                        });
                      }
                  },
                  icon: Icon(Icons.qr_code_scanner),
                  label: Text('Pay Now'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 20 : 16,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserDashboardTab(Size screenSize, bool isTablet, bool isLargeScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  'User Dashboard',
                  style: TextStyle(
                    fontSize: isTablet ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome back! Here\'s what\'s happening today.',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
              child: Column(
                children: [
                  // Auth buttons
                  Row(
                    children: [
                      Visibility(
                      visible: true,
                        child:
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    //ScaffoldMessenger.of(context).showSnackBar(
                                    // SnackBar(content: Text('Register feature coming soon!')),
                                    // );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>  MyApp1("isregister")),
                                    );
                                  },
                                  icon: Icon(Icons.app_registration),
                                  label: Text('Register'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet ? 20 : 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: isTablet ? 20 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(width: 16),
                      Visibility(
                        visible: _isLogoutVisible,
                        child:
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();
                              // final dataString = prefs.getString('userData');
                              await prefs.remove('userData');
                              await prefs.clear();

                              //_initHive();
                              print("returned to homepage");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Logging off')),
                              );
                              Username="User";_isLoginVisible=true;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => MyHomePage()), // Your actual home widget
                                    (Route<dynamic> route) => false,
                              );

                            },
                            icon: Icon(Icons.logout),
                            label: Text('Logout'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lime,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 20 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: TextStyle(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Visibility(
                        visible: _isLoginVisible,
                        child:
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              //ScaffoldMessenger.of(context).showSnackBar(
                              // SnackBar(content: Text('Register feature coming soon!')),
                              // );
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  LoginPage()),
                              );
                            },
                            icon: Icon(Icons.login_outlined),
                            label: Text('Login'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 20 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: TextStyle(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // Profile section
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: isTablet ? 80 : 60,
                      backgroundImage: Profilepic != null
                          ? MemoryImage(Profilepic!)
                          : null,
                      child: Profilepic == null
                          ? Icon(Icons.camera_alt, size: isTablet ? 50 : 40)
                          : null,
                    ),
                  ),

                  SizedBox(height: 24),
                  Text(Username,style: TextStyle(fontSize: isTablet ? 18 : 25),),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Edit Profile feature coming soon!')),
                        );
                      },
                      icon: Icon(Icons.edit),
                      label: Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 20 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Quick Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: isLargeScreen ? 4 : (isTablet ? 2 : 2),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isTablet ? 1.5 : 1.2,
            children: [
              _buildStatCard('Total Contribution', userTtlContrib.toString(), Icons.currency_rupee, Colors.orange, '+23%', isTablet),
              _buildStatCard('Favourite', '0', Icons.article, Colors.green, '+8%', isTablet),
              _buildStatCard('Notifications', '0', Icons.notifications, Colors.purple, '+5%', isTablet),
            ],
          ),
          SizedBox(height: 24),

          // Main Action Buttons
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: isLargeScreen ? 3 : (isTablet ? 2 : 2),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isTablet ? 1.3 : 1.1,
            children: [

              _buildActionCard('Analytics', Icons.analytics, Colors.teal, () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Analytics',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Analytics Overview',
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Container(
                                  height: 200,
                                  child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    primaryYAxis: NumericAxis(),
                                    series: <CartesianSeries<_SalesData, String>>[
                                      ColumnSeries<_SalesData, String>(
                                        dataSource: data,
                                        xValueMapper: (_SalesData sales, _) => sales.year,
                                        yValueMapper: (_SalesData sales, _) => sales.sales,
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, isTablet),
              _buildActionCard('Settings', Icons.settings, Colors.teal, () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Admin Settings',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 24),



                        // Settings list
                        Card(
                          child: Column(
                            children: List.generate(
                              menuItems.length,
                                  (index) => ListTile(
                                title: Text(
                                  menuItems[index],
                                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                                ),
                                trailing: Switch(
                                  value: toggleStates[index],
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      toggleStates[index] = newValue;
                                    });
                                  },
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 24 : 16,
                                  vertical: isTablet ? 8 : 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, isTablet),
              _buildActionCard('Support', Icons.contact_support, Colors.green, () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Send Notification',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              ListTile(
                                leading: Icon(Icons.account_circle),
                                title: Text('Account Settings'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle account settings
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.notifications),
                                title: Text('Notifications'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle notifications
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.security),
                                title: Text('Security'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle security
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.help),
                                title: Text('Help & Support'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle help
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, isTablet),
            ],
          ),
          SizedBox(height: 32),

          // Analytics Section

        ],
      ),
    );
  }

  Widget _buildAdminTab(Size screenSize, bool isTablet, bool isLargeScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: isTablet ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome back! Here\'s what\'s happening today.',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Quick Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: isLargeScreen ? 4 : (isTablet ? 2 : 2),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isTablet ? 1.5 : 1.2,
            children: [
              _buildStatCard('Total Users', dynamicList.length.toString(), Icons.people, Colors.blue, '+12%', isTablet),
              _buildStatCard('Active Posts', '0', Icons.article, Colors.green, '+8%', isTablet),
              _buildStatCard('Revenue', '₹23', Icons.currency_rupee, Colors.orange, '+23%', isTablet),
              _buildStatCard('Notifications', '0', Icons.notifications, Colors.purple, '+5%', isTablet),
            ],
          ),
          SizedBox(height: 24),

          // Main Action Buttons
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: isLargeScreen ? 3 : (isTablet ? 2 : 2),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isTablet ? 1.3 : 1.1,
            children: [
              _buildActionCard('Create Post', Icons.post_add, Colors.blue, () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Create Post',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Title

                                SizedBox(height: 10),

                                // File Picker Buttons


                                Row(
                                  children: [

                                    SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _pickCustomMediaFile,
                                        icon: Icon(Icons.perm_media, color: Colors.white),
                                        label: Text('Select Media', style: TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: EdgeInsets.symmetric(vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 30),

                                // Selected File Display
                                if (_selectedFile != null) ...[
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Selected File',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: _fileType == 'Image' ? Colors.green :
                                                _fileType == 'Video' ? Colors.purple :
                                                _fileType == 'Audio' ? Colors.orange : Colors.blue,
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: Text(
                                                _fileType ?? 'Media',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15),

                                        Row(
                                          children: [
                                            Icon(
                                              _fileType == 'Image' ? Icons.image :
                                              _fileType == 'Video' ? Icons.video_library :
                                              _fileType == 'Audio' ? Icons.audiotrack : Icons.insert_drive_file,
                                              color: Colors.grey[600],
                                              size: 30,
                                            ),
                                            SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _fileName ?? 'Unknown',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 5),
                                                  FutureBuilder<FileStat>(
                                                    future: _selectedFile!.stat(),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        return Text(
                                                          'Size: ${_getFileSizeString(snapshot.data!.size)}',
                                                          style: TextStyle(
                                                            color: Colors.grey[600],
                                                            fontSize: 14,
                                                          ),
                                                        );
                                                      }
                                                      return Text(
                                                        'Loading...',
                                                        style: TextStyle(
                                                          color: Colors.grey[600],
                                                          fontSize: 14,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              onPressed: _clearSelectedFile,
                                              icon: Icon(Icons.close, color: Colors.red),
                                              label: Text(
                                                'Remove',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.file_upload_outlined,
                                            size: 60,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: 15),
                                          Text(
                                            'No file selected',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Choose a file using the buttons above',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                ],
                                SizedBox(height: 30),

                                _buildTextField(label: 'Media Title', controller: _nameController,inputfeildtype: TextInputType.name,icontype:Icons.title),
                                _buildTextField(label: 'Description', controller: _nameController,inputfeildtype: TextInputType.name,icontype:Icons.description),
                                _buildTextField(label: 'Visible', controller: _nameController,inputfeildtype: TextInputType.name,icontype:Icons.visibility_outlined),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: (){},
                                    icon: Icon(Icons.perm_media, color: Colors.white),
                                    label: Text('Publish', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(horizontal: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, isTablet),
              _buildActionCard('Hightlight', Icons.highlight, Colors.orange, () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Hightlight',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              ListTile(
                                leading: Icon(Icons.account_circle),
                                title: Text('Account Settings'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle account settings
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.notifications),
                                title: Text('Notifications'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle notifications
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.security),
                                title: Text('Security'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle security
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.help),
                                title: Text('Help & Support'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle help
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, isTablet),
              _buildActionCard('Send Notify', Icons.notifications, Colors.green, () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Send Notification',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              ListTile(
                                leading: Icon(Icons.account_circle),
                                title: Text('Account Settings'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle account settings
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.notifications),
                                title: Text('Notifications'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle notifications
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.security),
                                title: Text('Security'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle security
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.help),
                                title: Text('Help & Support'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle help
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, isTablet),
              _buildActionCard('UserMgmt', Icons.people_alt, Colors.purple, () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'User Management',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                    Expanded(
                      child: AlphabetNavigation(
                        stringList: stringLists,
                        dynamicList: dynamicList,
                        showSearchField: true,
                        dynamicListHeight: 270, // Reset to original height for collapsed state
                        searchFieldHintText: "Search here...",
                        searchFieldTextStyle: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        searchFieldHintTextStyle: TextStyle(
                          color: Colors.grey.shade300,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        searchFieldIcon: Icon(
                          Icons.search,
                          color: Colors.blue.shade800,
                        ),
                        searchFieldEndIconColor: Colors.blue.shade800,
                        listDirection: ListDirection.left,
                        alphabetListBackgroundColor: Colors.tealAccent,
                        selectedColor: Colors.white70,
                        unselectedColor: Colors.black38,
                        circleSelectedBackgroundColor: Colors.blue,
                        circleSelectedLetter: true,
                        circleBorderRadius: 10.0,
                        scrollAnimationCurve: Curves.easeInCubic,
                        itemBuilder: (context, index, dynamicList) {
                          final isExpanded = expandedTiles.contains(index);
                          final item = dynamicList[index];
                          final transactionDate = DateTime.now().subtract(Duration(days: index));
                          final formattedDate = '${transactionDate.day.toString().padLeft(2, '0')}/'
                              '${transactionDate.month.toString().padLeft(2, '0')}/'
                              '${transactionDate.year}';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Main header that's always visible
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (isExpanded) {
                                          expandedTiles.remove(index);
                                        } else {
                                          expandedTiles.add(index);
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Padding(
                                      padding: EdgeInsets.all(isTablet ? 16.0 : 14.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: const Color(0xFF56A3A6),
                                            child: Text(
                                              item.isNotEmpty ? item[0].toUpperCase() : '?',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(
                                            isExpanded ? Icons.expand_less : Icons.expand_more,
                                            color: Colors.grey.shade600,
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Expandable content
                                  Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.fromLTRB(
                                        isTablet ? 16.0 : 14.0,
                                        0,
                                        isTablet ? 16.0 : 14.0,
                                        isTablet ? 16.0 : 14.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 12),

                                          // Transaction ID Row
                                          _buildInfoRow(
                                            'Transaction ID:',
                                            'TXN${index.toString().padLeft(6, '0')}',
                                            isTablet,
                                          ),
                                          const SizedBox(height: 8),

                                          // Date Row
                                          _buildInfoRow(
                                            'Date:',
                                            formattedDate,
                                            isTablet,
                                          ),
                                          const SizedBox(height: 8),

                                          // Status Row
                                          _buildInfoRow(
                                            'Status:',
                                            'Completed',
                                            isTablet,
                                            valueColor: Colors.green,
                                            valueWeight: FontWeight.w600,
                                          ),
                                          const SizedBox(height: 8),

                                          // Amount Row
                                          _buildInfoRow(
                                            'Amount:',
                                            '\$${(index * 12.5 + 50).toStringAsFixed(2)}',
                                            isTablet,
                                            valueWeight: FontWeight.w600,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                            ElevatedButton(
                                                onPressed:()
                                                {

                                                } ,
                                                child: Text("Notify")),

                                          ElevatedButton(
                                              onPressed:()
                                              {

                                              } ,
                                              child: Text("InActive")),
                                          ElevatedButton(
                                              onPressed:()
                                              {

                                                blanddb ins = blanddb();
                                                ins.RemoveUser(dynamicList[index]);
                                                _initHive();
                                                _initControllers();
                                                Navigator.pop(context);
                                              } ,
                                              child: Text("Remove")),
                                            ],),
                                        ],
                                      ),
                                    )


                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),


                      ],
                    ),
                  ),
                );
              }, isTablet),
              _buildActionCard('Analytics', Icons.analytics, Colors.teal, () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Analytics',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Analytics Overview',
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Container(
                                  height: 200,
                                  child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    primaryYAxis: NumericAxis(),
                                    series: <CartesianSeries<_SalesData, String>>[
                                      ColumnSeries<_SalesData, String>(
                                        dataSource: data,
                                        xValueMapper: (_SalesData sales, _) => sales.year,
                                        yValueMapper: (_SalesData sales, _) => sales.sales,
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, isTablet),
              _buildActionCard('Settings', Icons.settings, Colors.teal, () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Admin Settings',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              ListTile(
                                leading: Icon(Icons.account_circle),
                                title: Text('Account Settings'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle account settings
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.notifications),
                                title: Text('Notifications'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle notifications
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.security),
                                title: Text('Security'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle security
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.help),
                                title: Text('Help & Support'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Handle help
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, isTablet),
            ],
          ),
          SizedBox(height: 32),

          // Analytics Section

        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String change, bool isTablet) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: isTablet ? 32 : 24),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: isTablet ? 12 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoRow(
      String label,
      String value,
      bool isTablet, {
        Color? valueColor,
        FontWeight? valueWeight,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 15 : 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 15 : 13,
              color: valueColor ?? Colors.black87,
              fontWeight: valueWeight ?? FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onPressed, bool isTablet) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isTablet ? 32 : 24),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);
  final String year;
  final double sales;
}