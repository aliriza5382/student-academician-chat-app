import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addMessage(
      String message, String senderId, String receiverId) async {
    await _firestore.collection('messages').add({
      'message': message,
      'senderId': senderId,
      'receiverId': receiverId,
      'timeStamp': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> getMessages(String userId) {
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addUser(
      String name, String username, String password, String role) async {
    final collection = role == 'student' ? 'students' : 'academicians';

    await _firestore.collection(collection).add({
      'name': name,
      'username': username,
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
