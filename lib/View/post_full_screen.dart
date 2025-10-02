import 'package:flutter/material.dart';
import '../Model/post.dart';

class PostFullScreen extends StatefulWidget {
  final Post_feed post;

  const PostFullScreen({Key? key, required this.post}) : super(key: key);

  @override
  _PostFullScreenState createState() => _PostFullScreenState();
}

class _PostFullScreenState extends State<PostFullScreen> {
  late Post_feed post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post by ${post.username}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display media if available
            if (post.media_urls != null && post.media_urls!.isNotEmpty)
              SizedBox(
                height: 250,
                child: PageView(
                  children: post.media_urls!
                      .map((url) => Image.network(url, fit: BoxFit.cover))
                      .toList(),
                ),
              ),
            const SizedBox(height: 12),

            // Post caption
            Text(post.caption ?? '', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),

            // Like and comment row
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.isliked ? Icons.favorite : Icons.favorite_border,
                    color: post.isliked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      post.toggleLike();
                    });
                  },
                ),
                Text('${post.like_count} likes'),
                const SizedBox(width: 20),
                const Icon(Icons.comment),
                const SizedBox(width: 4),
                Text('${post.comment_count} comments'),
              ],
            ),
            const Divider(),

            // Comments section
            Text("Comments", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            ...post.commentsList.map(
                  (comment) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(comment.profileImage),
                ),
                title: Text(comment.username),
                subtitle: Text(comment.content),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        comment.isliked ? Icons.favorite : Icons.favorite_border,
                        color: comment.isliked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          comment.toggleLike();
                        });
                      },
                    ),
                    Text('${comment.likes}')
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
