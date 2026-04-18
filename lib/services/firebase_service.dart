import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_data.dart';
import '../models/alert_event.dart';
import '../models/supervisor_profile.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  String _nodePath(String node) {
    final uid = auth.currentUser?.uid;
    return uid != null ? 'users/$uid/$node' : 'public/$node';
  }

  Future<UserCredential> signIn(String email, String password) async {
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Update last login time
    await updateLastLogin();
    return credential;
  }

  Future<UserCredential> signUp(String email, String password) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Create initial profile
    await _createInitialProfile(credential.user!);
    return credential;
  }

  Future<void> signOut() {
    return auth.signOut();
  }

  Future<void> _createInitialProfile(User user) async {
    final profile = SupervisorProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      createdAt: DateTime.now(),
    );
    await database.ref(_nodePath('profile')).set(profile.toJson());
  }

  Future<SupervisorProfile?> getUserProfile() async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        return null;
      }

      final snapshot = await database.ref(_nodePath('profile')).get();
      if (snapshot.exists) {
        return SupervisorProfile.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map),
        );
      }

      // Profile doesn't exist yet, return null
      // The settings screen will create a default one from Auth user
      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? department,
    String? profileImageUrl,
  }) async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        // Update Firebase Auth display name
        if (displayName != null && displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }

        // Update profile in database
        final snapshot = await database.ref(_nodePath('profile')).get();
        Map<String, dynamic> profileData =
            Map<String, dynamic>.from(snapshot.value as Map? ?? {});

        profileData.update(
          'displayName',
          (value) => displayName,
          ifAbsent: () => displayName,
        );
        profileData.update(
          'phoneNumber',
          (value) => phoneNumber,
          ifAbsent: () => phoneNumber,
        );
        profileData.update(
          'department',
          (value) => department,
          ifAbsent: () => department,
        );
        if (profileImageUrl != null) {
          profileData.update(
            'profileImageUrl',
            (value) => profileImageUrl,
            ifAbsent: () => profileImageUrl,
          );
        }

        await database.ref(_nodePath('profile')).set(profileData);
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final user = auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }

  Future<void> updateLastLogin() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final snapshot = await database.ref(_nodePath('profile')).get();
        Map<String, dynamic> profileData =
            Map<String, dynamic>.from(snapshot.value as Map? ?? {});
        profileData['lastLogin'] = DateTime.now().toIso8601String();
        await database.ref(_nodePath('profile')).update(profileData);
      }
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  Future<void> saveSensorRecord(SensorData data) async {
    final ref = database.ref(_nodePath('sensor_history')).push();
    await ref.set(data.toJson());
  }

  Future<void> saveAlertEvent(AlertEvent event) async {
    final ref = database.ref(_nodePath('alerts')).push();
    await ref.set(event.toJson());
  }
}
