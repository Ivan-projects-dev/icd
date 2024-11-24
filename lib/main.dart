import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ICDScreen(),
    );
  }
}

class ICDScreen extends StatefulWidget {
  @override
  _ICDScreenState createState() => _ICDScreenState();
}

class _ICDScreenState extends State<ICDScreen> {
  Map<String, String> _icdData = {};
  String _selectedLanguage = 'ru';

  @override
  void initState() {
    super.initState();
    _loadICDData();
  }

  Future<void> _loadICDData() async {
    try {
      // Загрузка данных из файла JSON
      final String data =
          await rootBundle.loadString('assets/icd_$_selectedLanguage.json');
      setState(() {
        _icdData = Map<String, String>.from(json.decode(data));
      });
    } catch (e) {
      // Логирование ошибок, если файл не найден или содержит ошибку
      print('Ошибка загрузки JSON: $e');
      setState(() {
        _icdData = {
          "Ошибка": "Не удалось загрузить данные для выбранного языка"
        };
      });
    }
  }

  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    _loadICDData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('МКБ - ${_selectedLanguage.toUpperCase()}'),
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            onChanged: (value) {
              if (value != null) _changeLanguage(value);
            },
            items: [
              DropdownMenuItem(value: 'ru', child: Text('Русский')),
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'lv', child: Text('Latviešu')),
            ],
          ),
        ],
      ),
      body: _icdData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _icdData.length,
              itemBuilder: (context, index) {
                final code = _icdData.keys.elementAt(index);
                final name = _icdData[code];
                return ListTile(
                  title: Text('$code: $name'),
                );
              },
            ),
    );
  }
}
