import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();
  
  for (int i = 4800; i < 6000; i++) {
    if (lines[i].contains('Row(')) {
      if (lines[i+1].contains('mainAxisAlignment: MainAxisAlignment.spaceBetween,')) {
        lines[i] = lines[i].replaceFirst('Row(', 'Wrap(');
        lines[i+1] = lines[i+1].replaceFirst('mainAxisAlignment: MainAxisAlignment.spaceBetween,', 'alignment: WrapAlignment.spaceBetween, runSpacing: 6,');
      } else if (lines[i+1].contains('mainAxisAlignment: MainAxisAlignment.spaceAround,')) {
        lines[i] = lines[i].replaceFirst('Row(', 'Wrap(');
        lines[i+1] = lines[i+1].replaceFirst('mainAxisAlignment: MainAxisAlignment.spaceAround,', 'alignment: WrapAlignment.spaceAround, runSpacing: 6,');
      }
    }
  }
  
  file.writeAsStringSync(lines.join('\n'));
  print('Replaced remaining Rows with Wraps!');
}
