import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();
  
  List<int> targetLines = [4163, 4269, 4365, 4466, 4570, 4688];
  
  for (int i in targetLines) {
    if (lines[i].contains('Row(') && lines[i+1].contains('mainAxisAlignment: MainAxisAlignment.spaceBetween,')) {
      lines[i] = lines[i].replaceFirst('Row(', 'Wrap(');
      lines[i+1] = lines[i+1].replaceFirst('mainAxisAlignment: MainAxisAlignment.spaceBetween,', 'alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 8,');
    } else {
      print('Mismatch at line \$i: \${lines[i]}');
    }
  }
  
  file.writeAsStringSync(lines.join('\n'));
  print('Replaced Rows with Wraps!');
}
