import 'package:flutter/material.dart';
import 'login_screen.dart'; // Login ekranını bağlama

// Uygulamanın başlangıç ekranı
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF273745), // Koyu gri arka plan rengi
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // İçeriği dikey olarak ortalar
        children: [
          // Logo ve üst tasarım
          Center(
            child: Image.asset(
              'assets/ArkaPlan/arka_plan_ilk.png', // Görsel dosyasının yolu
              fit: BoxFit.contain, // Görselin kapsama modu
              width: 750, // Görselin genişliği
              height: 650, // Görselin yüksekliği
            ),
          ),
          SizedBox(height: 40), // Görsel ile buton arasındaki boşluk
          // "Hoşgeldiniz" butonu
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFCC00), // Altın sarısı buton rengi
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25), // Yuvarlatılmış köşeler
              ),
              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20), // Buton iç dolgu ayarı
            ),
            onPressed: () {
              // Login ekranına yönlendirme
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()), // LoginScreen ekranına geçiş
              );
            },
            child: Text(
              'Hoşgeldiniz', // Buton üzerindeki yazı
              style: TextStyle(
                fontSize: 20, // Yazı boyutu
                fontWeight: FontWeight.bold, // Kalın yazı stili
                color: const Color(0xFF121E2D), // Koyu mavi yazı rengi
              ),
            ),
          ),
        ],
      ),
    );
  }
}
