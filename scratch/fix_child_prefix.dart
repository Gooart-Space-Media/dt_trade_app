import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();
  
  // Find the Container decoration block
  int startIdx = lines.indexWhere((l) => l.contains("color: Theme.of(context).cardColor,"));
  int containerIdx = lines.indexWhere((l) => l.contains("isDesktop"), startIdx);
  if (containerIdx != -1 && lines[containerIdx].trim() == 'isDesktop') {
      lines[containerIdx] = '              child: isDesktop';
  } else if (containerIdx != -1 && lines[containerIdx].trim() == 'isDesktop') {
      // it might have trailing spaces
      lines[containerIdx] = lines[containerIdx].replaceFirst('isDesktop', 'child: isDesktop');
  } else if (containerIdx != -1 && lines[containerIdx].contains('isDesktop')) {
      lines[containerIdx] = lines[containerIdx].replaceFirst('isDesktop', 'child: isDesktop');
  }

  // Find FittedBox without child:
  for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('FittedBox(fit: BoxFit.scaleDown, child: Text(\\'实操双单：A单'))) {
          lines[i] = lines[i].replaceFirst('FittedBox(fit:', 'child: FittedBox(fit:');
      }
  }

  file.writeAsStringSync(lines.join('\n'));
  print('Fixed missing children prefixes!');
}
