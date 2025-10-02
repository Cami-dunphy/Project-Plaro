import 'package:flutter/material.dart';
import '../Model/toast.dart';

class ToastFullScreen extends StatefulWidget {
  final Toast_feed toast;

  const ToastFullScreen({Key? key, required this.toast}) : super(key: key);

  @override
  _ToastFullScreenState createState() => _ToastFullScreenState();
}

class _ToastFullScreenState extends State<ToastFullScreen> {
  late Toast_feed toast;

  @override
  void initState() {
    super.initState();
    toast = widget.toast;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Toast by ${toast.username}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toast title
            if (toast.title != null)
              Text(
                toast.title!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 12),

            // Toast content
            if (toast.content != null)
              Text(
                toast.content!,
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 12),

            // Like and comment row
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    toast.isliked ? Icons.favorite : Icons.favorite_border,
                    color: toast.isliked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      toast.toggleLike();
                    });
                  },
                ),
                Text('${toast.like_count} likes'),
                const SizedBox(width: 20),
                const Icon(Icons.comment),
                const SizedBox(width: 4),
                Text('${toast.comment_count} comments'),
              ],
            ),
            const Divider(),

            // Comments section
            Text("Comments", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            ...toast.commentsList.map(
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
                        comment.uliked ? Icons.favorite : Icons.favorite_border,
                        color: comment.uliked ? Colors.red : Colors.grey,
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
