import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Import package color picker
import '../services/firebase_service.dart';

class CustomModePage extends StatefulWidget {
  const CustomModePage({super.key});

  @override
  State<CustomModePage> createState() => _CustomModePageState();
}

class _CustomModePageState extends State<CustomModePage> {
  final FirebaseService _firebaseService = FirebaseService();

  String effect = "rainbow";
  double speed = 50;
  Color selectedColor = Colors.blue;

  // Fungsi untuk membuka dialog color picker
  void _pickColorForCustomMode(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Warna Efek'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                selectedColor = color;
              },
              colorPickerWidth: 300,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: false,
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
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('PILIH'),
              onPressed: () {
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
    _firebaseService.setCurrentMode("custom");

    // Mulai mendengarkan perubahan data dari Firebase untuk Custom Mode
    _firebaseService.getCustomModeDataStream().listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          effect = data['effect'] ?? 'rainbow';
          speed = (data['speed'] ?? 50).toDouble();
          selectedColor = _colorFromHex(data['color'] ?? '#0000FF');
        });
      }
    });
  }

  // Fungsi helper untuk konversi warna
  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  void _saveToFirebase() async {
    // Konversi warna ke hex dengan padding yang aman
    String hexColor = '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase().padLeft(6, '0')}';

    try {
      await _firebaseService.updateCustomMode(
        effect: effect,
        speed: speed.toInt(),
        color: hexColor,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Efek berhasil disimpan!'), backgroundColor: Colors.green),
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
      appBar: AppBar(title: const Text("Custom Mode")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Ratakan teks ke kiri
          children: [
            const Text("Effect", style: TextStyle(fontSize: 18)),
            RadioListTile(
              title: const Text("Rainbow Cycle"),
              value: "rainbow",
              groupValue: effect,
              onChanged: (v) => setState(() => effect = v!),
            ),
            RadioListTile(
              title: const Text("Pulse Cycle Flow"),
              value: "pulse",
              groupValue: effect,
              onChanged: (v) => setState(() => effect = v!),
            ),
            RadioListTile(
              title: const Text("Neon Alternating Blink"),
              value: "blink",
              groupValue: effect,
              onChanged: (v) => setState(() => effect = v!),
            ),

            const SizedBox(height: 20),

            const Text("Speed", style: TextStyle(fontSize: 18)),
            Text("Speed: ${speed.toInt()}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Slider(
              min: 0,
              max: 100,
              value: speed,
              onChanged: (v) => setState(() => speed = v),
            ),

            const SizedBox(height: 40),

            const Text("Color", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 15),
            // Ganti Wrap dengan GestureDetector untuk membuka picker
            GestureDetector(
              onTap: () => _pickColorForCustomMode(context),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: const Center(
                  child: Text(
                    'Klik untuk memilih warna efek',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
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
              child: const Text("APPLY EFFECT"),
            ),
          ],
        ),
      ),
    );
  }
}