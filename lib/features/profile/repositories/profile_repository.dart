import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../../auth/auth_repository.dart';
import '../services/ai_assessment_service.dart';
import '../../../core/services/storage_service.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final AiAssessmentService? _assessmentService;
  final StorageService? _storageService;

  ProfileRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    AiAssessmentService? assessmentService,
    StorageService? storageService,
  })  : _firestore = firestore,
        _auth = auth,
        _assessmentService = assessmentService,
        _storageService = storageService;

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

  Stream<UserProfile?> watchProfile([String? userId]) {
    final uid = userId ?? _userId;
    if (uid == null) {
      return Stream.value(null);
    }

    try {
      return _firestore
          .collection('users')
          .doc(uid)
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
      final assessment = await _assessmentService.generateAssessment(profile);
      
      // Save it back to the profile
      await saveProfile(UserProfile(
        uid: profile.uid,
        basicInfo: profile.basicInfo,
        bodyMetrics: profile.bodyMetrics,
        fitnessProfile: profile.fitnessProfile,
        nutritionProfile: profile.nutritionProfile,
        healthLifestyle: profile.healthLifestyle,
        isProfileComplete: profile.isProfileComplete,
        lastAssessment: assessment,
        lastAssessmentDate: DateTime.now(),
        hasSeenOnboarding: profile.hasSeenOnboarding,
      ));
      
      return assessment;
    }
    return 'Detailed assessment is currently unavailable. Please check your internet connection.';
  }

  Future<void> updateOnboardingStatus(bool hasSeen) async {
    if (_userId == null) return;
    await _firestore.collection('users').doc(_userId).update({
      'hasSeenOnboarding': hasSeen,
    });
  }

  Future<String> uploadProfileImage(File file) async {
    if (_storageService == null || _userId == null) {
      throw Exception('Storage service not available');
    }

    final url = await _storageService.uploadProfilePicture(file);
    
    // Update profile with new URL in both Firestore and Auth
    await Future.wait([
       _firestore.collection('users').doc(_userId).update({
         'basicInfo.photoUrl': url,
       }),
       _auth.currentUser!.updatePhotoURL(url),
    ]);

    return url;
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    assessmentService: ref.watch(aiAssessmentServiceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

final profileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.read(profileRepositoryProvider).watchProfile(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => Stream.value(null),
  );
});
