class GlobalVariables {
  // static const String serverUrl = 'https://reg.seabs.ac.id/';
  static const String serverUrl = 'http://172.172.52.11:90/';
  static int currentIndex = 0; // Untuk BottomNavigationBar main_screen.dart
}

// Contoh penggunaan di file lain:
// import 'package:syc_mobile/utils/global_variables.dart';
//
// void fetchData() {
//   final url = GlobalVariables.baseurl + 'endpoint';
//   // Gunakan url untuk request API
// }
