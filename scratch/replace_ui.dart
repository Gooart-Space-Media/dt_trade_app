import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  String code = file.readAsStringSync();

  final oldUi = '''        Row(
          children: [
            const Text('快速联动品种 (自动载入 ATR 止损基准): ', style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text('当前: ' + activePair, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: kWatchlistPairs.map((p) => p.symbol).toList().map((pair) {
              bool active = activePair == pair;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    activePair = pair;
                    isGoldMode = pair == 'XAUUSD';
                    _saveParam('calc_active_pair', pair);
                    _saveParam('calc_is_gold', isGoldMode);
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFFFEF3C7) : Colors.transparent,
                    border: Border.all(color: active ? const Color(0xFFF59E0B) : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(pair, style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? const Color(0xFFD97706) : Colors.grey.shade700)),
                ),
              );
            }).toList(),
          ),
        ),''';

  final newUi = '''        Row(
          children: [
            const Text('点值梯队联动 (自动载入 ATR 止损基准): ', style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text('当前: ' + activePair, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPairGroup('🥇 第一梯队：绝对恒定组 (\$0.10)', ['EURUSD', 'GBPUSD', 'AUDUSD', 'NZDUSD']),
              _buildPairGroup('🛡️ 第二梯队：超级防御组 (~\$0.06)', ['USDJPY', 'EURJPY', 'GBPJPY', 'AUDJPY', 'CADJPY', 'AUDNZD']),
              _buildPairGroup('📉 第三梯队：安全打折组 (~\$0.07)', ['USDCAD', 'AUDCAD', 'EURCAD']),
              _buildPairGroup('⚠️ 第四梯队：点值溢价组 (警惕微超)', ['USDCHF', 'EURGBP']),
              _buildPairGroup('👑 独立品种：美黄金 (0.1\$ = 1Pip)', ['XAUUSD']),
            ],
          ),
        ),''';

  if (code.contains(oldUi)) {
    code = code.replaceAll(oldUi, newUi);
    file.writeAsStringSync(code);
    print('Replaced successfully!');
  } else {
    print('Could not find old UI block!');
  }
}
