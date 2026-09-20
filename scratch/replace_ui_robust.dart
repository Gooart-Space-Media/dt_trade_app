import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  String code = file.readAsStringSync().replaceAll('\r\n', '\n');

  final oldUiStart = "const Text('快速联动品种 (自动载入 ATR 止损基准): ', style: TextStyle(fontSize: 11, color: Colors.grey)),";
  final oldUiEnd = "}).toList(),\n          ),\n        ),";

  final startIndex = code.indexOf(oldUiStart);
  if (startIndex == -1) {
    print('Start not found');
    return;
  }
  
  // Find the Row that contains the oldUiStart
  final rowStart = code.lastIndexOf('        Row(\n          children: [', startIndex);
  if (rowStart == -1) {
      print('Row start not found');
      return;
  }

  final endIndex = code.indexOf(oldUiEnd, startIndex);
  if (endIndex == -1) {
    print('End not found');
    return;
  }

  final fullEndIndex = endIndex + oldUiEnd.length;

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

  code = code.replaceRange(rowStart, fullEndIndex, newUi);
  file.writeAsStringSync(code);
  print('Replaced successfully by range!');
}
