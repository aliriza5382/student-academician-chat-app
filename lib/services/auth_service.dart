import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Geçici olarak oturum bilgilerini saklamak için değişkenler
  String? loggedInUserId;
  String? loggedInUserRole;

  Future<bool> loginUser(String username, String password, String role) async {
    final collection = role == 'student' ? 'students' : 'academicians';

    final querySnapshot = await _firestore
        .collection(collection)
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return false; // Kullanıcı bulunamadı
    }

    final user = querySnapshot.docs.first.data();
    if (user['password'] == password) {
      loggedInUserId = querySnapshot.docs.first.id;
      loggedInUserRole = role;
      return true; // Giriş başarılı
    }

    return false; // Şifre yanlış
  }

  // Giriş yapan kullanıcının ID'sini döner
  String? getLoggedInUserId() {
    return loggedInUserId;
  }

  // Giriş yapan kullanıcının rolünü döner
  String? getLoggedInUserRole() {
    return loggedInUserRole;
  }
}
