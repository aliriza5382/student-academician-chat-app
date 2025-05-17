import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore bağlantısı
import 'student_home.dart'; // Öğrenci ana ekranı
import 'academician_home.dart'; // Akademisyen ana ekranı
import 'package:intl/intl.dart'; // Tarih ve zaman formatlama için
import 'course_selection_screen.dart'; // Ders seçimi ekranı

// Giriş ekranı için StatefulWidget sınıfı
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState(); // Durum sınıfı oluşturuluyor
}

// Giriş ekranının durum sınıfı
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController(); // Kullanıcı adı kontrolcüsü
  final TextEditingController _passwordController = TextEditingController(); // Şifre kontrolcüsü
  String _role = 'student'; // Varsayılan kullanıcı rolü

  // Şu anki zamanı döndüren fonksiyon
  String getCurrentTime() {
    return DateFormat('HH:mm').format(DateTime.now()); // Saat ve dakika formatı
  }

  // Şu anki tarihi döndüren fonksiyon
  String getCurrentDate() {
    return DateFormat('dd/MM/yyyy').format(DateTime.now()); // Gün, ay ve yıl formatı
  }

  // Kullanıcı giriş işlemleri
  Future<void> loginUser(BuildContext context) async {
    String username = _usernameController.text.trim(); // Kullanıcı adı girilen metin
    String password = _passwordController.text.trim(); // Şifre girilen metin

    // Kullanıcı adı ve şifre boş kontrolü
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun.')), // Uyarı mesajı
      );
      return;
    }

    // Firebase'de koleksiyon seçimi
    final collection = _role == 'student' ? 'students' : 'academicians';
    final querySnapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('username', isEqualTo: username)
        .get();

    // Kullanıcı bulunamazsa uyarı göster
    if (querySnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı bulunamadı veya bilgiler yanlış.')), // Uyarı mesajı
      );
      return;
    }

    final user = querySnapshot.docs.first.data(); // İlk kullanıcıyı al
    if (user['password'] == password) {
      String loggedInUserId = querySnapshot.docs.first.id; // Kullanıcı ID'si
      String name = user['name']; // Kullanıcı adı

      // Hoş geldiniz mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _role == 'student'
                ? 'Hoşgeldin $name'
                : 'Hoşgeldiniz $name Hocam', // Kullanıcı rolüne göre mesaj
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF121E2D),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // Ders seçimi kontrolü
      final courseDoc = await FirebaseFirestore.instance
          .collection('selectedCourses')
          .doc(loggedInUserId)
          .get();

      if (!courseDoc.exists) {
        // Ders seçimi yapılmamışsa seçim ekranına yönlendirme
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CourseSelectionScreen(
              userId: loggedInUserId,
              userType: _role,
            ),
          ),
        );
      } else {
        // Ders seçimi yapılmışsa ana ekrana yönlendirme
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _role == 'student'
                ? StudentHome(loggedInUserId: loggedInUserId)
                : AcademicianHome(loggedInUserId: loggedInUserId),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Şifre yanlış.')), // Yanlış şifre uyarısı
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Arka plan rengi (Açık Bej)
      appBar: AppBar(
        backgroundColor: const Color(0xFF121E2D), // Koyu Mavi Başlık
        title: const Text(
          'Giriş Yap', // Başlık
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, // Başlığı ortalar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Geri dön
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zaman ve Tarih Gösterimi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Zaman: ${getCurrentTime()}', // Zaman formatı
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF121E2D),
                  ),
                ),
                Text(
                  'Tarih: ${getCurrentDate()}', // Tarih formatı
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF121E2D),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30), // Boşluk
            // Kullanıcı Adı Alanı
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı', // Etiket
                labelStyle: TextStyle(color: const Color(0xFF121E2D)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF121E2D)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF121E2D)),
                ),
              ),
            ),
            SizedBox(height: 20), // Boşluk
            // Şifre Alanı
            TextField(
              controller: _passwordController,
              obscureText: true, // Şifre gizleme
              decoration: InputDecoration(
                labelText: 'Şifre', // Etiket
                labelStyle: TextStyle(color: const Color(0xFF121E2D)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF121E2D)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF121E2D)),
                ),
              ),
            ),
            SizedBox(height: 30), // Boşluk
            // Rol Seçimi Dropdown
            DropdownButton<String>(
              value: _role,
              dropdownColor: Colors.white, // Açılır menü rengi
              onChanged: (value) {
                setState(() {
                  _role = value!; // Seçilen rol
                });
              },
              items: [
                DropdownMenuItem(
                  value: 'student',
                  child: Center(
                    child: Text(
                      'ÖĞRENCİ',
                      style: TextStyle(color: const Color(0xFF121E2D)),
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'academician',
                  child: Center(
                    child: Text(
                      'AKADEMİSYEN',
                      style: TextStyle(color: const Color(0xFF121E2D)),
                    ),
                  ),
                ),
              ],
              isExpanded: true, // Tam genişlik
              underline: Container(
                height: 1,
                color: const Color(0xFF121E2D),
              ),
            ),
            SizedBox(height: 30), // Boşluk
            // Giriş Yap Butonu
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC00), // Buton rengi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Köşe yuvarlatma
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50, // Yatay dolgu
                    vertical: 15, // Dikey dolgu
                  ),
                ),
                onPressed: () => loginUser(context), // Giriş işlemi
                child: Text(
                  'GİRİŞ YAP', // Buton yazısı
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
