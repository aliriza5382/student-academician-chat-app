import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore bağlantısı
import 'message_screen.dart'; // Mevcut mesajlaşma ekranını temsil eder

// Öğrencilerin listelendiği ekran
class StudentListScreen extends StatelessWidget {
  final String courseName; // Hangi dersin öğrencilerinin listeleneceğini belirten ders adı
  final String loggedInUserId; // Şu an oturum açmış kullanıcının ID'si

  const StudentListScreen({
    required this.courseName,
    required this.loggedInUserId,
    super.key,
  }); // Constructor tanımı

  // Öğrencinin adını Firestore'dan alma fonksiyonu
  Future<String> getStudentName(String studentId) async {
    try {
      // Firestore'da öğrenci koleksiyonunu kontrol et
      DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students') // Öğrenci koleksiyonu
          .doc(studentId) // Öğrenci ID'sine göre belgeyi al
          .get();

      if (studentSnapshot.exists) {
        return studentSnapshot['name']; // Eğer öğrenci bulunursa adını döndür
      } else {
        return "Bilinmeyen Öğrenci"; // Eğer öğrenci bulunamazsa varsayılan metni döndür
      }
    } catch (e) {
      return "Hata: $e"; // Hata durumunda hata mesajını döndür
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dersi Alan Öğrenciler", // Başlık metni
          style: TextStyle(color: Colors.white), // Yazı rengi beyaz
        ),
        backgroundColor: const Color(0xFF121E2D), // Başlık arka plan rengi
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Geri dön
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('selectedCourses') // Firestore koleksiyon adı
            .where('courses', arrayContains: courseName) // Ders adına göre filtrele
            .where('userType', isEqualTo: 'student') // Sadece öğrenci kayıtlarını getir
            .snapshots(), // Anlık veri akışı
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Yükleniyor göstergesi
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Bu dersi alan öğrenci bulunamadı.")); // Öğrenci yok mesajı
          }

          List<QueryDocumentSnapshot> students = snapshot.data!.docs; // Öğrenci belgeleri listesi

          return ListView.builder(
            itemCount: students.length, // Öğrenci sayısı
            itemBuilder: (context, index) {
              var student = students[index]; // Öğrenci bilgisi
              String studentId = student['userId']; // Öğrenci ID'si

              return FutureBuilder<String>(
                future: getStudentName(studentId), // Öğrenci ismini al
                builder: (context, nameSnapshot) {
                  if (nameSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text("Yükleniyor..."), // Yükleniyor mesajı
                      leading: Icon(Icons.person, color: Colors.black), // İkon
                    );
                  }
                  if (nameSnapshot.hasError) {
                    return ListTile(
                      title: Text("Hata: ${nameSnapshot.error}"), // Hata mesajı
                      leading: const Icon(Icons.error, color: Colors.red), // Hata ikonu
                    );
                  }

                  String studentName = nameSnapshot.data ?? "Bilinmeyen Öğrenci"; // Öğrenci adı

                  return ListTile(
                    title: Text(studentName), // Öğrenci adı
                    subtitle: Text("ID: $studentId"), // Öğrenci ID'si (isteğe bağlı)
                    leading: const Icon(Icons.person, color: Colors.black), // İkon
                    onTap: () {
                      // Öğrenciye tıklanınca mesajlaşma ekranına yönlendir
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessageScreen(
                            loggedInUserId: loggedInUserId, // Giriş yapan kullanıcı ID'si
                            receiverId: studentId, // Alıcı öğrenci ID'si
                            receiverName: studentName, // Alıcı öğrenci adı
                          ),
                        ),
                      );
                    },
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
