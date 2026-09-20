import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();

  // 1. Change Flex Ratio
  int flex5Idx = lines.indexWhere((l) => l.contains('flex: 5,'));
  if (flex5Idx != -1) lines[flex5Idx] = lines[flex5Idx].replaceAll('flex: 5', 'flex: 6');
  
  int flex6Idx = lines.indexWhere((l) => l.contains('flex: 6,'), flex5Idx + 1);
  if (flex6Idx != -1) lines[flex6Idx] = lines[flex6Idx].replaceAll('flex: 6', 'flex: 4');

  // 2. Change _buildTierButton to have a fixed width and fit inside a Wrap
  int startIdx = lines.indexWhere((l) => l.contains('Widget _buildTierButton(String title, String subtitle, String pairs) {'));
  int endIdx = lines.indexWhere((l) => l.contains('Widget build(BuildContext context) {'), startIdx);

  if (startIdx != -1 && endIdx != -1) {
    final newHelper = '''
  Widget _buildTierButton(String title, String subtitle, String pairs) {
    bool active = activePair == title;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          activePair = title;
          isGoldMode = title.contains('黄金');
          _saveParam('calc_active_pair', title);
          _saveParam('calc_is_gold', isGoldMode);
        });
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 10, bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFEF3C7) : Colors.transparent,
          border: Border.all(color: active ? const Color(0xFFF59E0B) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? const Color(0xFFD97706) : Colors.blueGrey)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 10, color: active ? const Color(0xFFD97706).withOpacity(0.8) : Colors.grey)),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(pairs, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: active ? const Color(0xFFD97706) : Colors.grey.shade600), textAlign: TextAlign.right),
            ),
          ],
        ),
      ),
    );
  }
''';
    lines.replaceRange(startIdx, endIdx, [newHelper]);
  }

  // 3. Change Column to Wrap for the Tier Buttons
  // Look for:
  // child: Column(
  //   crossAxisAlignment: CrossAxisAlignment.start,
  //   children: [
  //     _buildTierButton(
  int colStart = lines.indexWhere((l) => l.contains('child: Column('));
  while (colStart != -1) {
    // Check if the next few lines have _buildTierButton
    if (lines[colStart + 3].contains('_buildTierButton')) {
        lines[colStart] = lines[colStart].replaceAll('child: Column(', 'child: Wrap(');
        // Remove crossAxisAlignment: CrossAxisAlignment.start,
        lines.removeAt(colStart + 1);
        break; // found and replaced
    }
    colStart = lines.indexWhere((l) => l.contains('child: Column('), colStart + 1);
  }

  file.writeAsStringSync(lines.join('\n'));
  print('Layout updated successfully!');
}
