import 'package:flutter/material.dart';
import 'user_list_screen.dart'; // Kullanıcı listesini gösteren ekran
import 'group_list_screen.dart'; // Grup mesajlaşma ekranı
import 'course_selection_screen.dart'; // Ders seçimi ekranı
import 'course_list_screen.dart'; // Ders listeleme ekranı
import 'change_password_screen.dart';

// Akademisyen ana ekranı sınıfı
class AcademicianHome extends StatelessWidget {
  final String loggedInUserId; // Giriş yapan akademisyenin ID'si

  const AcademicianHome({super.key, required this.loggedInUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Açık bej arka plan rengi
      appBar: AppBar(
        backgroundColor: const Color(0xFF121E2D), // Başlık rengi (Koyu mavi)
        title: const Text(
          'Akademisyen Paneli', // Ekran başlığı
          style: TextStyle(
            color: Colors.white, // Beyaz başlık yazı rengi
          ),
        ),
        centerTitle: true, // Başlığı ortala
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Ekran kenar boşlukları
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // İçeriği yukarı ve aşağı ayır
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Satır içi buton düzeni
                  children: [
                    // Ders Listeleme Butonu
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Ders listeleme ekranına yönlendirme
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseListScreen(
                                userId: loggedInUserId,
                                userType: 'academician', // Kullanıcı tipi akademisyen
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list, color: Colors.black), // Listeleme ikonu
                        label: const Text(
                          'Dersleri Listele', // Buton yazısı
                          style: TextStyle(
                            fontSize: 18, // Yazı boyutu
                            fontWeight: FontWeight.bold, // Kalın yazı
                            color: Colors.black, // Siyah yazı rengi
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCC00), // Altın sarısı buton rengi
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25), // Yuvarlatılmış köşeler
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15), // Buton iç dolgu
                          minimumSize: const Size(double.infinity, 60), // Buton genişliği
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // Butonlar arası boşluk
                    // Ders Düzenleme Butonu
                    IconButton(
                      onPressed: () {
                        // Ders seçimi ekranına yönlendirme
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseSelectionScreen(
                              userId: loggedInUserId,
                              userType: 'academician', // Kullanıcı tipi akademisyen
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.black), // Düzenleme ikonu
                      tooltip: 'Ders Düzenleme', // İkon üzerine gelindiğinde görünecek yazı
                      color: const Color(0xFF121E2D), // İkon rengi (Koyu mavi)
                    ),
                  ],
                ),
                const SizedBox(height: 15), // Satırlar arası boşluk

                // Toplu Mesajlaşma Butonu
                ElevatedButton.icon(
                  onPressed: () {
                    // Grup listeleme ekranına yönlendirme
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupListScreen(
                          loggedInUserId: loggedInUserId, // Oturum açan akademisyenin ID'si
                          isAcademician: true, // Kullanıcı akademisyen olduğu için true
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.group, color: Colors.black), // Grup ikonu
                  label: const Text(
                    'Toplu Mesajlaşma', // Buton yazısı
                    style: TextStyle(
                      fontSize: 18, // Yazı boyutu
                      fontWeight: FontWeight.bold, // Kalın yazı
                      color: Colors.black, // Siyah yazı rengi
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00), // Altın sarısı buton rengi
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // Yuvarlatılmış köşeler
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15), // Buton iç dolgu
                    minimumSize: const Size(double.infinity, 60), // Buton genişliği
                  ),
                ),
                const SizedBox(height: 15),

                // Mesaj Bilgileri Butonu
                ElevatedButton.icon(
                  onPressed: () {
                    // Kullanıcı listesi ekranına yönlendirme
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserListScreen(
                          loggedInUserId: loggedInUserId,
                          userType: 'academician', // Kullanıcı tipi akademisyen
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message, color: Colors.black), // Mesaj ikonu
                  label: const Text(
                    'Mesaj Bilgileri', // Buton yazısı
                    style: TextStyle(
                      fontSize: 18, // Yazı boyutu
                      fontWeight: FontWeight.bold, // Kalın yazı
                      color: Colors.black, // Siyah yazı rengi
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00), // Altın sarısı buton rengi
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // Yuvarlatılmış köşeler
                    ),
                    minimumSize: const Size(double.infinity, 50), // Buton genişliği
                  ),
                ),

                const SizedBox(height: 15),

                // Şifre Değiştir Butonu
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(
                          loggedInUserId: loggedInUserId,
                          userType: 'academician',
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
