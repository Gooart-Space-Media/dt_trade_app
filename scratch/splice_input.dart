import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();
  
  int startIndex = -1;
  int endIndex = -1;
  
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Row(') && lines[i+2].contains('Expanded(') && lines[i+11].contains('calc_balance')) {
      startIndex = i;
      break;
    }
  }
  
  if (startIndex != -1) {
    for (int i = startIndex; i < startIndex + 60; i++) {
      if (lines[i].contains('],') && lines[i+1].contains('),') && lines[i+3].contains('动态变速箱风控档位')) {
        endIndex = i + 1;
        break;
      }
    }
  }
  
  if (startIndex != -1 && endIndex != -1) {
    String newBlock = '''        isDesktop
            ? Row(
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
                          child: Text('≈ RM \${(balance * rate).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('汇率 (MYR)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            GestureDetector(
                              onTap: isFetchingRate ? null : _fetchLiveExchangeRate,
                              child: Text(isFetchingRate ? '刷新中..' : '🔄 实时', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _rateCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: _buildInput(isGoldMode ? '形态止损 (0.1\\\$ = 1 Pip)' : '形态止损空间 (Pips)', _slCtrl, (v) {
                      setState(() => slPips = double.tryParse(v) ?? 0);
                      _saveParam('calc_sl', slPips);
                    }),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInput('账户本金 (USD)', _balCtrl, (v) {
                              setState(() => balance = double.tryParse(v) ?? 0);
                              _saveParam('calc_balance', balance);
                            }),
                            Padding(
                              padding: const EdgeInsets.only(left: 4, top: 4),
                              child: Text('≈ RM \${(balance * rate).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('汇率', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                                GestureDetector(
                                  onTap: isFetchingRate ? null : _fetchLiveExchangeRate,
                                  child: Text(isFetchingRate ? '刷新..' : '🔄 实时', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _rateCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInput(isGoldMode ? '形态止损 (0.1\\\$ = 1 Pip)' : '形态止损空间 (Pips)', _slCtrl, (v) {
                    setState(() => slPips = double.tryParse(v) ?? 0);
                    _saveParam('calc_sl', slPips);
                  }),
                ],
              ),''';
              
    lines.replaceRange(startIndex, endIndex + 1, newBlock.split('\n'));
    file.writeAsStringSync(lines.join('\n'));
    print('Spliced successfully!');
  } else {
    print('Could not find boundaries! \$startIndex \$endIndex');
  }
}
