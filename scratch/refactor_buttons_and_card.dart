import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();

  // 1. Refactor _buildTierButton
  int btnStart = lines.indexWhere((l) => l.contains('Widget _buildTierButton(String title, String subtitle, String pairs) {'));
  int btnEnd = lines.indexWhere((l) => l.contains('Widget build(BuildContext context) {'), btnStart);

  if (btnStart != -1 && btnEnd != -1) {
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
        width: 250,
        margin: const EdgeInsets.only(right: 12, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFEF3C7) : Colors.transparent,
          border: Border.all(color: active ? const Color(0xFFF59E0B) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: active ? const Color(0xFFD97706) : Colors.blueGrey)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11, color: active ? const Color(0xFFD97706).withOpacity(0.8) : Colors.grey)),
            const SizedBox(height: 8),
            Text(pairs.replaceAll('\\n', ' '), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? const Color(0xFFD97706) : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
''';
    lines.replaceRange(btnStart, btnEnd, [newHelper]);
  }

  // Reload lines array since we modified it
  lines = lines.join('\n').split('\n');

  // 2. Refactor Results Card to be Row on Desktop
  int cardStart = lines.indexWhere((l) => l.contains("const Text('本次亏损上限 (风险金额)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),"));
  // Find the end of the card's column children
  int cardEnd = lines.indexWhere((l) => l.contains("// 500-3200 标准速查表卡片 (来自 Notion 核心战法)"), cardStart);
  
  if (cardStart != -1 && cardEnd != -1) {
      // Find the closing bracket of the column children which is roughly at cardEnd - 4
      int actualEnd = cardEnd - 1;
      while (actualEnd > cardStart && !lines[actualEnd].contains('],')) {
          actualEnd--;
      }

      final newCardLogic = '''
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('本次亏损上限 (风险金额)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 6),
                              Text('\\\$''\${riskAmt.toStringAsFixed(2)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                              Text('≈ RM \${riskAmtRM.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 80, color: Theme.of(context).dividerColor.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 10)),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('执行双轨总手数 (恒为偶数)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 6),
                              if (isInsufficient) ...[
                                const Text('🚫 资金不足以挂双单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                                const SizedBox(height: 4),
                                Text('理论需: \${rawLots.toStringAsFixed(3)} 手\\n(强烈建议转 Micro 微型)', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.red)),
                              ] else ...[
                                Text('\${finalLots.toStringAsFixed(2)} 手', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: isGoldMode ? const Color(0xFFD97706) : const Color(0xFF2563EB))),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                  ),
                                  child: Text('实操双单：A单 \${(finalLots / 2).toStringAsFixed(2)}手 ➕ B单 \${(finalLots / 2).toStringAsFixed(2)}手', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Text('本次亏损上限 (风险金额)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('\\\$''\${riskAmt.toStringAsFixed(2)}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                        Text('≈ RM \${riskAmtRM.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                        const Divider(height: 30),
                        const Text('执行双轨总手数 (恒为偶数)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 4),
                        if (isInsufficient) ...[
                          const Text('🚫 资金不足以挂双单', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                          const SizedBox(height: 4),
                          Text('理论需: \${rawLots.toStringAsFixed(3)} 手 (强烈建议转 Micro 微型账户执行)', style: const TextStyle(fontSize: 12, color: Colors.red)),
                        ] else ...[
                          Text('\${finalLots.toStringAsFixed(2)} 手', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: isGoldMode ? const Color(0xFFD97706) : const Color(0xFF2563EB))),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: Text('实操双单：A单 \${(finalLots / 2).toStringAsFixed(2)} 手 ➕ B单 \${(finalLots / 2).toStringAsFixed(2)} 手', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ],
                    ),''';

      lines.replaceRange(cardStart, actualEnd + 1, [newCardLogic]);
  }

  file.writeAsStringSync(lines.join('\n'));
  print('Buttons and Card updated successfully!');
}
