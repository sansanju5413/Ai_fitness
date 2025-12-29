import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageService {
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  StorageService(this._storage, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  /// Uploads a profile picture for the current user.
  /// Returns the download URL.
  Future<String> uploadProfilePicture(File file) async {
    if (_userId == null) {
      throw Exception('User must be logged in to upload profile picture');
    }

    final extension = file.path.split('.').last;
    final ref = _storage
        .ref()
        .child('users')
        .child(_userId!)
        .child('profile_picture.$extension');

    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  /// Deletes the current user's profile picture if it exists in storage.
  Future<void> deleteProfilePicture(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('[StorageService] Error deleting profile picture: $e');
    }
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(FirebaseStorage.instance, FirebaseAuth.instance);
});
