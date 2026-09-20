import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();
  
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Row(') && i + 1 < lines.length) {
      if (lines[i+1].contains('mainAxisAlignment: MainAxisAlignment.spaceBetween,')) {
        lines[i] = lines[i].replaceFirst('Row(', 'Wrap(');
        lines[i+1] = lines[i+1].replaceFirst('mainAxisAlignment: MainAxisAlignment.spaceBetween,', 'alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 4,');
      }
    }
  }
  
  file.writeAsStringSync(lines.join('\n'));
  print('Replaced ALL remaining spaceBetween Rows with Wraps!');
}
