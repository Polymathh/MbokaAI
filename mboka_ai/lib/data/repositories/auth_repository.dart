import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';


class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream to track the user's authentication state in real-time
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  // 🔑 Get a user's profile data after successful authentication
  Future<AppUser> getUserData(User user) async {
    // 1. Fetch the user document from Firestore using the Firebase UID
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final businessName = data['businessName'] as String? ?? 'Hustler';
      
      // 2. Return the custom AppUser model
      return AppUser.fromFirebaseUser(user, businessName);
    }
    
    // Fallback if Firestore data is missing
    return AppUser.fromFirebaseUser(user, 'Hustler');
  }

  // 🔐 SIGN UP with Email and Password
  Future<void> signUp({
    required String email,
    required String password,
    required String businessName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Additional Step: Write Business Name to Firestore (Required by your spec)
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'businessName': businessName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
    } on FirebaseAuthException catch (e) {
      // Re-throw the exception so the BLoC can handle it and update the UI
      throw Exception(e.message ?? 'Registration failed.');
    }
  }

  // 🔑 SIGN IN with Email and Password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed. Check credentials.');
    }
  }

  // 🚪 SIGN OUT
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}