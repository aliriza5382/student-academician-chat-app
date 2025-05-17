import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore bağlantısı
import 'message_search_screen.dart'; // Mesaj arama ekranı

// Mesaj ekranı için StatefulWidget
class MessageScreen extends StatefulWidget {
  final String loggedInUserId; // Gönderenin ID'si
  final String receiverId; // Alıcının ID'si
  final String receiverName; // Alıcının adı

  const MessageScreen({super.key, 
    required this.loggedInUserId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  _MessageScreenState createState() => _MessageScreenState(); // Durum sınıfı
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController(); // Mesaj giriş kontrolcüsü
  final ScrollController _scrollController = ScrollController(); // Scroll için kontrol
  late List<QueryDocumentSnapshot> allMessages; // Tüm mesajlar

  String? _repliedMessageId; // Cevaplanan mesajın ID'si
  String? _repliedMessageText; // Cevaplanan mesaj metni
  String? _repliedMessageSenderId; // Cevaplanan mesajın gönderen ID'si

  String? highlightedMessageId; // Vurgulanan mesajın ID'si

  // Mesajı vurgulama
  void highlightMessage(String messageId) {
    setState(() {
      highlightedMessageId = messageId; // Vurgulanan mesaj ID'si
    });

    // 1 saniye sonra vurguyu kaldır
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        highlightedMessageId = null;
      });
    });
  }

  // Emoji listesi
  final List<String> _emojis = [
    '😀', '😁', '😂', '🥰', '😍', '😎', '😢', '👍', '👏', '🙏',
    '🎉', '🔥', '💖', '🎈', '🙌', '😘', '😜', '🤔', '🤩', '😭'
  ];

  @override
  void initState() {
    super.initState();
    fetchMessages(); // Mesajları çek
  }

  // Mesajları Firestore'dan çek
  Future<void> fetchMessages() async {
    final messages = await FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timeStamp', descending: true)
        .get();

    setState(() {
      allMessages = messages.docs.where((doc) {
        final data = doc.data();
        final senderId = data['senderId'];
        final receiverId = data['receiverId'];
        return (senderId == widget.loggedInUserId &&
            receiverId == widget.receiverId) ||
            (senderId == widget.receiverId &&
                receiverId == widget.loggedInUserId);
      }).toList();
    });
  }

  // Mesaja kaydır
  void scrollToMessage(QueryDocumentSnapshot message) {
    final index = allMessages.indexOf(message);
    if (index != -1) {
      _scrollController.animateTo(
        index * 80.0, // Mesaj yüksekliğine göre
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ).then((_) {
        setState(() {
          highlightedMessageId = message.id; // Mesaj vurgulandı
        });

        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            highlightedMessageId = null; // Vurguyu kaldır
          });
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mesaj bulunamadı.'), // Hata mesajı
        ),
      );
    }
  }

  // Emoji panelini göster
  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // Satırdaki emoji sayısı
            childAspectRatio: 1.5, // Emoji kutusu oranı
          ),
          itemCount: _emojis.length, // Toplam emoji sayısı
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _messageController.text += _emojis[index]; // Emoji ekle
                });
                Navigator.pop(context); // Paneli kapat
              },
              child: Center(
                child: Text(
                  _emojis[index],
                  style: TextStyle(fontSize: 24), // Emoji boyutu
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Mesaj gönderme
  Future<void> sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Kullanıcı engel kontrolü
    final blockedDoc = await FirebaseFirestore.instance
        .collection('blockedStudents')
        .doc(widget.receiverId)
        .get();

    if (blockedDoc.exists) {
      final blockedList = List<String>.from(blockedDoc['blocked'] ?? []);
      if (blockedList.contains(widget.loggedInUserId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bu kullanıcı sizi engellediği için mesaj gönderemezsiniz.'), // Engel mesajı
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Mesaj Firestore'a ekle
    await FirebaseFirestore.instance.collection('messages').add({
      'message': message,
      'senderId': widget.loggedInUserId,
      'receiverId': widget.receiverId,
      'repliedMessageId': _repliedMessageId,
      'repliedMessageText': _repliedMessageText,
      'repliedMessageSenderId': _repliedMessageSenderId,
      'likes': [], // Beğeniler
      'timeStamp': DateTime.now().toIso8601String(), // Zaman damgası
    });

    setState(() {
      _repliedMessageId = null;
      _repliedMessageText = null;
      _repliedMessageSenderId = null;
    });

    _messageController.clear(); // Mesaj kutusunu temizle
  }

  // Mesaj beğenme işlemi
  Future<void> toggleLike(String messageId, List likes, String senderId) async {
    if (senderId == widget.loggedInUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kendi mesajınızı beğenemezsiniz.'), // Uyarı mesajı
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isLiked = likes.contains(widget.loggedInUserId);

    await FirebaseFirestore.instance.collection('messages').doc(messageId).update({
      'likes': isLiked
          ? FieldValue.arrayRemove([widget.loggedInUserId]) // Beğeniyi kaldır
          : FieldValue.arrayUnion([widget.loggedInUserId]), // Beğeni ekle
      'likedBy': isLiked ? null : widget.loggedInUserId, // Beğenen kullanıcı kaydı
    });
  }

  // Mesaj silme işlemi
  Future<void> deleteMessage(String messageId) async {
    await FirebaseFirestore.instance.collection('messages').doc(messageId).delete();
  }

  // Mesaj silme onayı
  void confirmDeleteMessage(String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mesajı Sil'), // Başlık
          content: Text('Bu mesajı silmek istediğinizden emin misiniz?'), // Açıklama
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal', style: TextStyle(color: Colors.black)), // İptal butonu
            ),
            TextButton(
              onPressed: () {
                deleteMessage(messageId); // Mesajı sil
                Navigator.of(context).pop();
              },
              child: Text('Sil', style: TextStyle(color: Colors.red)), // Sil butonu
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Arka plan rengi
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), // Başlık rengi
        title: Text(
          widget.receiverName, // Alıcı adı
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search), // Arama ikonu
            onPressed: () async {
              final selectedMessage = await Navigator.push<QueryDocumentSnapshot?>(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    allMessages: allMessages,
                    scrollController: _scrollController,
                  ),
                ),
              );

              if (selectedMessage != null) {
                final messageId = selectedMessage.id;
                highlightMessage(messageId); // Mesajı vurgula
                final index = allMessages.indexOf(selectedMessage);
                if (index != -1) {
                  _scrollController.animateTo(
                    index * 80.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              }
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_repliedMessageText != null)
            Container(
              color: Colors.grey.shade300,
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Cevaplanan: $_repliedMessageText',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _repliedMessageId = null;
                        _repliedMessageText = null;
                        _repliedMessageSenderId = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timeStamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final senderId = data['senderId'];
                  final receiverId = data['receiverId'];
                  return (senderId == widget.loggedInUserId &&
                      receiverId == widget.receiverId) ||
                      (senderId == widget.receiverId &&
                          receiverId == widget.loggedInUserId);
                }).toList();

                return ListView.builder(
                  reverse: true, // Son mesajdan başla
                  controller: _scrollController, // Scroll kontrolü
                  itemCount: messages.length, // Mesaj sayısı
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final data = message.data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == widget.loggedInUserId; // Gönderen kontrolü
                    final likes = List.from(data['likes'] ?? []); // Beğeniler

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _repliedMessageId = message.id; // Cevaplanan mesaj ID'si
                          _repliedMessageText = data['message']; // Mesaj metni
                          _repliedMessageSenderId = data['senderId']; // Gönderen ID'si
                        });
                      },
                      onLongPress: isMe
                          ? () => confirmDeleteMessage(message.id) // Uzun basınca sil
                          : null,
                      child: Align(
                        alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft, // Hizalama
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: message.id == highlightedMessageId
                                ? Colors.yellow.withOpacity(0.5) // Vurgulu mesaj arka plan
                                : isMe
                                ? const Color(0xFF121E2D) // Gönderen rengi
                                : const Color(0xFFFFCC00), // Alıcı rengi
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                              bottomLeft: isMe ? Radius.circular(15) : Radius.zero,
                              bottomRight: isMe ? Radius.zero : Radius.circular(15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data['repliedMessageText'] != null)
                                Container(
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    data['repliedMessageSenderId'] ==
                                        widget.loggedInUserId
                                        ? 'Cevaplanan (Kendi): ${data['repliedMessageText']}'
                                        : 'Cevaplanan: ${data['repliedMessageText']}',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  ),
                                ),
                              Text(
                                data['message'], // Mesaj metni
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black, // Renk
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => toggleLike(
                                      message.id,
                                      likes,
                                      data['senderId'], // Gönderenin ID'si
                                    ),
                                    child: Icon(
                                      likes.contains(widget.loggedInUserId)
                                          ? Icons.favorite // Beğenildi
                                          : Icons.favorite_border, // Beğenilmedi
                                      color: likes.contains(widget.loggedInUserId)
                                          ? Colors.red // Beğeni rengi
                                          : Colors.black54, // Normal renk
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text('${likes.length}'), // Beğeni sayısı
                                  if (data['likedBy'] == widget.receiverId) // Karşı taraf beğendi
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        'Mesajınız beğenildi', // Beğeni mesajı
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.green),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            color: const Color(0xFFEEEEEE),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.emoji_emotions, color: Colors.orange), // Emoji butonu
                  onPressed: _showEmojiPicker, // Emoji panelini göster
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController, // Mesaj kontrolcüsü
                    decoration: InputDecoration(
                      labelText: 'Mesaj Yaz', // Etiket
                      labelStyle: TextStyle(color: const Color(0xFF121E2D)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25), // Çerçeve köşeleri
                        borderSide: BorderSide(color: const Color(0xFF121E2D)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: const Color(0xFF121E2D)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: const Color(0xFF121E2D)), // Gönder butonu
                  onPressed: sendMessage, // Mesaj gönder
                  iconSize: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
