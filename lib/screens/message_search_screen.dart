import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore bağlantısı

// Mesaj arama ekranı için StatefulWidget
class SearchScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot> allMessages; // Tüm mesajlar
  final ScrollController scrollController; // Kaydırma kontrolcüsü

  const SearchScreen({super.key, 
    required this.allMessages,
    required this.scrollController,
  });

  @override
  _SearchScreenState createState() => _SearchScreenState(); // Durum sınıfı oluşturma
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController(); // Arama metin kontrolcüsü
  List<QueryDocumentSnapshot> filteredMessages = []; // Filtrelenmiş mesajlar listesi

  @override
  void initState() {
    super.initState();
    filteredMessages = widget.allMessages; // Başlangıçta tüm mesajları göster
  }

  // Gönderenin adını almak için Firestore sorguları
  Future<String> getSenderName(String senderId) async {
    try {
      // Öncelikle students koleksiyonunu kontrol et
      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(senderId)
          .get();

      if (studentDoc.exists) {
        return studentDoc['name'] ?? 'Bilinmeyen'; // Eğer isim bulunursa döndür
      }

      // Eğer students'ta bulunmazsa academicians koleksiyonunu kontrol et
      final academicianDoc = await FirebaseFirestore.instance
          .collection('academicians')
          .doc(senderId)
          .get();

      if (academicianDoc.exists) {
        return academicianDoc['name'] ?? 'Bilinmeyen'; // Eğer isim bulunursa döndür
      }

      // Eğer hiçbir koleksiyonda bulunmazsa "Bilinmeyen" döndür
      return 'Bilinmeyen';
    } catch (e) {
      print('Hata: $e'); // Hata durumunda log yaz
      return 'Bilinmeyen';
    }
  }

  // Mesajları filtreleme
  void filterMessages(String query) {
    setState(() {
      filteredMessages = widget.allMessages.where((message) {
        final content = (message.data() as Map<String, dynamic>)['message'] ?? '';
        return content.toLowerCase().contains(query.toLowerCase()); // Arama metnini kontrol et
      }).toList();
    });
  }

  // Belirli bir mesaja kaydırma
  void scrollToMessage(QueryDocumentSnapshot message) {
    final index = widget.allMessages.indexOf(message);
    if (index != -1) {
      widget.scrollController.animateTo(
        index * 80.0, // Mesaj boyutuna göre ayarla
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    Navigator.pop(context, message); // Ekranı kapat ve mesaja dön
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Modern arka plan rengi
      appBar: AppBar(
        backgroundColor: const Color(0xFF121E2D), // Başlık rengi
        title: TextField(
          controller: _searchController, // Arama metin kontrolcüsü
          onChanged: filterMessages, // Kullanıcı yazdıkça filtrele
          style: const TextStyle(color: Colors.white), // Beyaz yazı rengi
          decoration: const InputDecoration(
            hintText: 'Mesajlarda ara...', // Yer tutucu metin
            hintStyle: TextStyle(color: Colors.white70), // Gri yer tutucu rengi
            border: InputBorder.none, // Çerçeve yok
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white), // Kapatma ikonu
            onPressed: () {
              Navigator.pop(context); // Arama ekranını kapat
            },
          ),
        ],
      ),
      body: filteredMessages.isEmpty
          ? const Center(
        child: Text(
          'Eşleşen mesaj bulunamadı.', // Eğer filtre sonucu boşsa mesaj göster
          style: TextStyle(color: Colors.black54),
        ),
      )
          : ListView.builder(
        itemCount: filteredMessages.length, // Filtrelenmiş mesaj sayısı
        itemBuilder: (context, index) {
          final message = filteredMessages[index];
          final data = message.data() as Map<String, dynamic>;
          final senderId = data['senderId'] ?? ''; // Gönderen ID'si
          final messageContent = data['message'] ?? ''; // Mesaj metni

          return FutureBuilder<String>(
            future: getSenderName(senderId), // Gönderenin adını al
            builder: (context, snapshot) {
              final senderName = snapshot.data ?? 'Bilinmeyen'; // Gönderenin adı

              return GestureDetector(
                onTap: () {
                  scrollToMessage(message); // Mesaja kaydır
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Kutunun dış boşlukları
                  padding: const EdgeInsets.all(12), // Kutunun iç boşlukları
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF), // Beyaz arka plan
                    borderRadius: BorderRadius.circular(12), // Yuvarlatılmış köşeler
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12, // Hafif gölge
                        blurRadius: 5, // Gölge bulanıklığı
                        offset: Offset(0, 2), // Gölgenin ofseti
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName, // Gönderenin adı
                        style: const TextStyle(
                          color: Colors.black87, // Siyah yazı rengi
                          fontWeight: FontWeight.bold, // Kalın yazı
                          fontSize: 14, // Yazı boyutu
                        ),
                      ),
                      const SizedBox(height: 5), // Yazılar arası boşluk
                      Text(
                        messageContent, // Mesaj metni
                        style: const TextStyle(
                          color: Colors.black54, // Gri yazı rengi
                          fontSize: 14, // Yazı boyutu
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
