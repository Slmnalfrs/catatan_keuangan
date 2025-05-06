import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(CatatanKeuanganApp());
}

class CatatanKeuanganApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Keuangan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}
