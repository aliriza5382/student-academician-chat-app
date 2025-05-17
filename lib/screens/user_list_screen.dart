import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore ile bağlantı
import 'message_screen.dart'; // Mesaj ekranı

// Kullanıcı listesi ekranı sınıfı
class UserListScreen extends StatelessWidget {
  final String loggedInUserId; // Giriş yapan kullanıcının ID'si
  final String userType; // Kullanıcı tipi: "student" veya "academician"

  const UserListScreen({super.key, required this.loggedInUserId, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Arka plan rengi (Açık Bej)
      appBar: AppBar(
        backgroundColor: const Color(0xFF121E2D), // Başlık rengi (Koyu Mavi)
        title: const Text(
          'Kullanıcılar', // Ekran başlığı
          style: TextStyle(
            color: Colors.white, // Beyaz başlık yazı rengi
          ),
        ),
        centerTitle: true, // Başlığı ortala
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Geri dön
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(userType == 'student' ? 'academicians' : 'students') // Kullanıcı tipine göre koleksiyon seçimi
            .snapshots(), // Veri akışı
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator()); // Veri yüklenirken spinner
          }

          final users = snapshot.data!.docs; // Kullanıcı verileri

          return ListView.separated(
            padding: const EdgeInsets.all(10), // Liste kenar boşlukları
            itemCount: users.length, // Liste eleman sayısı
            separatorBuilder: (context, index) => const SizedBox(height: 10), // Elemanlar arası boşluk
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user.id; // Kullanıcının ID'si
              final userName = user['name']; // Kullanıcı adı

              // Kullanıcı engelleme durumu için değişken
              bool isBlocked = false;

              return StatefulBuilder(
                builder: (context, setState) {
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Mesaj ekranına yönlendirme
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessageScreen(
                                  loggedInUserId: loggedInUserId, // Gönderenin ID'si
                                  receiverId: userId, // Alıcının ID'si
                                  receiverName: userName, // Alıcının adı
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCC00), // Buton rengi (Altın sarısı)
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25), // Yuvarlatılmış köşeler
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15), // İç dolgu
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Colors.black), // Kullanıcı simgesi
                              const SizedBox(width: 10), // İkon ile yazı arası boşluk
                              Text(
                                userName, // Kullanıcı adı
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Siyah yazı rengi
                                ),
                              ),
                              const SizedBox(width: 10), // Yazı ile engelli simgesi arası boşluk
                              if (isBlocked)
                                const Icon(Icons.block, color: Colors.red), // Engelli simgesi
                            ],
                          ),
                        ),
                      ),
                      if (userType == 'academician') // Akademisyen için engelleme menüsü
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.black), // Menü ikonu
                          onSelected: (value) async {
                            if (value == 'Engelle') {
                              // Kullanıcıyı engelle
                              await FirebaseFirestore.instance
                                  .collection('blockedStudents')
                                  .doc(loggedInUserId)
                                  .set({
                                'blocked': FieldValue.arrayUnion([userId]), // Kullanıcıyı engelleme listesine ekle
                              }, SetOptions(merge: true));
                              setState(() {
                                isBlocked = true; // Engelleme durumu güncellenir
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$userName başarıyla engellendi.')), // Başarı mesajı
                              );
                            } else if (value == 'Engeli Kaldır') {
                              // Kullanıcı engelini kaldır
                              await FirebaseFirestore.instance
                                  .collection('blockedStudents')
                                  .doc(loggedInUserId)
                                  .update({
                                'blocked': FieldValue.arrayRemove([userId]), // Kullanıcıyı engelleme listesinden çıkar
                              });
                              setState(() {
                                isBlocked = false; // Engelleme durumu kaldırılır
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$userName üzerindeki engel kaldırıldı.')), // Başarı mesajı
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'Engelle',
                              child: Text('Engelle'), // Menüde "Engelle" seçeneği
                            ),
                            PopupMenuItem(
                              value: 'Engeli Kaldır',
                              child: Text('Engeli Kaldır'), // Menüde "Engeli Kaldır" seçeneği
                            ),
                          ],
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
