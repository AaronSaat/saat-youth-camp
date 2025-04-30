// for coding purpose
// ini global function untuk print log kalo error

// jangan lupa di declare
// import '/utils/debug_log.dart';

void debugPrintCustom(dynamic message) {
  final lines = message.toString().split('\n');
  print('='.padRight(50, '='));
  for (var line in lines) {
    print(line);
  }
  print('='.padRight(50, '='));
}
