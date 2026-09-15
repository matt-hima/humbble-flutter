import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';

final authProvider = Provider<FirebaseAuth>((_) => FirebaseAuth.instance);
final dbProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);
final storageProvider = Provider<FirebaseStorage>(
  (_) => FirebaseStorage.instance,
);
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authProvider).authStateChanges(),
);
final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(ref.watch(dbProvider)),
);
final matchRepositoryProvider = Provider(
  (ref) => MatchRepository(ref.watch(dbProvider)),
);

class AuthRepository {
  AuthRepository(this._auth, this._db);
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  Future<void> signUp(String name, String email, String password) async {
    final r = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await r.user!.updateDisplayName(name.trim());
    await _db
        .collection('profiles')
        .doc(r.user!.uid)
        .set(
          Profile(
            id: r.user!.uid,
            name: name.trim(),
            age: 18,
            bio: 'Tell people about yourself',
            photoUrl: '',
          ).toMap(),
        );
  }

  Future<void> signOut() => _auth.signOut();
  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
}

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.watch(authProvider), ref.watch(dbProvider)),
);

class ProfileRepository {
  ProfileRepository(this._db);
  final FirebaseFirestore _db;
  Stream<Profile?> watch(String uid) => _db
      .collection('profiles')
      .doc(uid)
      .snapshots()
      .map((d) => d.exists ? Profile.fromDoc(d) : null);
  Stream<List<Profile>> discover(String uid) => _db
      .collection('profiles')
      .limit(40)
      .snapshots()
      .map(
        (s) => s.docs.map(Profile.fromDoc).where((p) => p.id != uid).toList(),
      );
  Future<void> save(Profile p) => _db
      .collection('profiles')
      .doc(p.id)
      .set(p.toMap(), SetOptions(merge: true));
}

class MatchRepository {
  MatchRepository(this._db);
  final FirebaseFirestore _db;
  Future<void> react({
    required String from,
    required String to,
    required bool liked,
  }) => _db.collection('reactions').doc('${from}_$to').set({
    'from': from,
    'to': to,
    'liked': liked,
    'createdAt': FieldValue.serverTimestamp(),
  });
  Stream<List<Conversation>> conversations(String uid) => _db
      .collection('conversations')
      .where('memberIds', arrayContains: uid)
      .snapshots()
      .map((s) => s.docs.map(Conversation.fromDoc).toList());
  Stream<QuerySnapshot<Map<String, dynamic>>> messages(String id) => _db
      .collection('conversations')
      .doc(id)
      .collection('messages')
      .orderBy('createdAt')
      .snapshots();
  Future<void> send(String id, String uid, String text) async {
    await _db.collection('conversations').doc(id).collection('messages').add({
      'senderId': uid,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('conversations').doc(id).set({
      'lastMessage': text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
