import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  String code = file.readAsStringSync();
  // Normalize line endings for replacement
  code = code.replaceAll('\r\n', '\n');

  // Fix 1: Change the Wrap to a horizontally scrolling Row
  String oldMobileLayout = '''              : Wrap(
                  children: [
                    _buildTierButton('🥇 第一梯队', '绝对恒定 (\$0.10)', 'EURUSD, GBPUSD, AUDUSD, NZDUSD', width: 250),
                    _buildTierButton('🛡️ 第二梯队', '超级防御 (~\$0.06)', 'USDJPY, EURJPY, GBPJPY, AUDJPY, CADJPY, AUDNZD', width: 250),
                    _buildTierButton('📉 第三梯队', '安全打折 (~\$0.07)', 'USDCAD, AUDCAD, EURCAD', width: 250),
                    _buildTierButton('⚠️ 第四梯队', '点值溢价 (警惕微超)', 'USDCHF, EURGBP', width: 250),
                    _buildTierButton('👑 独立品种', '美黄金 (0.1\$ = 1Pip)', 'XAUUSD', width: 250),
                  ],
                ),''';
                
  String newMobileLayout = '''              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTierButton('🥇 第一梯队', '绝对恒定 (\$0.10)', 'EURUSD, GBPUSD, AUDUSD, NZDUSD', width: 220),
                      _buildTierButton('🛡️ 第二梯队', '超级防御 (~\$0.06)', 'USDJPY, EURJPY, GBPJPY, AUDJPY, CADJPY, AUDNZD', width: 240),
                      _buildTierButton('📉 第三梯队', '安全打折 (~\$0.07)', 'USDCAD, AUDCAD, EURCAD', width: 200),
                      _buildTierButton('⚠️ 第四梯队', '点值溢价 (警惕微超)', 'USDCHF, EURGBP', width: 200),
                      _buildTierButton('👑 独立品种', '美黄金 (0.1\$ = 1Pip)', 'XAUUSD', width: 160),
                    ],
                  ),
                ),''';
                
  code = code.replaceAll(oldMobileLayout, newMobileLayout);

  // Fix 2: Update _buildTierButton colors for Dark Mode
  String oldBuildTierButton = '''  Widget _buildTierButton(String title, String subtitle, String pairs, {double? width}) {
    bool active = activePair == title;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          activePair = title;
          isGoldMode = pairs.contains('XAUUSD');
          _saveParam('calc_active_pair', title);
          _saveParam('calc_is_gold', isGoldMode);
        });
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFEF3C7) : Colors.transparent,
          border: Border.all(color: active ? const Color(0xFFF59E0B) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: active ? const Color(0xFFD97706) : Colors.blueGrey)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 9, color: active ? const Color(0xFFD97706).withOpacity(0.8) : Colors.grey)),
            const SizedBox(height: 8),
            Text(pairs.replaceAll('\\n', ' '), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active ? const Color(0xFFD97706) : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }''';

  String newBuildTierButton = '''  Widget _buildTierButton(String title, String subtitle, String pairs, {double? width}) {
    bool active = activePair == title;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          activePair = title;
          isGoldMode = pairs.contains('XAUUSD');
          _saveParam('calc_active_pair', title);
          _saveParam('calc_is_gold', isGoldMode);
        });
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: active 
              ? (isDark ? const Color(0xFFF59E0B).withOpacity(0.2) : const Color(0xFFFEF3C7)) 
              : Colors.transparent,
          border: Border.all(
              color: active 
                  ? const Color(0xFFF59E0B) 
                  : Theme.of(context).dividerColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: active ? const Color(0xFFF59E0B) : (isDark ? Colors.grey.shade300 : Colors.blueGrey))),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 9, color: active ? const Color(0xFFF59E0B).withOpacity(0.8) : (isDark ? Colors.grey.shade500 : Colors.grey))),
            const SizedBox(height: 8),
            Text(pairs.replaceAll('\\n', ' '), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active ? const Color(0xFFF59E0B) : (isDark ? Colors.grey.shade400 : Colors.grey.shade600))),
          ],
        ),
      ),
    );
  }''';

  code = code.replaceAll(oldBuildTierButton, newBuildTierButton);

  file.writeAsStringSync(code);
  print('Mobile layout and colors fixed!');
}
