import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_list_screen.dart'; // Öğrenci listeleme ekranı
import 'academician_list_screen.dart'; // Akademisyen listeleme ekranı

class CourseListScreen extends StatelessWidget {
  final String userId; // Kullanıcı ID'si
  final String userType; // Kullanıcı tipi: "student" veya "academician"

  const CourseListScreen({super.key, required this.userId, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Seçtiğiniz Dersler",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF121E2D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Geri dön
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('selectedCourses')
            .doc(userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Henüz bir ders seçimi yapılmadı."));
          }

          List courses = snapshot.data!['courses'] ?? [];
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(courses[index]), // Ders adı
                leading: Icon(Icons.book, color: Colors.black), // İkon
                onTap: () {
                  // Kullanıcı tipine göre yönlendirme
                  if (userType == "student") {
                    // Öğrenci giriş yapmışsa akademisyeni göster
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AcademicianListScreen(
                          courseName: courses[index],
                          loggedInUserId: userId, // Burada `userId` ekleniyor
                        ),
                      ),
                    );
                  } else if (userType == "academician") {
                    // Akademisyen giriş yapmışsa öğrencileri göster
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentListScreen(
                          courseName: courses[index],
                          loggedInUserId: userId, // Burada `userId` ekleniyor
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
