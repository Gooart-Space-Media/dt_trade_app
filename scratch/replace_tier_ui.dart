import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  String code = file.readAsStringSync().replaceAll('\r\n', '\n');

  final oldHelperRegex = "  Widget _buildPairButton(String pair) {[\\s\\S]*?  Widget build\\(BuildContext context\\) \\{";

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

  Widget build(BuildContext context) {''';

  code = code.replaceFirst(RegExp(oldHelperRegex), newHelper);

  final oldUi = '''              _buildPairGroup('🥇 第一梯队：绝对恒定组 (\\\$0.10)', ['EURUSD', 'GBPUSD', 'AUDUSD', 'NZDUSD']),
              _buildPairGroup('🛡️ 第二梯队：超级防御组 (~\\\$0.06)', ['USDJPY', 'EURJPY', 'GBPJPY', 'AUDJPY', 'CADJPY', 'AUDNZD']),
              _buildPairGroup('📉 第三梯队：安全打折组 (~\\\$0.07)', ['USDCAD', 'AUDCAD', 'EURCAD']),
              _buildPairGroup('⚠️ 第四梯队：点值溢价组 (警惕微超)', ['USDCHF', 'EURGBP']),
              _buildPairGroup('👑 独立品种：美黄金 (0.1\\\$ = 1Pip)', ['XAUUSD']),''';

  final newUi = '''              _buildTierButton('🥇 第一梯队', '绝对恒定组 (\\\$0.10)', 'EURUSD, GBPUSD\\nAUDUSD, NZDUSD'),
              _buildTierButton('🛡️ 第二梯队', '超级防御组 (~\\\$0.06)', 'USDJPY, EURJPY, GBPJPY\\nAUDJPY, CADJPY, AUDNZD'),
              _buildTierButton('📉 第三梯队', '安全打折组 (~\\\$0.07)', 'USDCAD, AUDCAD, EURCAD'),
              _buildTierButton('⚠️ 第四梯队', '点值溢价组 (警惕微超)', 'USDCHF, EURGBP'),
              _buildTierButton('👑 独立品种', '美黄金 (0.1\\\$ = 1Pip)', 'XAUUSD'),''';

  if (code.contains(oldUi)) {
    code = code.replaceFirst(oldUi, newUi);
    file.writeAsStringSync(code);
    print('Replaced successfully!');
  } else {
    print('Could not find old UI block!');
  }
}
