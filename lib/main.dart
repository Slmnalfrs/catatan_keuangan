import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://yfzudzewogsvneziwfzd.supabase.co';
const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmenVkemV3b2dzdm5leml3ZnpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg4MjU0MTAsImV4cCI6MjA2NDQwMTQxMH0.ysuXN4NqruVVxxwmnGdmMfvarUeL8NMh6bdQltD2HB4';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  
  runApp(CatatanKeuanganApp());
}

class CatatanKeuanganApp extends StatelessWidget {
  const CatatanKeuanganApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Keuangan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}