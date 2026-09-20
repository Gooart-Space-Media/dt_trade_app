class _LotSizeCalcPageState extends State<LotSizeCalcPage> {
  final TextEditingController _balCtrl = TextEditingController(text: '1000');
  final TextEditingController _rateCtrl = TextEditingController(text: '4.50');
  final TextEditingController _slCtrl = TextEditingController(text: '50');

  double balance = 1000;
  double rate = 4.50;
  int riskPct = 2;
  double slPips = 50;
  bool isGoldMode = false;
  bool isMicroMode = false;
  String activePair = "EURUSD";
  bool isFetchingRate = false;

  @override
  void initState() {
    super.initState();
    _loadSavedParams();
  }

  Future<void> _loadSavedParams() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getDouble('calc_balance') ?? 1000;
      rate = prefs.getDouble('calc_rate') ?? 4.50;
      riskPct = prefs.getInt('calc_risk') ?? 2;
      slPips = prefs.getDouble('calc_sl') ?? 50;
      isGoldMode = prefs.getBool('calc_is_gold') ?? false;
      isMicroMode = prefs.getBool('calc_is_micro') ?? false;
      activePair = prefs.getString('calc_active_pair') ?? 'EURUSD';

      _balCtrl.text = balance.toStringAsFixed(0);
      _rateCtrl.text = rate.toStringAsFixed(2);
      _slCtrl.text = slPips.toStringAsFixed(0);
    });
  }

  Future<void> _saveParam(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is double) await prefs.setDouble(key, value);
    if (value is int) await prefs.setInt(key, value);
    if (value is bool) await prefs.setBool(key, value);
      if (value is String) await prefs.setString(key, value);
  }

  Future<void> _fetchLiveExchangeRate() async {
    setState(() => isFetchingRate = true);
    HapticFeedback.lightImpact();
    try {
      final response = await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD')).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rates'] != null && data['rates']['MYR'] != null) {
          final liveRate = (data['rates']['MYR'] as num).toDouble();
          setState(() {
            rate = liveRate;
            _rateCtrl.text = rate.toStringAsFixed(2);
          });
          _saveParam('calc_rate', rate);
        }
      }
    } catch (_) {} finally {
      if (mounted) setState(() => isFetchingRate = false);
    }
  }

  // Fight IQ 物理级蜡烛长短健康诊断
  Map<String, dynamic> _getFightIqDiagnosis(double pips) {
    if (isGoldMode) {
      if (pips < 150) {
        return {
          'status': '🟡 黄金噪音小蜡烛 (< 150 Pips / < \$15)',
          'desc': '机构未发力，多为震荡横盘噪音，极易假突破，不建议做突破挂单。',
          'color': const Color(0xFFD97706),
        };
      } else if (pips <= 250) {
        return {
          'status': '🟢 黄金标准舒适区 (150 ~ 250 Pips / \$15~\$25)',
          'desc': '完美标准日线吞没！动能充沛，突破法与 50% 回撤法均可完美执行！',
          'color': const Color(0xFF16A34A),
        };
      } else if (pips <= 350) {
        return {
          'status': '🔵 黄金偏大蜡烛 (250 ~ 350 Pips / \$25~\$35)',
          'desc': '突破止损偏大，严禁追突破挂单！必须用 Fib 50% 回踩折半入场！',
          'color': const Color(0xFF2563EB),
        };
      } else {
        return {
          'status': '🛑 黄金极端力竭蜡烛 (> 350 Pips / > \$35)',
          'desc': '情绪过热暴冲！次日极易深度反抽或扫损，系统强烈建议直接放弃！',
          'color': const Color(0xFFDC2626),
        };
      }
    }
    if (pips < 50) {
      return {
        'status': '🟡 比较短的蜡烛 (< 50 Pips)',
        'desc': '日内波动偏小。此时 50% 回调位太近易被噪音扫损，建议仅采用【突破法挂单】。',
        'color': const Color(0xFFD97706),
      };
    } else if (pips <= 80) {
      return {
        'status': '🟢 标准黄金蜡烛 (50 ~ 80 Pips)',
        'desc': '完美舒适区！波动充足且方向明确，突破法与 50% 回调法均可完美执行！',
        'color': const Color(0xFF16A34A),
      };
    } else if (pips <= 100) {
      return {
        'status': '🔵 偏大蜡烛 (80 ~ 100 Pips)',
        'desc': '突破止损偏大。强烈建议使用【50% 回调法】，将入场风险折半压缩至 40~50 Pips！',
        'color': const Color(0xFF2563EB),
      };
    } else {
      return {
        'status': '🛑 极端力竭蜡烛 (> 100 Pips)',
        'desc': '情绪力竭暴冲！盈亏比极差，系统强烈建议直接放弃交易，坚决不介入！',
        'color': const Color(0xFFDC2626),
      };
    }
  }

  void _showStandardLotsTable() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final tableData = [
          {'bal': 500, 'rm': 2250, 'risk': 10, 's50': '0.02 手 (0.01+0.01)', 's80': '🚫 不可用 (超标)'},
          {'bal': 800, 'rm': 3600, 'risk': 16, 's50': '0.02 手 (0.01+0.01)', 's80': '0.02 手 (0.01+0.01)'},
          {'bal': 1000, 'rm': 4500, 'risk': 20, 's50': '0.04 手 (0.02+0.02)', 's80': '0.02 手 (0.01+0.01)'},
          {'bal': 1500, 'rm': 6750, 'risk': 30, 's50': '0.06 手 (0.03+0.03)', 's80': '0.02 手 (0.01+0.01)'},
          {'bal': 1600, 'rm': 7200, 'risk': 32, 's50': '0.06 手 (0.03+0.03)', 's80': '0.04 手 (0.02+0.02)'},
          {'bal': 2000, 'rm': 9000, 'risk': 40, 's50': '0.08 手 (0.04+0.04)', 's80': '0.04 手 (0.02+0.02)'},
          {'bal': 2400, 'rm': 10800, 'risk': 48, 's50': '0.08 手 (0.04+0.04)', 's80': '0.06 手 (0.03+0.03)'},
          {'bal': 3000, 'rm': 13500, 'risk': 60, 's50': '0.12 手 (0.06+0.06)', 's80': '0.06 手 (0.03+0.03)'},
          {'bal': 3200, 'rm': 14400, 'risk': 64, 's50': '0.12 手 (0.06+0.06)', 's80': '0.08 手 (0.04+0.04)'},
        ];

        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🧮 500 - 3,200 美元双轨最大手数对照表', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('点击任意行可直接快速载入该资金配置 (总手数恒为偶数，保证 2 x 1% 完美平分)：', style: TextStyle(fontSize: 11, color: Colors.grey)),
              const Divider(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: tableData.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (c, idx) {
                    final row = tableData[idx];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          balance = (row['bal'] as int).toDouble();
                          _balCtrl.text = balance.toStringAsFixed(0);
                        });
                        _saveParam('calc_balance', balance);
                        Navigator.pop(ctx);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('\$${row['bal']} (RM ${row['rm']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('2% 红线: \$${row['risk']}', style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('50pips: ${row['s50']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                Text('80pips: ${row['s80']}', style: TextStyle(fontSize: 11, color: (row['s80'] as String).contains('不可用') ? Colors.red : Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double riskAmt = balance * (riskPct / 100);
    double riskAmtRM = riskAmt * rate;
    double rawLots = (slPips > 0) ? riskAmt / (slPips * (isMicroMode ? 0.1 : 10)) : 0;
    int rawMicro = (rawLots * 100).floor();
    if (rawMicro % 2 != 0) rawMicro -= 1;
    double finalLots = rawMicro / 100;
    bool isInsufficient = isMicroMode ? (finalLots < 0.02 * 100) : (finalLots < 0.02);

    final fightIq = _getFightIqDiagnosis(slPips);

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        // Account Mode (XM Standard vs Micro)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => isMicroMode = false);
                    _saveParam('calc_is_micro', false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !isMicroMode ? const Color(0xFF2563EB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('🏢 XM 标准/Ultra Low (1手=100k)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: !isMicroMode ? Colors.white : Colors.grey)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => isMicroMode = true);
                    _saveParam('calc_is_micro', true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isMicroMode ? const Color(0xFF059669) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('🔬 XM Micro 微型 (1手=1k)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isMicroMode ? Colors.white : Colors.grey)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: (){},
              icon: const Icon(Icons.info_outline, size: 14),
              label: const Text('XM 账户选型指南', style: TextStyle(fontSize: 12)),
            ),
            TextButton.icon(
              onPressed: (){},
              icon: const Icon(Icons.bar_chart, size: 14, color: Colors.teal),
              label: const Text('打开手数对照表', style: TextStyle(fontSize: 12, color: Colors.teal)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text('快速联动品种 (自动载入 ATR 止损基准): ', style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text('当前: ' + activePair, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['EURUSD', 'USDJPY', 'AUDUSD', 'GBPUSD'].map((pair) {
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
                  child: Row(
                    children: [
                      if (active) const Icon(Icons.check, size: 12, color: Color(0xFFD97706)),
                      if (active) const SizedBox(width: 4),
                      Text(pair, style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? const Color(0xFFD97706) : Colors.grey.shade700)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(isMicroMode ? '外汇点值: 0.01手 = \$0.001/Pip (Micro)' : '外汇点值: 0.01手 = \$0.10/Pip', style: TextStyle(fontSize: 11, color: Colors.grey)),
            Row(
              children: [
                Icon(Icons.business_center, size: 12, color: Colors.grey),
                SizedBox(width: 4),
                Text(isMicroMode ? '微型账户点值' : '标准账户点值', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            )
          ],
        ),

        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(isGoldMode ? '黄金点值: 0.1\$ 波动 = 1 Pip' : '外汇点值: 0.01手 ≈ \$0.10/Pip', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            InkWell(
              onTap: _showStandardLotsTable,
              child: const Text('📊 打开手数对照表', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildInput('账户本金 (USD)', _balCtrl, (v) {
                setState(() => balance = double.tryParse(v) ?? 0);
                _saveParam('calc_balance', balance);
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('汇率 (MYR)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      GestureDetector(
                        onTap: isFetchingRate ? null : _fetchLiveExchangeRate,
                        child: Text(isFetchingRate ? '刷新中..' : '🔄 实时', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
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
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 4, bottom: 12),
          child: Text('≈ RM ${(balance * rate).toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
        ),

        // 动态变速箱风控档位
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('变速箱风控红线 (Risk %)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text(balance <= 2000 ? '🔥 激进翻倍档 (\$500~\$2k)' : '🛡️ 稳健巡航档 (>\$2k)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: balance <= 2000 ? const Color(0xFFD97706) : const Color(0xFF2563EB))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [2, 3, 4].map((r) {
            bool selected = riskPct == r;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => riskPct = r);
                    _saveParam('calc_risk', r);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? (isGoldMode ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF)) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? (isGoldMode ? const Color(0xFFD97706) : const Color(0xFF3B82F6)) : Theme.of(context).dividerColor.withOpacity(0.4)),
                    ),
                    child: Center(
                      child: Text('$r% ${r == 2 ? "(巡航)" : r == 3 ? "(激进)" : "(极限)"}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: selected ? (isGoldMode ? const Color(0xFF92400E) : const Color(0xFF1E40AF)) : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        _buildInput(isGoldMode ? '形态止损点数 (0.1\$ 为 1 Pip)' : '形态止损空间 (Pips)', _slCtrl, (v) {
          setState(() => slPips = double.tryParse(v) ?? 0);
          _saveParam('calc_sl', slPips);
        }),
        const SizedBox(height: 10),

        // Fight IQ 物理级蜡烛诊断横幅
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (fightIq['color'] as Color).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (fightIq['color'] as Color).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fightIq['status'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fightIq['color'] as Color)),
              const SizedBox(height: 2),
              Text(fightIq['desc'] as String, style: TextStyle(fontSize: 11, color: (fightIq['color'] as Color).withOpacity(0.85), height: 1.3)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 结果卡片
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('本次亏损上限 (风险金额)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                Text('\$${riskAmt.toStringAsFixed(2)}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                Text('≈ RM ${riskAmtRM.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                const Divider(height: 30),
                const Text('执行双轨总手数 (恒为偶数)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                if (isInsufficient) ...[
                  const Text('🚫 资金不足以挂双单', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 4),
                  Text('理论需: ${rawLots.toStringAsFixed(3)} 手 (强烈建议转 Micro 微型账户执行)', style: const TextStyle(fontSize: 12, color: Colors.red)),
                ] else ...[
                  Text('${finalLots.toStringAsFixed(2)} 手', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: isGoldMode ? const Color(0xFFD97706) : const Color(0xFF2563EB))),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Text('实操双单：A单 ${(finalLots / 2).toStringAsFixed(2)} 手 ➕ B单 ${(finalLots / 2).toStringAsFixed(2)} 手', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 500-3200 标准速查表卡片 (来自 Notion 核心战法)
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: false,
              leading: const Icon(Icons.table_chart_rounded, color: Color(0xFF2563EB), size: 20),
              title: const Text('📖 资金阶梯标准速查表 (50 Pips 止损基准)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const Text('基准条件：止损 50 Pips，单笔风险 2%，双轨 1%+1% 分仓', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                Table(
                  border: TableBorder.all(color: Theme.of(context).dividerColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(1.1),
                    2: FlexColumnWidth(1.6),
                    3: FlexColumnWidth(1.6),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : const Color(0xFFF1F5F9)),
                      children: const [
                        Padding(padding: EdgeInsets.all(6), child: Text('本金', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Padding(padding: EdgeInsets.all(6), child: Text('2%风险', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Padding(padding: EdgeInsets.all(6), child: Text('标准双单', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Padding(padding: EdgeInsets.all(6), child: Text('微型双单(Micro)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      ],
                    ),
                    _buildTableRow('\$500', '\$10', '0.01 + 0.01', '0.10 + 0.10 (优)'),
                    _buildTableRow('\$1,000', '\$20', '0.02 + 0.02', '0.20 + 0.20'),
                    _buildTableRow('\$1,500', '\$30', '0.03 + 0.03', '0.30 + 0.30'),
                    _buildTableRow('\$2,000', '\$40', '0.04 + 0.04', '0.40 + 0.40'),
                    _buildTableRow('\$3,200', '\$64', '0.06 + 0.06', '0.64 + 0.64'),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('💡 提示：\$500 资金在标准账户下无法拆出 0.005 手，因此强烈建议 \$500 资金开设 Micro 微型账户以执行标准 1%+1% 分仓。', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String col1, String col2, String col3, String col4) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(6), child: Text(col1, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
        Padding(padding: const EdgeInsets.all(6), child: Text(col2, style: const TextStyle(fontSize: 10, color: Colors.red), textAlign: TextAlign.center)),
        Padding(padding: const EdgeInsets.all(6), child: Text(col3, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)), textAlign: TextAlign.center)),
        Padding(padding: const EdgeInsets.all(6), child: Text(col4, style: const TextStyle(fontSize: 10, color: Color(0xFF059669)), textAlign: TextAlign.center)),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// 3. 自动止盈报价生成器（重磅新增：黄金口袋 Fib 50%~61.8% 狙击入场模式）
// -------------------------------------------------------------

