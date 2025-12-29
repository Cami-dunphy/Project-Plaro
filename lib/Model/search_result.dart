import 'event.dart';
import 'post.dart';
import 'toast.dart';
import 'user_profile.dart';

enum SearchResultType { user, event, post, toast }

class SearchResult {
  final SearchResultType type;
  final dynamic data;

  SearchResult({required this.type, required this.data});

  // Factory constructors for each type
  factory SearchResult.user(UserProfile user) {
    return SearchResult(type: SearchResultType.user, data: user);
  }

  factory SearchResult.event(Event event) {
    return SearchResult(type: SearchResultType.event, data: event);
  }

  factory SearchResult.post(Post_feed post) {
    return SearchResult(type: SearchResultType.post, data: post);
  }

  factory SearchResult.toast(Toast_feed toast) {
    return SearchResult(type: SearchResultType.toast, data: toast);
  }

  // Getters for type checking
  bool get isUser => type == SearchResultType.user;
  bool get isEvent => type == SearchResultType.event;
  bool get isPost => type == SearchResultType.post;
  bool get isToast => type == SearchResultType.toast;

  // Getters for data
  UserProfile? get user => isUser ? data as UserProfile : null;
  Event? get event => isEvent ? data as Event : null;
  Post_feed? get post => isPost ? data as Post_feed : null;
  Toast_feed? get toast => isToast ? data as Toast_feed : null;
}
