import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Import package baru
import '../services/firebase_service.dart';

class LEDControlPage extends StatefulWidget {
  const LEDControlPage({super.key});

  @override
  State<LEDControlPage> createState() => _LEDControlPageState();
}

class _LEDControlPageState extends State<LEDControlPage> {
  final FirebaseService _firebaseService = FirebaseService();

  bool ledStatus = true;
  double brightness = 100;
  Color selectedColor = Colors.white; // Warna default bisa Anda ubah

  // Fungsi untuk membuka dialog color picker
  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Warna LED'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor, // Warna yang dipilih saat ini
              onColorChanged: (Color color) {
                // Callback saat warna diubah di picker
                selectedColor = color;
              },
              // Tampilkan beberapa warna preset untuk kemudahan
              colorPickerWidth: 300,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: false, // Nonaktifkan transparansi
              displayThumbColor: true,
              paletteType: PaletteType.hsv,
              labelTypes: const <ColorLabelType>[
                ColorLabelType.hsv,
                ColorLabelType.rgb,
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('BATAL'),
              onPressed: () {
                // Tutup dialog tanpa menyimpan perubahan
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('PILIH'),
              onPressed: () {
                // Tutup dialog dan update state dengan warna baru
                setState(() {
                      // selectedColor sudah diperbarui di onColorChanged
                    });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _firebaseService.setCurrentMode("main");
    
    // Mendengarkan perubahan data dari Firebase
    _firebaseService.getMainModeDataStream().listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          ledStatus = data['status'] == 'on';
          brightness = (data['brightness'] ?? 0).toDouble();
          selectedColor = _colorFromHex(data['color'] ?? '#FF0000');
        });
      }
    });
  }

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  void _saveToFirebase() async {
    String hexColor = '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase().padLeft(6, '0')}';

    try {
      await _firebaseService.updateMainMode(
        status: ledStatus ? "on" : "off",
        brightness: brightness.toInt(),
        color: hexColor,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Main Mode")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // status switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("LED Status", style: TextStyle(fontSize: 18)),
                Switch(
                  value: ledStatus,
                  onChanged: (v) => setState(() => ledStatus = v),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // brightness slider
            Text("Brightness: ${brightness.toInt()}", style: const TextStyle(fontSize: 18)),
            Slider(
              min: 0,
              max: 255,
              value: brightness,
              onChanged: (v) => setState(() => brightness = v),
            ),
            const SizedBox(height: 40), // Tambah jarak vertikal
            // color selection
            const Text("Color", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 15), // Tambah jarak vertikal
            // Ganti Wrap dengan GestureDetector untuk membuka picker
            GestureDetector(
              onTap: () => _pickColor(context),
              child: Container(
                width: double.infinity, // Buat selebar mungkin
                height: 60,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: const Center(
                  child: Text(
                    'Klik untuk memilih warna',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow( // Tambah bayangan agar teks terbaca di warna terang
                          color: Colors.black,
                          offset: Offset(0.5, 0.5),
                          blurRadius: 2.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveToFirebase,
              child: const Text("SAVE TO FIREBASE"),
            ),
          ],
        ),
      ),
    );
  }
}