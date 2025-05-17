import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'group_message_screen.dart';

// Grupları listelemek için ekran
class GroupListScreen extends StatelessWidget {
  final String loggedInUserId; // Giriş yapan kullanıcının ID'si
  final bool isAcademician; // Kullanıcının akademisyen olup olmadığını belirten bilgi

  const GroupListScreen({
    required this.loggedInUserId,
    required this.isAcademician,
    super.key,
  });

  // Grup silme işlemi
  void deleteGroup(BuildContext context, String groupId) async {
    try {
      // 1. Gruba ait mesajları sil
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('groupMessages') // Grup mesajları koleksiyonu
          .where('groupId', isEqualTo: groupId) // Grup ID'sine göre filtreleme
          .get();

      for (var doc in messagesSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('groupMessages') // Grup mesajları koleksiyonu
            .doc(doc.id) // Mesajın ID'sine göre silme
            .delete();
      }

      // 2. Grubu sil
      await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Grup ve mesajları başarıyla silindi.")), // Başarı mesajı
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Grup silinirken hata oluştu: $e")), // Hata mesajı
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gruplar", // Ekran başlığı
          style: TextStyle(color: Colors.white),
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
            .collection('groups') // Gruplar koleksiyonu
            .where('members', arrayContains: loggedInUserId) // Kullanıcının üye olduğu gruplar
            .snapshots(), // Anlık veri akışı
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Yükleniyor göstergesi
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Henüz dahil olduğunuz bir grup bulunmamaktadır."), // Grup yok mesajı
            );
          }

          final groups = snapshot.data!.docs; // Gruplar listesi

          return ListView.builder(
            itemCount: groups.length, // Grup sayısı
            itemBuilder: (context, index) {
              final group = groups[index]; // Grup bilgisi
              final groupName = group['name']; // Grup adı
              final createdBy = group['createdBy']; // Grubu oluşturan kullanıcı

              return ListTile(
                title: Text(groupName), // Grup adı
                trailing: loggedInUserId == createdBy
                    ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red), // Silme ikonu
                  onPressed: () => deleteGroup(context, group.id), // Silme işlemi
                )
                    : null,
                onTap: () {
                  // Grup mesajları ekranına yönlendirme
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupMessageScreen(
                        groupId: group.id, // Grup ID'si
                        groupName: groupName, // Grup adı
                        loggedInUserId: loggedInUserId, // Giriş yapan kullanıcının ID'si
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: isAcademician // Sadece akademisyenler grup oluşturabilir
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF121E2D), // Buton arka plan rengi
        onPressed: () => createGroup(context, loggedInUserId), // Grup oluşturma işlemi
        child: const Icon(Icons.group_add, color: Colors.white), // Grup oluşturma ikonu
      )
          : null,
    );
  }

  // Grup oluşturma işlemi
  Future<void> createGroup(BuildContext context, String creatorId) async {
    String groupName = ""; // Grup adı
    List<String> selectedMembers = []; // Seçilen üyeler listesi

    // Öğrencileri çek
    final students = await FirebaseFirestore.instance.collection('students').get();
    // Akademisyenleri çek
    final academicians = await FirebaseFirestore.instance.collection('academicians').get();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Grup Oluştur"), // Grup oluşturma başlığı
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: "Grup Adı"), // Grup adı girişi
                      onChanged: (value) {
                        groupName = value; // Grup adı güncelleme
                      },
                    ),
                    const Divider(), // Bölme çizgisi
                    const Text("Üyeleri Seç"), // Üye seçimi başlığı
                    ...students.docs.map((student) {
                      return CheckboxListTile(
                        title: Text(student['name']), // Öğrenci adı
                        value: selectedMembers.contains(student.id), // Seçim durumu
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              selectedMembers.add(student.id); // Öğrenci ekleme
                            } else {
                              selectedMembers.remove(student.id); // Öğrenci çıkarma
                            }
                          });
                        },
                      );
                    }),
                    ...academicians.docs
                        .where((academic) => academic.id != creatorId) // Oluşturucu hariç
                        .map((academic) {
                      return CheckboxListTile(
                        title: Text(academic['name']), // Akademisyen adı
                        value: selectedMembers.contains(academic.id), // Seçim durumu
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              selectedMembers.add(academic.id); // Akademisyen ekleme
                            } else {
                              selectedMembers.remove(academic.id); // Akademisyen çıkarma
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // İptal
                  child: const Text("İptal"),
                ),
                TextButton(
                  onPressed: () async {
                    if (groupName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Grup adı boş olamaz!")), // Uyarı mesajı
                      );
                      return;
                    }

                    if (selectedMembers.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Oluşturucu dahil en az 3 kişi olmalı!")), // Uyarı mesajı
                      );
                      return;
                    }

                    // Grup oluşturma işlemi
                    await FirebaseFirestore.instance.collection('groups').add({
                      'name': groupName, // Grup adı
                      'members': [creatorId, ...selectedMembers], // Üyeler
                      'restrictedMembers': [], // Kısıtlı üyeler
                      'createdBy': creatorId, // Oluşturan kullanıcı
                      'timeStamp': DateTime.now(), // Oluşturma zamanı
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Grup başarıyla oluşturuldu!")), // Başarı mesajı
                    );

                    Navigator.of(context).pop(); // Dialog kapatma
                  },
                  child: const Text("Oluştur"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
