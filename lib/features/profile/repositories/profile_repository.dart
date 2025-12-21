import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/ai_assessment_service.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final AiAssessmentService? _assessmentService;

  ProfileRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    AiAssessmentService? assessmentService,
  })  : _firestore = firestore,
        _auth = auth,
        _assessmentService = assessmentService;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> saveProfile(UserProfile profile) async {
    if (_userId == null) {
      throw Exception('User must be logged in to save profile');
    }

    await _firestore
        .collection('users')
        .doc(_userId)
        .set(profile.toJson(), SetOptions(merge: true));
  }

  Future<UserProfile?> getProfile() async {
    if (_userId == null) {
      return null;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserProfile.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  Stream<UserProfile?> watchProfile() {
    if (_userId == null) {
      return Stream.value(null);
    }

    try {
      return _firestore
          .collection('users')
          .doc(_userId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return null;
        }
        try {
          return UserProfile.fromJson(snapshot.data()!);
        } catch (e) {
          return null;
        }
      });
    } catch (e) {
      return Stream.value(null);
    }
  }

  Future<String> generateAiAssessment(UserProfile profile) async {
    if (_assessmentService != null) {
      return _assessmentService.generateAssessment(profile);
    }
    return 'Detailed assessment is currently unavailable. Please check your internet connection.';
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    assessmentService: ref.watch(aiAssessmentServiceProvider),
  );
});

final profileStreamProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(profileRepositoryProvider).watchProfile();
});
