import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();

  // 1. Change Flex Ratio to 7 and 3
  int flex6Idx = lines.indexWhere((l) => l.contains('flex: 6,'));
  if (flex6Idx != -1) lines[flex6Idx] = lines[flex6Idx].replaceAll('flex: 6', 'flex: 7');
  
  int flex4Idx = lines.indexWhere((l) => l.contains('flex: 4,'), flex6Idx + 1);
  if (flex4Idx != -1) lines[flex4Idx] = lines[flex4Idx].replaceAll('flex: 4', 'flex: 3');

  // 2. Refactor _buildTierButton to take optional width
  int btnStart = lines.indexWhere((l) => l.contains('Widget _buildTierButton('));
  int btnEnd = lines.indexWhere((l) => l.contains('Widget build(BuildContext context) {'), btnStart);

  if (btnStart != -1 && btnEnd != -1) {
    final newHelper = '''
  Widget _buildTierButton(String title, String subtitle, String pairs, {double? width}) {
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
        width: width,
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFEF3C7) : Colors.transparent,
          border: Border.all(color: active ? const Color(0xFFF59E0B) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? const Color(0xFFD97706) : Colors.blueGrey)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 10, color: active ? const Color(0xFFD97706).withOpacity(0.8) : Colors.grey)),
            const SizedBox(height: 8),
            Text(pairs.replaceAll('\\n', ' '), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? const Color(0xFFD97706) : Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
''';
    lines.replaceRange(btnStart, btnEnd, [newHelper]);
  }

  // Reload lines array
  lines = lines.join('\n').split('\n');

  // 3. Refactor the Tier list calling logic
  int wrapStart = lines.indexWhere((l) => l.contains("child: Wrap("));
  int wrapEnd = -1;
  if (wrapStart != -1) {
      for(int i = wrapStart; i < lines.length; i++){
          if(lines[i].contains("],") && lines[i-1].contains('XAUUSD')) {
              wrapEnd = i + 1; // get to the end of the Wrap block
              break;
          }
      }
  }

  if (wrapStart != -1 && wrapEnd != -1) {
      final newWrapLogic = '''
              isDesktop 
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTierButton('🥇 第一梯队', '绝对恒定 (\\\$0.10)', 'EURUSD, GBPUSD, AUDUSD, NZDUSD', width: null)),
                      Expanded(child: _buildTierButton('🛡️ 第二梯队', '超级防御 (~\\\$0.06)', 'USDJPY, EURJPY, GBPJPY, AUDJPY, CADJPY, AUDNZD', width: null)),
                      Expanded(child: _buildTierButton('📉 第三梯队', '安全打折 (~\\\$0.07)', 'USDCAD, AUDCAD, EURCAD', width: null)),
                      Expanded(child: _buildTierButton('⚠️ 第四梯队', '点值溢价 (警惕微超)', 'USDCHF, EURGBP', width: null)),
                      Expanded(child: _buildTierButton('👑 独立品种', '美黄金 (0.1\\\$ = 1Pip)', 'XAUUSD', width: null)),
                    ],
                  )
                : Wrap(
                    children: [
                      _buildTierButton('🥇 第一梯队', '绝对恒定 (\\\$0.10)', 'EURUSD, GBPUSD, AUDUSD, NZDUSD', width: 250),
                      _buildTierButton('🛡️ 第二梯队', '超级防御 (~\\\$0.06)', 'USDJPY, EURJPY, GBPJPY, AUDJPY, CADJPY, AUDNZD', width: 250),
                      _buildTierButton('📉 第三梯队', '安全打折 (~\\\$0.07)', 'USDCAD, AUDCAD, EURCAD', width: 250),
                      _buildTierButton('⚠️ 第四梯队', '点值溢价 (警惕微超)', 'USDCHF, EURGBP', width: 250),
                      _buildTierButton('👑 独立品种', '美黄金 (0.1\\\$ = 1Pip)', 'XAUUSD', width: 250),
                    ],
                  ),''';
      
      // Need to find where Wrap ends correctly. 
      // The original code was:
      // child: Wrap(
      //    children: [
      //      _buildTierButton(...)
      //      ...
      //    ]
      // ),
      // So wrapEnd should be after `),`
      int actualEnd = wrapEnd;
      while (actualEnd < lines.length && !lines[actualEnd].contains('),')) {
          actualEnd++;
      }
      lines.replaceRange(wrapStart, actualEnd + 1, [newWrapLogic]);
  }

  // Reload lines array
  lines = lines.join('\n').split('\n');

  // 4. Wrap the right card texts in FittedBox to prevent overflow when 30% width
  int finalLotsIdx = lines.indexWhere((l) => l.contains("Text('\\\$''\${riskAmt.toStringAsFixed(2)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),"));
  if (finalLotsIdx != -1) {
      lines[finalLotsIdx] = "                              FittedBox(fit: BoxFit.scaleDown, child: Text('\\\$''\${riskAmt.toStringAsFixed(2)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900))),";
  }

  int bigFinalLotsIdx = lines.indexWhere((l) => l.contains("Text('\${finalLots.toStringAsFixed(2)} 手', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900"));
  if (bigFinalLotsIdx != -1) {
      lines[bigFinalLotsIdx] = "                                FittedBox(fit: BoxFit.scaleDown, child: Text('\${finalLots.toStringAsFixed(2)} 手', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: isGoldMode ? const Color(0xFFD97706) : const Color(0xFF2563EB)))),";
  }
  
  int dualOrdersIdx = lines.indexWhere((l) => l.contains("Text('实操双单：A单 \${(finalLots / 2).toStringAsFixed(2)}手 ➕ B单 \${(finalLots / 2).toStringAsFixed(2)}手'"));
  if (dualOrdersIdx != -1) {
      lines[dualOrdersIdx] = "                                  FittedBox(fit: BoxFit.scaleDown, child: Text('实操双单：A单 \${(finalLots / 2).toStringAsFixed(2)}手 ➕ B单 \${(finalLots / 2).toStringAsFixed(2)}手', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),";
  }


  file.writeAsStringSync(lines.join('\n'));
  print('Layout width changed and Row added!');
}
