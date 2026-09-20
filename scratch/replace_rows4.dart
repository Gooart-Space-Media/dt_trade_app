import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();
  
  List<int> targetLines = [2581, 2770];
  
  for (int i in targetLines) {
    if (lines[i].contains('Row(') && lines[i+1].contains('mainAxisAlignment: MainAxisAlignment.spaceBetween,')) {
      lines[i] = lines[i].replaceFirst('Row(', 'Wrap(');
      lines[i+1] = lines[i+1].replaceFirst('mainAxisAlignment: MainAxisAlignment.spaceBetween,', 'alignment: WrapAlignment.spaceBetween, runSpacing: 6,');
    }
  }
  
  file.writeAsStringSync(lines.join('\n'));
  print('Replaced more Rows!');
}
