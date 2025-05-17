import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore bağlantısı için gerekli paket

// Grup mesaj ekranı için StatefulWidget
class GroupMessageScreen extends StatefulWidget {
  final String groupId; // Grup ID'si
  final String groupName; // Grup adı
  final String loggedInUserId; // Oturum açmış kullanıcının ID'si

  const GroupMessageScreen({
    required this.groupId,
    required this.groupName,
    required this.loggedInUserId,
    super.key,
  });

  @override
  _GroupMessageScreenState createState() => _GroupMessageScreenState(); // Durum sınıfı
}

class _GroupMessageScreenState extends State<GroupMessageScreen> {
  final TextEditingController _messageController = TextEditingController(); // Mesaj giriş kontrolcüsü

  /// Kullanıcı adını Firestore'dan alır
  Future<String> fetchUserName(String userId) async {
    String? userName;

    try {
      var studentSnapshot = await FirebaseFirestore.instance
          .collection('students') // Öğrenci koleksiyonunu kontrol et
          .doc(userId)
          .get();

      if (studentSnapshot.exists) {
        userName = studentSnapshot['name']; // Öğrenci adı
      } else {
        var academicianSnapshot = await FirebaseFirestore.instance
            .collection('academicians') // Akademisyen koleksiyonunu kontrol et
            .doc(userId)
            .get();

        if (academicianSnapshot.exists) {
          userName = academicianSnapshot['name']; // Akademisyen adı
        }
      }
    } catch (e) {
      print("fetchUserName hatası: $e"); // Hata durumunda log yaz
    }

    return userName ?? "Bilinmeyen Kullanıcı"; // Kullanıcı adı bulunamazsa varsayılan değer
  }

  /// Mesaj gönderme işlemi
  Future<void> sendMessage() async {
    final message = _messageController.text.trim(); // Mesaj metni
    if (message.isEmpty) return; // Mesaj boşsa işlem yapma

    try {
      final senderName = await fetchUserName(widget.loggedInUserId); // Gönderenin adını al

      // Grubu yöneticisinin kim olduğunu kontrol et
      final groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();
      final String createdBy = groupSnapshot['createdBy']; // Grup yöneticisi ID'si

      String displayName = senderName;
      if (widget.loggedInUserId == createdBy) {
        displayName += " (Yönetici)"; // Yönetici etiketi ekle
      }

      // Mesajı Firestore'a ekle
      await FirebaseFirestore.instance.collection('groupMessages').add({
        'groupId': widget.groupId,
        'senderId': widget.loggedInUserId,
        'senderName': displayName,
        'message': message,
        'timeStamp': FieldValue.serverTimestamp(), // Zaman damgası
      });

      _messageController.clear(); // Mesaj giriş alanını temizle
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mesaj gönderilemedi: $e")), // Hata mesajı
      );
    }
  }

  /// Grup üyelerini gösterme işlemi
  void showGroupMembers() async {
    try {
      final groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      final memberIds = List<String>.from(groupSnapshot['members']); // Üye ID'leri
      final String createdBy = groupSnapshot['createdBy']; // Grup yöneticisi ID'si
      List<String> memberNames = [];

      for (String memberId in memberIds) {
        String name = await fetchUserName(memberId); // Üye adını al
        if (memberId == createdBy) {
          name += " (Yönetici)"; // Yönetici etiketi ekle
        }
        memberNames.add(name);
      }

      // Grup üyelerini dialog içinde göster
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Grup Üyeleri"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: memberNames.map((name) => Text(name)).toList(), // Üye adlarını listele
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Dialog'u kapat
              child: const Text("Kapat"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Grup üyeleri gösterilirken hata oluştu: $e"); // Hata durumunda log yaz
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName), // Grup adı başlık olarak gösterilir
        actions: [
          IconButton(
            icon: const Icon(Icons.group), // Grup üyelerini gösterme ikonu
            onPressed: showGroupMembers, // Üye gösterme işlemi
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groupMessages') // Mesajlar koleksiyonu
            .where('groupId', isEqualTo: widget.groupId) // Grup ID'sine göre filtrele
            .orderBy('timeStamp', descending: true) // Mesajları tarihe göre sırala
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Yükleniyor göstergesi
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Henüz mesaj bulunmamaktadır.")); // Mesaj yok mesajı
          }

          final messages = snapshot.data!.docs; // Mesajlar listesi

          return ListView.builder(
            reverse: true, // Mesajları sondan başlat
            itemCount: messages.length, // Mesaj sayısı
            itemBuilder: (context, index) {
              final data = messages[index]; // Mesaj verisi
              final timeStamp = data['timeStamp'] as Timestamp?;
              final time = timeStamp != null
                  ? timeStamp.toDate().toString() // Zamanı formatla
                  : "Bilinmeyen Zaman"; // Zaman yoksa varsayılan değer

              return ListTile(
                title: Text("${data['senderName']}: ${data['message']}"), // Gönderen ve mesaj
                subtitle: Text(time, style: TextStyle(color: Colors.grey)), // Zaman bilgisi
              );
            },
          );
        },
      ),
      // Mesaj gönderme bölümü
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController, // Mesaj giriş alanı kontrolcüsü
                decoration: const InputDecoration(hintText: "Mesaj Yaz..."), // Yer tutucu metin
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send), // Gönderme ikonu
              onPressed: sendMessage, // Mesaj gönderme işlemi
            ),
          ],
        ),
      ),
    );
  }
}
