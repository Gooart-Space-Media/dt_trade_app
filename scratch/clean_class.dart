class _OverlapCheckerPageState extends State<OverlapCheckerPage> {
  final List<String> corePairs = kWatchlistPairs.where((p) => p.isCore).map((p) => p.symbol).toList();
  final List<String> minorPairs = kWatchlistPairs.where((p) => p.isMinor).map((p) => p.symbol).toList();
  final List<String> observedPairs = kWatchlistPairs.where((p) => p.category == 'observed').map((p) => p.symbol).toList();

  String? s1;
  String? s2;
  String? s3;

  String dir1 = '多';
  String dir2 = '多';

  String dir3 = '多';
  List<bool> checklist = [false, false, false, false];
  List<bool> checklist = [false, false, false, false];


  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      s1 = prefs.getString('ol_s1');
      s2 = prefs.getString('ol_s2');
      s3 = prefs.getString('ol_s3');
      dir1 = prefs.getString('ol_d1') ?? '多';
      dir2 = prefs.getString('ol_d2') ?? '多';
      dir3 = prefs.getString('ol_d3') ?? '多';
    });
  }

  Future<void> _saveState(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }


  bool isConflict(String pair, List<String?> selectedOthers) {
    String base = pair.substring(0, 3);
    String quote = pair.substring(3, 6);
    for (var other in selectedOthers) {
      if (other != null && other.isNotEmpty) {
        if (other.contains(base) || other.contains(quote)) return true;
      }
    }
    return false;
  }

  // 晨间 10 秒单向敞口自审算法 (检测同质化做空/做多 USD 或 JPY)
  Map<String, dynamic> _auditCorrelation() {
    final trades = [
      if (s1 != null) {'pair': s1!, 'dir': dir1},
      if (s2 != null) {'pair': s2!, 'dir': dir2},
      if (s3 != null) {'pair': s3!, 'dir': dir3},
    ];

    if (trades.length < 2) {
      return {'hasRisk': false, 'msg': '选择 2~3 个品种后，系统将自动自审同向汇率共振风险。'};
    }

    int usdShortCount = 0;
    int usdLongCount = 0;

    for (var t in trades) {
      final p = t['pair'] as String;
      final isBuy = t['dir'] == '多';

      if (p == 'EURUSD' || p == 'GBPUSD' || p == 'AUDUSD' || p == 'NZDUSD' || p == 'XAUUSD') {
        if (isBuy) usdShortCount++; else usdLongCount++;
      } else if (p == 'USDJPY' || p == 'USDCAD' || p == 'USDCHF') {
        if (isBuy) usdLongCount++; else usdShortCount++;
      }
    }

    if (usdShortCount >= 3) {
      return {
        'hasRisk': true,
        'msg': '⚠️ 危险重叠！当前 3 笔交易全部在单向【做空美元 (Short USD)】！属于同质化单向敞口，若非农/CPI数据强劲，将遭遇 6% 连环爆仓回撤！建议拆解或换交叉盘。'
      };
    } else if (usdLongCount >= 3) {
      return {
        'hasRisk': true,
        'msg': '⚠️ 危险重叠！当前 3 笔交易全部在单向【做多美元 (Long USD)】！一旦美元反转将全部止损，建议降低同质化敞口。'
      };
    }

    return {
      'hasRisk': false,
      'msg': '✅ 晨间 10 秒自审通过：3 笔交易不存在单向同质化敞口，结构独立，可安全同时建仓（总日风险控制在 6% 内）！'
    };
  }

  void _showAvoidListDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🚫 坚决规避的毒药品种 (The Avoid List)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 10),
              const Text('以下四类品种在实战中看似有机会，实则暗藏点差与政策陷阱，强烈建议拉黑跳过：', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const Divider(height: 20),
              Expanded(
                child: ListView(
                  children: const [
                    _AvoidCard(title: '1. 联系汇率挂钩类 (画直线)', pairs: 'EURDKK, USDHKD, EURHKD, USDDKK, GBPDKK', reason: '受央行强行挂钩制度约束，K线基本为水平直线，日波动甚至小于点差，毫无交易价值。'),
                    _AvoidCard(title: '2. 高息吃人断崖类 (点差过宽)', pairs: 'USDTRY, EURTRY, USDZAR, EURZAR, USDMXN', reason: '新兴市场货币恶性贬值，看似单边躺赚，但隔夜利息极其昂贵且极易发生政策跳空，利润全被磨光。'),
                    _AvoidCard(title: '3. 极低流动性类 (严重滑点)', pairs: 'GBPSEK, GBPNOK, CHFSGD, NZDSGD, GBPSGD', reason: '挂单成交极不活跃，止损往往无法在预设点位成交，遭遇极端滑点击穿账户。'),
                    _AvoidCard(title: '4. 恶劣交叉盘规避', pairs: 'GBPNZD', reason: '虽然日均波幅极大，但点差同样极其昂贵，盈利空间往往刚好抵消高额交易成本。'),
                  ],
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
    final allPairs = [...corePairs, ...minorPairs, ...observedPairs];
    bool isComplete = (s1 != null && s2 != null && s3 != null);
    final audit = _auditCorrelation();

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🛡️ 多单并行防呆与自审', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Row(
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 6)),
                  onPressed: () => showWatchlistAtlasDialog(context),
                  icon: const Icon(Icons.menu_book_rounded, size: 15, color: Color(0xFF2563EB)),
                  label: const Text('16品种图鉴', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 6)),
                  onPressed: _showAvoidListDialog,
                  icon: const Icon(Icons.warning_amber_rounded, size: 15, color: Colors.red),
                  label: const Text('毒药黑名单', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.stars_rounded, size: 16, color: Color(0xFFD97706)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  '规范选项：⭐ 7大核心货币对 (极低点差) + 🔹 9大次要交叉盘',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              InkWell(
                onTap: () => showWatchlistAtlasDialog(context),
                child: const Text('详解 >', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        _buildDropdownRow('交易 1 (首选主线)', s1, dir1, allPairs, [], (p) => setState(() { s1 = p; s2 = null; s3 = null; }), (d) => setState(() => dir1 = d)),
        const SizedBox(height: 10),
        _buildDropdownRow('交易 2 (独立隔离)', s2, dir2, allPairs, [s1], (p) => setState(() { s2 = p; s3 = null; }), (d) => setState(() => dir2 = d)),
        const SizedBox(height: 10),
        _buildDropdownRow('交易 3 (独立隔离)', s3, dir3, allPairs, [s1, s2], (p) => setState(() => s3 = p), (d) => setState(() => dir3 = d)),
        const SizedBox(height: 16),

        // 晨间 10 秒单向敞口自审雷达卡片
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (audit['hasRisk'] as bool) ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: (audit['hasRisk'] as bool) ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon((audit['hasRisk'] as bool) ? Icons.warning_rounded : Icons.radar_rounded, size: 18, color: (audit['hasRisk'] as bool) ? Colors.red : const Color(0xFF15803D)),
                  const SizedBox(width: 6),
                  Text((audit['hasRisk'] as bool) ? '晨间自审预警：同质化过度曝险' : '晨间 10 秒风控自审雷达', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: (audit['hasRisk'] as bool) ? Colors.red : const Color(0xFF15803D))),
                ],
              ),
              const SizedBox(height: 4),
              Text(audit['msg'] as String, style: TextStyle(fontSize: 11, height: 1.4, color: (audit['hasRisk'] as bool) ? const Color(0xFF991B1B) : const Color(0xFF166534))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(int index) {
    final titles = [
      '日内无重大数据发布 (如非农、CPI等核弹级数据)',
      '情绪绝对平稳，未受上笔交易 (大赚/大亏) 的 FOMO 影响',
      '严格遵循 DT 双轨制，已预设 Trade 1 的保本与止盈',
      '单笔总风险严格控制在 2% 内，绝不抱有重仓扛单侥幸'
    ];
    bool isChecked = checklist[index];
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => checklist[index] = !checklist[index]);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isChecked ? const Color(0xFFF0FDF4) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isChecked ? const Color(0xFF4ADE80) : Theme.of(context).dividerColor.withOpacity(0.2)),
          boxShadow: isChecked ? [BoxShadow(color: const Color(0xFF4ADE80).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF22C55E) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isChecked ? const Color(0xFF22C55E) : Colors.grey.shade400, width: 2),
              ),
              child: isChecked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titles[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                  color: isChecked ? const Color(0xFF166534) : const Color(0xFF475569),
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildChecklistItem(int index) {
    final titles = [
      '日内无重大数据发布 (如非农、CPI等核弹级数据)',
      '情绪绝对平稳，未受上笔交易 (大赚/大亏) 的 FOMO 影响',
      '严格遵循 DT 双轨制，已预设 Trade 1 的保本与止盈',
      '单笔总风险严格控制在 2% 内，绝不抱有重仓扛单侥幸'
    ];
    bool isChecked = checklist[index];
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => checklist[index] = !checklist[index]);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isChecked ? const Color(0xFFF0FDF4) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isChecked ? const Color(0xFF4ADE80) : Theme.of(context).dividerColor.withOpacity(0.2)),
          boxShadow: isChecked ? [BoxShadow(color: const Color(0xFF4ADE80).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF22C55E) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isChecked ? const Color(0xFF22C55E) : Colors.grey.shade400, width: 2),
              ),
              child: isChecked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titles[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                  color: isChecked ? const Color(0xFF166534) : const Color(0xFF475569),
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow(String label, String? current, String dir, List<String> list, List<String?> others, ValueChanged<String?> onPairChanged, ValueChanged<String> onDirChanged) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('选择品种 (标注核心/次要)'),
                    value: current,
                    selectedItemBuilder: (ctx) {
                      return list.map((pairSymbol) {
                        final pair = getWatchlistPair(pairSymbol);
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: pair.isCore
                                      ? const Color(0xFFFEF3C7)
                                      : (pair.isGold ? const Color(0xFFFDE68A) : const Color(0xFFEFF6FF)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  pair.categoryLabel,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: pair.isCore
                                        ? const Color(0xFFB45309)
                                        : (pair.isGold ? const Color(0xFF92400E) : const Color(0xFF1D4ED8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(pair.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(width: 3),
                              Text('(${pair.chineseName})', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    items: list.map((pairSymbol) {
                      final pair = getWatchlistPair(pairSymbol);
                      bool conflict = isConflict(pairSymbol, others);
                      return DropdownMenuItem<String>(
                        value: conflict ? null : pairSymbol,
                        enabled: !conflict,
                        child: Row(
                          children: [
                            if (conflict) ...[
                              Text('🚫 $pairSymbol (关联货币冲突)', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: pair.isCore
                                      ? const Color(0xFFFEF3C7)
                                      : (pair.isGold ? const Color(0xFFFDE68A) : const Color(0xFFEFF6FF)),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: pair.isCore
                                        ? const Color(0xFFF59E0B)
                                        : (pair.isGold ? const Color(0xFFD97706) : const Color(0xFF60A5FA)),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  pair.categoryLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: pair.isCore
                                        ? const Color(0xFFB45309)
                                        : (pair.isGold ? const Color(0xFF92400E) : const Color(0xFF1D4ED8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(pair.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 4),
                              Text('(${pair.chineseName})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: onPairChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ToggleButtons(
              isSelected: [dir == '多', dir == '空'],
              borderRadius: BorderRadius.circular(8),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 28),
              selectedColor: Colors.white,
              fillColor: dir == '多' ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              onPressed: (index) {
                HapticFeedback.lightImpact();
                onDirChanged(index == 0 ? '多' : '空');
              },
              children: const [
                Text('多', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('空', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}