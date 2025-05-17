import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase bağlantısı için gerekli paket
import 'screens/welcome_screen.dart'; // Başlangıç ekranı dosyasını dahil etme
import 'firebase_options.dart'; // Firebase yapılandırma ayarlarını dahil etme

// Uygulamanın giriş noktası
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Widget bağlamasını başlatır, asenkron işlemler için gerekli
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase yapılandırmasını platforma göre başlatır
  );
  runApp(const MyApp()); // Uygulamayı başlatır
}

// Ana uygulama sınıfı
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor, opsiyonel bir anahtar alır

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Debug modunun üst bannerını kaldırır
      title: 'Firestore Chat Application', // Uygulama başlığı
      theme: ThemeData(primarySwatch: Colors.blue), // Uygulama temasını belirler
      home: WelcomeScreen(), // Uygulamanın açılış ekranını belirler
    );
  }
}
