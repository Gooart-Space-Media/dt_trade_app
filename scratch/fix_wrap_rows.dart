import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Wrap(') && i + 1 < lines.length && lines[i+1].contains('alignment: WrapAlignment.spaceBetween')) {
      // Look ahead up to 10 lines to find a Row that doesn't have mainAxisSize
      for (int j = i + 1; j < i + 15 && j < lines.length; j++) {
        if (lines[j].contains('Row(') && !lines[j].contains('mainAxisSize')) {
          lines[j] = lines[j].replaceFirst('Row(', 'Row(mainAxisSize: MainAxisSize.min, ');
        }
      }
    }
  }

  file.writeAsStringSync(lines.join('\n'));
  print('Added mainAxisSize: MainAxisSize.min to Rows inside Wrap(spaceBetween)');
}
