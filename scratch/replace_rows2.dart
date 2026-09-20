import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();
  
  List<int> targetLines = [4385];
  
  for (int i in targetLines) {
    if (lines[i].contains('Row(') && lines[i+1].contains('mainAxisAlignment: MainAxisAlignment.spaceAround,')) {
      lines[i] = lines[i].replaceFirst('Row(', 'Wrap(');
      lines[i+1] = lines[i+1].replaceFirst('mainAxisAlignment: MainAxisAlignment.spaceAround,', 'alignment: WrapAlignment.spaceAround, crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 12,');
    } else {
      print('Mismatch at line \$i: \${lines[i]}');
    }
  }
  
  file.writeAsStringSync(lines.join('\n'));
  print('Replaced spaceAround Row with Wrap!');
}
