import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  String content = file.readAsStringSync();

  var regex = RegExp(
      r'child:\s*Row\(\s*crossAxisAlignment:\s*CrossAxisAlignment\.start,\s*children:\s*\[\s*Expanded\(\s*child:\s*_buildResultCard\([\s\S]*?isDark: isDark,\s*\),\s*\),\s*const SizedBox\(width: 12\),\s*Expanded\(\s*child:\s*_buildResultCard\([\s\S]*?isDark: isDark,\s*\),\s*\),\s*\],\s*\),');

  if (regex.hasMatch(content)) {
    var match = regex.firstMatch(content)!;
    String matchedString = match.group(0)!;
    
    // We can just replace 'Row(' with 'isDesktop ? Row(' and append the Column part.
    // It's safer to just extract the two _buildResultCard calls.
    var cardRegex = RegExp(r'_buildResultCard\([\s\S]*?isDark: isDark,\s*\)');
    var cards = cardRegex.allMatches(matchedString).toList();
    if (cards.length == 2) {
      String dtCard = cards[0].group(0)!;
      String stCard = cards[1].group(0)!;
      
      String newCode = '''
                child: isDesktop ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: $dtCard,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: $stCard,
                    ),
                  ],
                ) : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    $dtCard,
                    const SizedBox(height: 12),
                    $stCard,
                  ],
                ),''';
      
      content = content.replaceFirst(matchedString, newCode);
      file.writeAsStringSync(content);
      print('Replaced successfully with Regex!');
    } else {
      print('Could not find two cards in the match!');
    }
  } else {
    print('Regex did not match!');
  }
}
