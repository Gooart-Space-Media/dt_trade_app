import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();

  // Find start of _buildPairButton
  int startIdx = lines.indexWhere((l) => l.contains('Widget _buildPairButton(String pair) {'));
  // Find start of build method after startIdx
  int endIdx = lines.indexWhere((l) => l.contains('Widget build(BuildContext context) {'), startIdx);

  if (startIdx == -1 || endIdx == -1) {
    print('Could not find helper bounds!');
    return;
  }

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
        margin: const EdgeInsets.only(bottom: 8),
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
  file.writeAsStringSync(lines.join('\n'));
  print('Replaced successfully!');
}
