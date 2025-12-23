import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/led_controller_page.dart';
import 'pages/custom_mode_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Gunakan blok try-catch untuk inisialisasi Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Ini biasanya terjadi saat Hot Restart.
    if (e.toString().contains('duplicate-app')) {
      print('Firebase app already exists. Skipping initialization.');
    } else {
      // Jika error lainnya, tampilkan errornya.
      print('Failed to initialize Firebase: $e');
    }
  }

  runApp(const MyApp());
}

// ... sisanya kode MyApp, HomeScreen, dll tidak berubah
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Controller',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final List<Widget> _pages = const [
    LEDControlPage(),
    CustomModePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: "Main Mode",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: "Custom Mode",
          ),
        ],
      ),
    );
  }
}