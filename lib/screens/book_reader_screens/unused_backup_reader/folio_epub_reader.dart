// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vocsy_epub_viewer/epub_viewer.dart';

// class EpubReaderScreen extends StatefulWidget {
//   final String filePath;
//   final String bookTitle;

//   const EpubReaderScreen({
//     super.key,
//     required this.filePath,
//     required this.bookTitle,
//   });

//   @override
//   State<EpubReaderScreen> createState() => _EpubReaderScreenState();
// }

// class _EpubReaderScreenState extends State<EpubReaderScreen> {
//   EpubLocator? _lastLocation;
//   bool _nightMode = false;
//   double _fontSize = 16.0;
//   String _fontFamily = 'Serif';

//   @override
//   void initState() {
//     super.initState();
//     _loadPreferences().then((_) {
//       _openEpub(); // Automatically open the EPUB reader after loading preferences
//     });
//   }

//   Future<void> _loadPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _nightMode = prefs.getBool('nightMode') ?? false;
//       _fontSize = prefs.getDouble('fontSize') ?? 16.0;
//       _fontFamily = prefs.getString('fontFamily') ?? 'Serif';
//       String? locationJson = prefs.getString('lastLocation');
//       if (locationJson != null) {
//         _lastLocation = EpubLocator.fromJson(jsonDecode(locationJson));
//       }
//     });
//   }

//   Future<void> _savePreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setBool('nightMode', _nightMode);
//     prefs.setDouble('fontSize', _fontSize);
//     prefs.setString('fontFamily', _fontFamily);
//     if (_lastLocation != null) {
//       prefs.setString('lastLocation', jsonEncode(_lastLocation!.toJson()));
//     }
//   }

//   void _openEpub() {
//     VocsyEpub.setConfig(
//       themeColor: Theme.of(context).primaryColor,
//       identifier: widget.bookTitle,
//       scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
//       allowSharing: false,
//       enableTts: true,
//       nightMode: _nightMode,
//       // sepiaMode: !_nightMode,
//     );

//     VocsyEpub.locatorStream.listen((locator) {
//       setState(() {
//         _lastLocation = EpubLocator.fromJson(jsonDecode(locator));
//       });
//       _savePreferences();
//     });

//     VocsyEpub.open(
//       widget.filePath,
//       lastLocation: _lastLocation,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:
//             Text("hello"),
//       ),
//       body:
//           Container(),
//     );
//   }
// }
