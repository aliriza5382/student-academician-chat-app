import 'package:flutter/material.dart';
import 'user_list_screen.dart'; // Kullanıcı listesini gösteren ekran
import 'group_list_screen.dart'; // Grup mesajlaşma ekranı
import 'course_list_screen.dart'; // Dersleri listeleme ekranı
import 'course_selection_screen.dart'; // Ders seçimi ekranı
import 'change_password_screen.dart';

// Öğrenci ana ekranı sınıfı
class StudentHome extends StatelessWidget {
  final String loggedInUserId; // Giriş yapan kullanıcının ID'si

  const StudentHome({super.key, required this.loggedInUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Arka plan rengi (Açık Bej)
      appBar: AppBar(
        backgroundColor: const Color(0xFF121E2D), // Başlık rengi (Koyu Mavi)
        title: const Text(
          'Öğrenci Paneli', // Başlık yazısı
          style: TextStyle(
            color: Colors.white, // Beyaz başlık yazı rengi
          ),
        ),
        centerTitle: true, // Başlığı ortala
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // İçerik kenar boşlukları
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // İçeriği yukarı ve aşağı düzenle
          children: [
            Column(
              children: [
                // Toplu Mesajlaşma Butonu
                ElevatedButton.icon(
                  onPressed: () {
                    // Grup listeleme ekranına geçiş
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupListScreen(
                          loggedInUserId: loggedInUserId,
                          isAcademician: false, // Kullanıcı öğrenci olduğu için false
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.group, color: Colors.black), // Grup ikonu
                  label: const Text(
                    'Toplu Mesajlaşma', // Buton yazısı
                    style: TextStyle(
                      fontSize: 18, // Yazı boyutu
                      fontWeight: FontWeight.bold, // Kalın yazı stili
                      color: Colors.black, // Siyah yazı rengi
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00), // Altın sarısı buton rengi
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // Yuvarlatılmış köşeler
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15), // İç dolgu
                    minimumSize: const Size(double.infinity, 60), // Buton genişliği
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Butonları yatayda düzenle
                  children: [
                    // Ders Listeleme Butonu
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Ders listeleme ekranına geçiş
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseListScreen(
                                userId: loggedInUserId,
                                userType: 'student', // Kullanıcı tipi öğrenci
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list, color: Colors.black), // Listeleme ikonu
                        label: const Text(
                          'Dersleri Listele', // Buton yazısı
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Siyah yazı rengi
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCC00), // Altın sarısı buton rengi
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25), // Yuvarlatılmış köşeler
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15), // İç dolgu
                          minimumSize: const Size(double.infinity, 60), // Buton genişliği
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Ders Düzenleme Butonu
                    IconButton(
                      onPressed: () {
                        // Ders seçimi ekranına geçiş
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseSelectionScreen(
                              userId: loggedInUserId,
                              userType: 'student', // Kullanıcı tipi öğrenci
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.black), // Düzenleme ikonu
                      tooltip: 'Ders Düzenleme', // İkon üzerine gelince gösterilecek yazı
                      color: const Color(0xFF121E2D), // İkon rengi (Koyu Mavi)
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Mesaj Bilgileri Butonu
                ElevatedButton.icon(
                  onPressed: () {
                    // Kullanıcı listesi ekranına geçiş
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserListScreen(
                          loggedInUserId: loggedInUserId,
                          userType: 'student', // Kullanıcı tipi öğrenci
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message, color: Colors.black), // Mesaj ikonu
                  label: const Text(
                    'Mesaj', // Buton yazısı
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Siyah yazı rengi
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00), // Altın sarısı buton rengi
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // Yuvarlatılmış köşeler
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15), // İç dolgu
                    minimumSize: const Size(double.infinity, 60), // Buton genişliği
                  ),
                ),

                const SizedBox(height: 20),

                // Şifre Değiştir Butonu
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(
                          loggedInUserId: loggedInUserId,
                          userType: 'student',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.lock, color: Colors.white),
                  label: const Text(
                    'Şifre Değiştir',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF121E2D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),

            // Güvenli Çıkış Butonu
            ElevatedButton.icon(
              onPressed: () {
                // Çıkış işlemi
                Navigator.pop(context); // Bir önceki ekrana geri dön
              },
              icon: const Icon(Icons.logout, color: Colors.white), // Çıkış ikonu
              label: const Text(
                'Güvenli Çıkış', // Buton yazısı
                style: TextStyle(
                  fontSize: 16, // Yazı boyutu küçültüldü
                  fontWeight: FontWeight.w500, // Yazı kalınlığı orta
                  color: Colors.white, // Beyaz yazı rengi
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF121E2D), // Koyu mavi buton rengi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Hafif yuvarlatılmış köşeler
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // İç dolgu küçültüldü
                minimumSize: const Size(150, 50), // Buton genişliği küçültüldü
              ),
            ),
          ],
        ),
      ),
    );
  }
}
