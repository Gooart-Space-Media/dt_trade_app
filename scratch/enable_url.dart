import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();

  // Add import
  int importIdx = lines.indexWhere((l) => l.startsWith('import '));
  lines.insert(importIdx, "import 'package:url_launcher/url_launcher.dart';");

  // Uncomment launchUrl and change it to async
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('onTap: () {') && i < 2000 && lines[i+1].contains('// TODO: Insert your actual XM Affiliate Link here')) {
      lines[i] = '      onTap: () async {';
      lines[i+2] = "        await launchUrl(Uri.parse('https://clicks.pipaffiliates.com/c?c=1302046&l=zh-hans&p=6'));";
      break;
    }
  }

  file.writeAsStringSync(lines.join('\n'));
  print('Added url_launcher and enabled link!');
}
