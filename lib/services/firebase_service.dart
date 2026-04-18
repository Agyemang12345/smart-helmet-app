import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_data.dart';
import '../models/alert_event.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  String _nodePath(String node) {
    final uid = auth.currentUser?.uid;
    return uid != null ? 'users/$uid/$node' : 'public/$node';
  }

  Future<UserCredential> signIn(String email, String password) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp(String email, String password) {
    return auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() {
    return auth.signOut();
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
