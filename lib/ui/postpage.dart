import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../db_connection/DBConnections.dart';
import '../models/upload_post_model.dart';

class EnhancedPostTab extends StatefulWidget {
  final bool isTablet;

  const EnhancedPostTab({
    super.key,
    this.isTablet = false,
  });

  @override
  State<EnhancedPostTab> createState() => _EnhancedPostTabState();
}

class _EnhancedPostTabState extends State<EnhancedPostTab> {
  String _searchQuery = '';
  List<UploadPostModel> postList = [];
  List<YoutubePlayerController> controllers = [];

  // String? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();

  String? getYoutubeVideoId(String url) {
    // Regex to match video ID in YouTube URL
    final RegExp regExp = RegExp(
      r'(?:v=|\/)([0-9A-Za-z_-]{11}).*',
      caseSensitive: false,
      multiLine: false,
    );

    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null; // no ID found
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  void fetchPosts() async {
    DbConnections dbConnections = DbConnections();
    postList = await dbConnections.getAllPosts();

    for (var post in postList) {
      print('Title: ${post.title}');
      print('YouTube Link: ${post.youTubeLink}');
      print('Timestamp: ${post.timestamp}');

      setState(() {
        postList =postList;

        controllers.add(
            YoutubePlayerController(
              initialVideoId: getYoutubeVideoId(post.youTubeLink) ?? '',
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                mute: false,
              ),
            )
        );
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchAndFilterBar(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isTablet ? 32.0 : 12.0,
              vertical: 8.0,
            ),
            itemCount: postList.length,
            itemBuilder: (context, index) {
              final post = postList[index];
              final originalIndex = postList.indexOf(post);
              final controller = controllers[originalIndex];
              return Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                constraints: BoxConstraints(
                    maxWidth: widget.isTablet ? 800 : double.infinity),
                child: _buildEnhancedPostCard(post, controller, originalIndex),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 16.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search posts...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
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
                vertical: widget.isTablet ? 16 : 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          /*SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
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
          ),*/
        ],
      ),
    );
  }

  Widget _buildEnhancedPostCard(
      UploadPostModel post, YoutubePlayerController controller, int postIndex) {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPostHeader(post, postIndex),
              _buildPostContent(post),
              _buildVideoPlayer(controller),
            ],
          ),
        ));
  }

  Widget _buildPostHeader(UploadPostModel post, int postIndex) {
    return Padding(
      padding: EdgeInsets.all(widget.isTablet ? 20.0 : 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: widget.isTablet ? 24 : 20,
            backgroundColor: Colors.blue[100],
            child: Text(
              post.email[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.fullName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: widget.isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(UploadPostModel post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isTablet ? 20.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: TextStyle(
              fontSize: widget.isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post.description,
            style: TextStyle(
              fontSize: widget.isTablet ? 14 : 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(YoutubePlayerController controller) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
        aspectRatio: 16 / 9,
      ),
      builder: (context, player) => player,
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
