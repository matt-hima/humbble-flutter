import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.photoUrl,
    this.goal = 'A meaningful connection',
    this.interests = const [],
  });
  final String id, name, bio, photoUrl, goal;
  final int age;
  final List<String> interests;
  factory Profile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Profile(
      id: doc.id,
      name: d['name'] ?? 'New member',
      age: d['age'] ?? 18,
      bio: d['bio'] ?? '',
      photoUrl: d['photoUrl'] ?? '',
      goal: d['goal'] ?? 'A meaningful connection',
      interests: List<String>.from(d['interests'] ?? []),
    );
  }
  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'bio': bio,
    'photoUrl': photoUrl,
    'goal': goal,
    'interests': interests,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

class Conversation {
  const Conversation({
    required this.id,
    required this.memberIds,
    required this.title,
    required this.photoUrl,
    this.lastMessage = '',
  });
  final String id, title, photoUrl, lastMessage;
  final List<String> memberIds;
  factory Conversation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Conversation(
      id: doc.id,
      memberIds: List<String>.from(d['memberIds'] ?? []),
      title: d['title'] ?? 'Match',
      photoUrl: d['photoUrl'] ?? '',
      lastMessage: d['lastMessage'] ?? 'Say hello',
    );
  }
}
