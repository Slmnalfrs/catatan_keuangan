import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan Keuangan'),
      ),
      body: Center(
        child: Text(
          'Selamat datang di Catatan Keuangan!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
