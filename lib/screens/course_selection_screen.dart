import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseSelectionScreen extends StatefulWidget {
  final String userId;
  final String userType; // "student" veya "academician"

  const CourseSelectionScreen({super.key, required this.userId, required this.userType});

  @override
  _CourseSelectionScreenState createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  List<String> courses = [
    "AVP",
    "OOP",
    "GOR",
    "VERİ.Y",
    "VERİ.T",
    "WEB",
    "Bilgisayar Bilimi",
    "MOBİL",
    "MAT"
  ]; // Örnek ders listesi
  List<String> selectedCourses = []; // Kullanıcının seçtiği dersler

  void saveCourses() async {
    await FirebaseFirestore.instance
        .collection('selectedCourses')
        .doc(widget.userId)
        .set({
      'userType': widget.userType,
      'userId': widget.userId,
      'courses': selectedCourses,
    });

    // Başarı mesajı göster ve ana ekrana dön
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ders seçimleriniz başarıyla kaydedildi.')),
    );

    Navigator.pop(context); // Geri dön
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userType == "student"
            ? "Alacağınız Dersleri Seçin"
            : "Vereceğiniz Dersleri Seçin", style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF121E2D),
      ),
      body: ListView(
        children: courses.map((course) {
          return CheckboxListTile(
            title: Text(course),
            value: selectedCourses.contains(course),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedCourses.add(course);
                } else {
                  selectedCourses.remove(course);
                }
              });
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveCourses,
        backgroundColor: const Color(0xFFFFCC00),
        child: const Icon(Icons.save, color: Colors.black),
      ),
    );
  }
}
