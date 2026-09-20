import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();
  
  // Find start
  int start = -1;
  for (int i=1900; i<lines.length; i++) {
    if (lines[i].contains('Row(') && lines[i+1].contains('crossAxisAlignment: CrossAxisAlignment.start,')) {
      if (lines[i+3].contains('flex: 1,')) {
        start = i;
        break;
      }
    }
  }
  
  // Find end
  int end = -1;
  if (start != -1) {
    for (int i=start; i<lines.length; i++) {
      if (lines[i].contains('动态变速箱风控档位')) {
        end = i - 2; // the row ends before this comment
        break;
      }
    }
  }
  
  if (start != -1 && end != -1) {
    print('Found start \$start, end \$end');
    String newContent = '''        isDesktop
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
    
    lines.replaceRange(start, end + 1, newContent.split('\n'));
    file.writeAsStringSync(lines.join('\n'));
    print('Fixed final overflow issue');
  } else {
    print('Failed to find');
  }
}
