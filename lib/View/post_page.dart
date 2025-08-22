import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/Post_card.dart';
import '../Model/post.dart';
import 'dart:io';
import '../ViewModel/post_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ViewModel/auth_provider.dart';
import '../ViewModel/setProfileProvider.dart';

class PostCreateScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends ConsumerState<PostCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final SupabaseClient _supabase = Supabase.instance.client;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();

    _titleController.addListener(() {
      ref.read(postCreateProvider.notifier).updateTitle(_titleController.text);
    });

    _contentController.addListener(() {
      ref.read(postCreateProvider.notifier).updateContent(_contentController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(authStateProvider).value;
      if (session != null) {
        ref.read(setProfileProvider.notifier).getUserProfile(session.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showTagDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Add Tag', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _tagController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _addTag(value);
              _tagController.clear();
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (_tagController.text.isNotEmpty) {
                _addTag(_tagController.text);
                _tagController.clear();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      ref.read(postCreateProvider.notifier).updateTags(_tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    ref.read(postCreateProvider.notifier).updateTags(_tags);
  }

  Future<void> _handleCreatePost() async {
    final success = await ref.read(postCreateProvider.notifier).createPost();
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Discard Changes?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(postCreateProvider.notifier).clearForm();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Add Media',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Photo Library', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(postCreateProvider.notifier).pickMedia();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(postCreateProvider.notifier).pickMedia(fromCamera: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.red),
                title: const Text('Video Library', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(postCreateProvider.notifier).pickVideo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_call, color: Colors.orange),
                title: const Text('Record Video', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(postCreateProvider.notifier).pickVideo(fromCamera: true);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final postCreateState = ref.watch(postCreateProvider);
    final authState = ref.watch(authStateProvider);
    final profileState = ref.watch(setProfileProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Show error messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (postCreateState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(postCreateState.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () => ref.read(postCreateProvider.notifier).clearError(),
            ),
          ),
        );
      }
    });

    return PopScope(
      canPop: !postCreateState.hasUnsavedChanges,
      onPopInvoked: (didPop) {
        if (!didPop && postCreateState.hasUnsavedChanges) {
          _showDiscardDialog();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
            onPressed: () {
              if (postCreateState.hasUnsavedChanges) {
                _showDiscardDialog();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            'Create Post',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: isTablet ? 20 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            if (postCreateState.hasUnsavedChanges)
              TextButton(
                onPressed: postCreateState.isLoading
                    ? null
                    : () => ref.read(postCreateProvider.notifier).saveDraft(),
                child: Text(
                  'Draft',
                  style: TextStyle(
                    color: postCreateState.isLoading ? Colors.grey : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: postCreateState.isLoading ? null : _handleCreatePost,
          backgroundColor: Colors.blue,
          icon: const Icon(Icons.send_sharp, size: 20, color: Colors.white),
          label: const Text(
            'Post',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            // Error
            if (postCreateState.error != null)
              Container(
                width: double.infinity,
                color: Colors.red.withOpacity(0.1),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        postCreateState.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: () => ref.read(postCreateProvider.notifier).clearError(),
                    ),
                  ],
                ),
              ),

            // Success
            if (postCreateState.successMessage != null)
              Container(
                width: double.infinity,
                color: Colors.green.withOpacity(0.1),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        postCreateState.successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.green, size: 20),
                      onPressed: () => ref.read(postCreateProvider.notifier).clearSuccessMessage(),
                    ),
                  ],
                ),
              ),

            // Loader
            if (postCreateState.isLoading)
              const LinearProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Media Preview
                    if (postCreateState.selectedMedia.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Media Preview',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: postCreateState.selectedMedia.length,
                              itemBuilder: (context, index) {
                                final media = postCreateState.selectedMedia[index];
                                return Container(
                                  width: 150,
                                  height: 150,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[800],
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(media.path),
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => ref.read(postCreateProvider.notifier).removeMedia(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Add Media Button
    Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: OutlinedButton.icon(
    onPressed: _showMediaPicker,
    icon: const Icon(Icons.add_photo_alternate, color: Colors.blue, size: 20),
    label: const Text(
    'Add Media',
    style: TextStyle(color: Colors.blue, fontSize: 14),
    ),
    style: OutlinedButton.styleFrom(
    side: BorderSide(color: Colors.blue),
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
    ),
    ),
    ),
    ),


                    // Title Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: TextField(
                        controller: _titleController,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Enter your title here...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.next,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Content Input
                    Container(
                      height: 250,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          child: TextField(
                            controller: _contentController,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 18 : 16,
                              height: 1.5,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Write your post content here...',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tags Section
                    Row(
                      children: [
                        Icon(Icons.local_offer_outlined, color: Colors.grey[400], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Tags',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _showTagDialog,
                          icon: const Icon(Icons.add, color: Colors.blue, size: 20),
                          label: const Text('Add Tag', style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Tag chips or empty state
                    if (_tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tag,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _removeTag(tag),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueAccent, width: 1.5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb_outline_sharp,
                              color: Colors.blueAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'No tags added yet. Tags help others discover your post.',
                                style: TextStyle(
                                  color: Colors.grey[200],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Preview Section
                    Text(
                      'Preview',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(color: Colors.grey[800], thickness: 1),
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: (_titleController.text.isEmpty &&
                          _contentController.text.isEmpty &&
                          _tags.isEmpty &&
                          postCreateState.selectedMedia.isEmpty)
                          ? Container(
                        padding: const EdgeInsets.all(16),

                        child: Center(
                          child: Text(
                            'Start typing to see a preview',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                          : authState.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Text('Error loading user data: $error', style: TextStyle(color: Colors.red)),
                        ),
                        data: (session) {
                          return profileState.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, stack) => Center(
                              child: Text('Error loading profile: $error', style: TextStyle(color: Colors.red)),
                            ),
                            data: (profile) {
                              final userId = session?.user?.id ?? 'preview_user';
                              final username = profile?.username ?? 'You';
                              final profilePic = profile?.profilePic;

                              return PostCard(
                                post: Post_feed(
                                  post_id: 'preview_${DateTime.now().millisecondsSinceEpoch}',
                                  user_id: userId,
                                  title: _titleController.text,
                                  content: _contentController.text,
                                  caption: '',
                                  tags: _tags,
                                  localMediaFiles: postCreateState.selectedMedia,
                                  username: username,
                                  profile_pic: profilePic,
                                  created_at: DateTime.now(),
                                  like_count: 0,
                                  comment_count: 0,
                                  share_count: 0,
                                  isliked: false,
                                  commentsList: [],
                                ),
                                isPreview: true,
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 100),
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