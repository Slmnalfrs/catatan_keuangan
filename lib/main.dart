import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVvY3d6bmx2a2RoZWh4aGltaHpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NDI5NTAsImV4cCI6MjA2MzIxODk1MH0.ZalkBAJyeXfO-dlyF-TpmHUCYdYnU2xzm58QXtES7xk';

Future<void> main() async {
  await Supabase.initialize( 
    url: 'https://uocwznlvkdhehxhimhzd.supabase.co',
    anonKey: supabaseKey,
  );
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
