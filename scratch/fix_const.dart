import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceAll(
    "const Text('💡 概率论破局真相',", 
    "Text('💡 概率论破局真相',"
  );
  
  content = content.replaceAll(
    "const Text(\n                              '传统单轨交易", 
    "Text(\n                              '传统单轨交易"
  );
  
  file.writeAsStringSync(content);
  print('Removed const from Text widgets');
}
