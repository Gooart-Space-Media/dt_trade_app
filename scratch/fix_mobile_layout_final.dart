import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  String code = file.readAsStringSync();
  code = code.replaceAll('\r\n', '\n');

  String tierRegex = r"child: isDesktop[\s\S]*?\? Row\([\s\S]*?\]\n                \)[\s\S]*?: Wrap\([\s\S]*?\]\n                \),";
  
  String newTierLayout = '''child: isDesktop
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
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTierButton('🥇 第一梯队', '绝对恒定 (\\\$0.10)', 'EURUSD, GBPUSD, AUDUSD, NZDUSD', width: 220),
                      _buildTierButton('🛡️ 第二梯队', '超级防御 (~\\\$0.06)', 'USDJPY, EURJPY, GBPJPY, AUDJPY, CADJPY, AUDNZD', width: 240),
                      _buildTierButton('📉 第三梯队', '安全打折 (~\\\$0.07)', 'USDCAD, AUDCAD, EURCAD', width: 200),
                      _buildTierButton('⚠️ 第四梯队', '点值溢价 (警惕微超)', 'USDCHF, EURGBP', width: 200),
                      _buildTierButton('👑 独立品种', '美黄金 (0.1\\\$ = 1Pip)', 'XAUUSD', width: 160),
                    ],
                  ),
                ),''';

  code = code.replaceFirst(RegExp(tierRegex), newTierLayout);

  String inputRegex = r"Row\(\s*crossAxisAlignment: CrossAxisAlignment\.start,\s*children: \[\s*Expanded\([\s\S]*?_buildInput\('账户本金 \(USD\)'[\s\S]*?_buildInput\(isGoldMode \? '形态止损[\s\S]*?\}\),\s*\),\s*\]\s*\),";
  
  String newInputLayout = '''isDesktop
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInput(isGoldMode ? '形态止损 (0.1\\\$ = 1 Pip)' : '形态止损空间 (Pips)', _slCtrl, (v) {
                    setState(() => slPips = double.tryParse(v) ?? 0);
                    _saveParam('calc_sl', slPips);
                  }),
                ],
              ),''';

  code = code.replaceFirst(RegExp(inputRegex), newInputLayout);

  file.writeAsStringSync(code);
  print('Mobile layout completely fixed!');
}
