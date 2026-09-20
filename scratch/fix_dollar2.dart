import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  String code = file.readAsStringSync();
  
  code = code.replaceAll(r'0.1$', r'0.1\$');
  
  file.writeAsStringSync(code);
  print('Fixed dollar signs!');
}
