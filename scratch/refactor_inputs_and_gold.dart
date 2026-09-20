import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();

  // 1. Fix isGoldMode logic in _buildTierButton
  int goldModeIdx = lines.indexWhere((l) => l.contains("isGoldMode = title.contains('黄金');"));
  if (goldModeIdx != -1) {
    lines[goldModeIdx] = lines[goldModeIdx].replaceAll("title.contains('黄金')", "pairs.contains('XAUUSD')");
  }

  // 2. Fix the typo for standard forex candle
  int typoIdx = lines.indexWhere((l) => l.contains("状态': '🟢 标准黄金蜡烛") || l.contains("status': '🟢 标准黄金蜡烛"));
  if (typoIdx != -1) {
    lines[typoIdx] = lines[typoIdx].replaceAll("标准黄金蜡烛", "标准外汇波动");
  }

  // 3. Find the old Row with Balance and Rate
  int rowStart = lines.indexWhere((l) => l.contains("child: _buildInput('账户本金 (USD)'"));
  // Walk backwards to find the Row(
  while (rowStart > 0 && !lines[rowStart].contains("Row(")) {
    rowStart--;
  }

  // Find the end of that block including the RM padding
  int rowEnd = lines.indexWhere((l) => l.contains("≈ RM \${(balance * rate)"), rowStart);
  while (rowEnd < lines.length && !lines[rowEnd].contains("),")) {
    rowEnd++;
  }

  // 4. Find the old SL input and delete it
  int slStart = lines.indexWhere((l) => l.contains("形态止损空间 (Pips)'"));
  if (slStart != -1) {
    int delStart = slStart - 2; // to catch the _buildInput line
    int delEnd = delStart;
    while (delEnd < lines.length && !lines[delEnd].contains("})),")) {
      delEnd++;
      if (lines[delEnd].contains("})),")) break;
      if (lines[delEnd].contains("}),")) break;
    }
    // Just blank them out to not mess up indices right away
    for (int i = delStart - 1; i <= delEnd + 1; i++) { // include SizedBoxes around it
      if (lines[i].contains("SizedBox") || lines[i].contains("形态止损") || lines[i].contains("slPips = ") || lines[i].contains("calc_sl") || lines[i].contains("})")) {
          lines[i] = "";
      }
    }
  }

  // 5. Replace the Balance/Rate block with the new 3-column row
  if (rowStart != -1 && rowEnd != -1) {
    final newRow = '''
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInput('账户本金 (USD)', _balCtrl, (v) {
                    setState(() => balance = double.tryParse(v) ?? 0);
                    _saveParam('calc_balance', balance);
                  }),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Text('≈ RM \${(balance * rate).toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('汇率 (MYR)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      GestureDetector(
                        onTap: isFetchingRate ? null : _fetchLiveExchangeRate,
                        child: Text(isFetchingRate ? '刷新..' : '🔄 实时', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _rateCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (v) {
                      setState(() => rate = double.tryParse(v) ?? 4.5);
                      _saveParam('calc_rate', rate);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: _buildInput(isGoldMode ? '形态止损 (0.1\\\$)' : '止损空间 (Pips)', _slCtrl, (v) {
                setState(() => slPips = double.tryParse(v) ?? 0);
                _saveParam('calc_sl', slPips);
              }),
            ),
          ],
        ),
''';
    lines.replaceRange(rowStart, rowEnd + 1, [newRow]);
  }

  // Remove empty lines created by step 4
  lines.removeWhere((l) => l.trim() == "" && !l.contains(" "));

  file.writeAsStringSync(lines.join('\n'));
  print('Done!');
}
