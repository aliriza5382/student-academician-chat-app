import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_screen.dart'; // Mesajlaşma ekranı

// Akademisyenleri listelemek için ekran
class AcademicianListScreen extends StatelessWidget {
  final String courseName; // Hangi dersin akademisyenlerinin listeleneceğini belirten ders adı
  final String loggedInUserId; // Giriş yapan kullanıcının ID'si

  const AcademicianListScreen({super.key, required this.courseName, required this.loggedInUserId});

  // Akademisyenin adını Firestore'dan alma fonksiyonu
  Future<String> getAcademicianName(String academicianId) async {
    try {
      // Firestore'da akademisyen koleksiyonunu kontrol et
      DocumentSnapshot academicianSnapshot = await FirebaseFirestore.instance
          .collection('academicians') // Akademisyen koleksiyonu
          .doc(academicianId) // Akademisyen ID'sine göre belgeyi al
          .get();

      if (academicianSnapshot.exists) {
        return academicianSnapshot['name']; // Eğer akademisyen bulunursa adını döndür
      } else {
        return "Bilinmeyen Akademisyen"; // Eğer akademisyen bulunamazsa varsayılan metni döndür
      }
    } catch (e) {
      return "Hata: $e"; // Hata durumunda hata mesajını döndür
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dersi Veren Akademisyenler", // Ekran başlığı
          style: TextStyle(color: Colors.white), // Başlık yazı rengi
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
            .where('courses', arrayContains: courseName) // Ders adına göre filtreleme
            .where('userType', isEqualTo: 'academician') // Sadece akademisyen kayıtlarını getir
            .snapshots(), // Anlık veri akışı
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Yükleniyor göstergesi
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Bu dersi veren akademisyen bulunamadı.")); // Akademisyen yok mesajı
          }

          List<QueryDocumentSnapshot> academicians = snapshot.data!.docs; // Akademisyen belgeleri listesi

          return ListView.builder(
            itemCount: academicians.length, // Akademisyen sayısı
            itemBuilder: (context, index) {
              var academician = academicians[index]; // Akademisyen bilgisi
              String academicianId = academician['userId']; // Akademisyen ID'si

              return FutureBuilder<String>(
                future: getAcademicianName(academicianId), // Akademisyen ismini al
                builder: (context, nameSnapshot) {
                  if (nameSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text("Yükleniyor..."), // Yükleniyor mesajı
                      leading: Icon(Icons.person, color: Colors.black), // İkon
                    );
                  }
                  if (nameSnapshot.hasError) {
                    return ListTile(
                      title: Text("Hata: ${nameSnapshot.error}"), // Hata mesajı
                      leading: Icon(Icons.error, color: Colors.red), // Hata ikonu
                    );
                  }

                  String academicianName =
                      nameSnapshot.data ?? "Bilinmeyen Akademisyen"; // Akademisyen adı

                  return ListTile(
                    title: Text(academicianName), // Akademisyen adı
                    subtitle: Text("ID: $academicianId"), // Akademisyen ID'si (isteğe bağlı)
                    leading: Icon(Icons.person, color: Colors.black), // İkon
                    onTap: () {
                      // Mesajlaşma ekranına yönlendirme
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessageScreen(
                            loggedInUserId: loggedInUserId, // Giriş yapan kullanıcı ID'si
                            receiverId: academicianId, // Alıcı akademisyen ID'si
                            receiverName: academicianName, // Alıcı akademisyen adı
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
