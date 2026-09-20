import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  String content = file.readAsStringSync();

  String oldChart = '''
                    // Right: Chart
                    Expanded(
                      flex: 52,
                      child: Container(
                        height: 120,
                        padding: const EdgeInsets.all(8),
'''.trim();

  String newChart = '''
                    // Right: Chart
                    Expanded(
                      flex: 52,
                      child: Container(
                        height: isDesktop ? 120 : 168,
                        padding: const EdgeInsets.all(8),
'''.trim();

  if (content.contains(oldChart)) {
    content = content.replaceFirst(oldChart, newChart);
    file.writeAsStringSync(content);
    print('Chart height updated successfully!');
  } else {
    print('Could not find old chart container block!');
  }
}
