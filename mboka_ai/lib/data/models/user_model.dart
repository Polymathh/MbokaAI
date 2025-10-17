import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser extends Equatable {
  final String uid;
  final String email;
  final String businessName;

  const AppUser({
    required this.uid,
    required this.email,
    required this.businessName,
  });

  // Factory to create an AppUser from Firebase Auth and Firestore data
  factory AppUser.fromFirebaseUser(User user, String bizName) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      businessName: bizName,
    );
  }

  // Empty user model for unauthenticated state
  static const empty = AppUser(uid: '', email: '', businessName: '');

  @override
  List<Object> get props => [uid, email, businessName];
}