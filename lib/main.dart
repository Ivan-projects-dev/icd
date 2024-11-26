import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English
        const Locale('ru', ''), // Russian
        const Locale('lv', ''), // Latvian
      ],
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
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
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadICDData();
  }

  Future<void> _loadICDData() async {
    try {
      final String data =
          await rootBundle.loadString('assets/icd_$_selectedLanguage.json');
      final parsedData = await compute(_parseJson, data);
      setState(() => _icdData = parsedData);
    } catch (e) {
      _showError('Ошибка загрузки данных: $e');
      setState(() => _icdData = {});
    }
  }

  static Map<String, String> _parseJson(String jsonString) =>
      Map<String, String>.from(json.decode(jsonString));

  void _changeLanguage(String languageCode) {
    setState(() => _selectedLanguage = languageCode);
    _loadICDData();
  }

  void _showError(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final filteredICDData = _icdData.entries
        .where((entry) =>
            entry.key.contains(_searchQuery) ||
            entry.value.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.0),
        child: AppBar(
          backgroundColor: Colors.red,
          centerTitle: true,
          title: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) => setState(() => _searchQuery = query),
                  decoration: InputDecoration(
                    hintText: 'Поиск...',
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                  cursorColor: Colors.blue,
                ),
              ),
              SizedBox(width: 10), // Отступ между строкой поиска и меню
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  onChanged: (value) {
                    if (value != null) _changeLanguage(value);
                  },
                  icon: SizedBox.shrink(), // Убираем иконку раскрытия
                  dropdownColor: Colors.white, // Цвет выпадающего меню
                  items: [
                    DropdownMenuItem(value: 'ru', child: Text('Русский')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'lv', child: Text('Latviešu')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: filteredICDData.isEmpty
                ? Center(
                    child: _icdData.isEmpty
                        ? CircularProgressIndicator()
                        : Text('Ничего не найдено'),
                  )
                : ListView.builder(
                    itemCount: filteredICDData.length,
                    itemBuilder: (context, index) {
                      final code = filteredICDData[index].key;
                      final name = filteredICDData[index].value;
                      return ListTile(title: Text('$code: $name'));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
