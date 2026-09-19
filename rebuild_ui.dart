import 'dart:io';

void main() {
  String code = File('lib/main.dart').readAsStringSync();

  String newBuild = r'''
  Widget build(BuildContext context) {
    double riskAmount = startBal * (riskPct / 100);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 800;

        // ═══════════════════════════════════════
        // 1. Top Controls (Banner + Inputs + Button) — 100% width
        // ═══════════════════════════════════════
        final topControls = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBanner(
              icon: Icons.insights,
              title: '蒙特卡洛 12 个月复利与走势演练',
              desc: '用客观概率打破赌徒侥幸心理。模拟连续12个月后资金曲线，直观感受风控红线的威力和回撤规律。',
              color: const Color(0xFFE11D48),
            ),
            const SizedBox(height: 12),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _balCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        labelText: '初始本金 (USD)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (v) {
                        startBal = double.tryParse(v) ?? 700;
                        SharedPreferences.getInstance().then((p) => p.setDouble('sim_bal', startBal));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _winCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        labelText: '交易胜率 (%)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (v) {
                        winRate = double.tryParse(v) ?? 50;
                        SharedPreferences.getInstance().then((p) => p.setDouble('sim_win', winRate));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _riskCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        labelText: '单笔总风险 (%)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (v) {
                        riskPct = double.tryParse(v) ?? 2;
                        SharedPreferences.getInstance().then((p) => p.setDouble('sim_risk', riskPct));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      isExpanded: true,
                      value: rr,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        labelText: '基础盈亏比',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1.0, child: Text('1:1 (保守)')),
                        DropdownMenuItem(value: 1.5, child: Text('1:1.5 (稳健)')),
                        DropdownMenuItem(value: 2.0, child: Text('1:2 (标准)')),
                        DropdownMenuItem(value: 3.0, child: Text('1:3 (极佳)')),
                      ],
                      onChanged: (v) {
                        setState(() => rr = v ?? 2.0);
                        SharedPreferences.getInstance().then((p) => p.setDouble('sim_rr', rr));
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 40,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: const Color(0xFF475569),
                      ),
                      onPressed: runSimulation,
                      icon: const Icon(Icons.casino, size: 18),
                      label: const Text('运行实战推演', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _balCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), labelText: '本金(USD)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        onChanged: (v) { startBal = double.tryParse(v) ?? 700; SharedPreferences.getInstance().then((p) => p.setDouble('sim_bal', startBal)); },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _winCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), labelText: '胜率(%)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        onChanged: (v) { winRate = double.tryParse(v) ?? 50; SharedPreferences.getInstance().then((p) => p.setDouble('sim_win', winRate)); },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _riskCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), labelText: '风险(%)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        onChanged: (v) { riskPct = double.tryParse(v) ?? 2; SharedPreferences.getInstance().then((p) => p.setDouble('sim_risk', riskPct)); },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        isExpanded: true, value: rr,
                        decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), labelText: '盈亏比', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        items: const [ DropdownMenuItem(value: 1.0, child: Text('1:1')), DropdownMenuItem(value: 1.5, child: Text('1:1.5')), DropdownMenuItem(value: 2.0, child: Text('1:2')), DropdownMenuItem(value: 3.0, child: Text('1:3')) ],
                        onChanged: (v) { setState(() => rr = v ?? 2.0); SharedPreferences.getInstance().then((p) => p.setDouble('sim_rr', rr)); },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), backgroundColor: const Color(0xFF475569)),
                    onPressed: runSimulation, icon: const Icon(Icons.casino),
                    label: const Text('🎲 运行 12 个月实战走势推演', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
          ],
        );

        // ═══════════════════════════════════════
        // 2. Left Panel — Comparison Cards
        // ═══════════════════════════════════════
        Widget leftPanel = Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.compare_arrows, color: Colors.blueAccent, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('双轨分仓 vs 传统单轨 12个月实战对比', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: const Text('DT 终极抗风险', style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.blueAccent.withOpacity(0.08),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.blueAccent, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '演练生效参数：单笔总风控 ${riskPct.toStringAsFixed(0)}% (\$${riskAmount.toStringAsFixed(0)}) - DT双轨拆分为 2x${(riskPct/2).toStringAsFixed(1)}% (各\$${(riskAmount/2).toStringAsFixed(0)}) · 初始本金 \$${startBal.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildResultCard(
                        title: 'DT 双轨 (2x${(riskPct/2).toStringAsFixed(1)}% = ${riskPct.toStringAsFixed(0)}%)',
                        subtitle: '风控: \$${riskAmount.toStringAsFixed(0)} (A:\$${(riskAmount/2).toStringAsFixed(0)}+B:\$${(riskAmount/2).toStringAsFixed(0)})',
                        finalBal: simResult!['dtFinal'],
                        maxRisk: '\$${riskAmount.toStringAsFixed(0)} (${riskPct.toStringAsFixed(0)}%)',
                        drawdown: simResult!['dtDrawdown'],
                        blowRate: simResult!['dtBlowRate'],
                        maxStreak: simResult!['dtMaxStreak'],
                        color: const Color(0xFF10B981),
                        isBlownUp: simResult!['dtBlownUp'],
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildResultCard(
                        title: '传统单轨 (1x${riskPct.toStringAsFixed(0)}%)',
                        subtitle: '单笔死扛风控: \$${riskAmount.toStringAsFixed(0)} (无保本)',
                        finalBal: simResult!['stFinal'],
                        maxRisk: '\$${riskAmount.toStringAsFixed(0)} (${riskPct.toStringAsFixed(0)}%)',
                        drawdown: simResult!['stDrawdown'],
                        blowRate: simResult!['stBlowRate'],
                        maxStreak: simResult!['stMaxStreak'],
                        color: const Color(0xFF8B5CF6),
                        isBlownUp: simResult!['stBlownUp'],
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        // ═══════════════════════════════════════
        // 3. Right Panel — Chart + Tip + Grid
        // ═══════════════════════════════════════
        Widget rightPanel = Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.show_chart, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Expanded(child: Text('资金净值走势对比 (Dual Equity Curve)', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))),
                    _buildLegend(const Color(0xFF10B981), '双轨分仓'),
                    const SizedBox(width: 12),
                    _buildLegend(const Color(0xFF8B5CF6), '传统单轨'),
                  ],
                ),
              ),
              Container(
                height: 180,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  painter: DualEquityCurvePainter(
                    dtPoints: simResult!['dtEquity'] as List<double>,
                    stPoints: simResult!['stEquity'] as List<double>,
                    dtBlownUp: simResult!['dtBlownUp'] as bool,
                    stBlownUp: simResult!['stBlownUp'] as bool,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 12, color: Color(0xFF312E81), height: 1.4),
                          children: [
                            TextSpan(text: '概率论破局真相：', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '传统单轨交易最致命的心态痛点是浮盈 1.5R 却侧漏翻车扫损。而 DT 双轨战法通过 Trade 1 提前落袋保本 + Trade 2 零风险奔跑，将最大回撤显著压缩，从数学概率底层彻底消灭爆仓！'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: const [
                    Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                    SizedBox(width: 6),
                    Text('逐月利润拆解 (DT 双轨):', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: LayoutBuilder(
                  builder: (context, gridConstraints) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(12, (idx) {
                        final val = (simResult!['dtMonthly'] as List<double>)[idx];
                        Color bgColor, borderColor, textColor;
                        String textStr;
                        if (val == 0) {
                          bgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
                          borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
                          textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
                          textStr = '-';
                        } else if (val > 0) {
                          bgColor = isDark ? const Color(0xFF064E3B).withOpacity(0.3) : const Color(0xFFF0FDF4);
                          borderColor = isDark ? const Color(0xFF059669).withOpacity(0.4) : const Color(0xFFBBF7D0);
                          textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF15803D);
                          textStr = '+\$${val.toStringAsFixed(0)}';
                        } else {
                          bgColor = isDark ? const Color(0xFF7F1D1D).withOpacity(0.3) : const Color(0xFFFEF2F2);
                          borderColor = isDark ? const Color(0xFFDC2626).withOpacity(0.4) : const Color(0xFFFECACA);
                          textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
                          textStr = '-\$${val.abs().toStringAsFixed(0)}';
                        }
                        return Container(
                          width: (gridConstraints.maxWidth - 24) / 4,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: borderColor)),
                          child: Column(
                            children: [
                              Text('月', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                              const SizedBox(height: 2),
                              Text(textStr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: textColor)),
                            ],
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        );

        // ═══════════════════════════════════════
        // 4. Assemble Layout
        // ═══════════════════════════════════════
        if (isDesktop) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                topControls,
                if (simResult != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: leftPanel),
                      const SizedBox(width: 16),
                      Expanded(child: rightPanel),
                    ],
                  ),
                ],
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                topControls,
                if (simResult != null) ...[
                  const SizedBox(height: 16),
                  leftPanel,
                  const SizedBox(height: 16),
                  rightPanel,
                ],
              ],
            ),
          );
        }
      },
    );
  }
''';

  // Also fix _buildResultCard — remove Spacer, use normal spacing
  String cardFix = r'''
  Widget _buildResultCard({
    required String title,
    required String subtitle,
    required double finalBal,
    required String maxRisk,
    required double drawdown,
    required double blowRate,
    required int maxStreak,
    required Color color,
    required bool isBlownUp,
    required bool isDark,
  }) {
    Color valueColor = isBlownUp ? const Color(0xFFDC2626) : color;
    Color ddColor = drawdown > 30 ? const Color(0xFFDC2626) : (drawdown > 15 ? Colors.orange : const Color(0xFF10B981));
    Color brColor = blowRate > 0 ? const Color(0xFFDC2626) : const Color(0xFF10B981);
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Expanded(child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color))),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 12),
          Text('\$${finalBal.toStringAsFixed(0)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: valueColor)),
          Text('≈ RM ${(finalBal * 4.5).toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, thickness: 1)),
          _row('单笔最大风控', maxRisk, isBlownUp ? const Color(0xFFDC2626) : color),
          const SizedBox(height: 6),
          _row('最大回撤', '${drawdown.toStringAsFixed(1)}%', ddColor),
          const SizedBox(height: 6),
          _row('破产熔断率', '${blowRate.toStringAsFixed(1)}%', brColor),
          const SizedBox(height: 6),
          _row('最大连亏', '$maxStreak 次', Colors.grey),
        ],
      ),
    );
  }
''';

  var lines = code.split('\n');

  // Find build method
  int buildStart = -1;
  int buildEnd = -1;
  for (int i = 3700; i < lines.length; i++) {
    if (lines[i].contains('Widget build(BuildContext context) {')) { buildStart = i; }
    if (buildStart != -1 && lines[i].contains('Widget _buildLegend(')) { buildEnd = i; break; }
  }

  // Find _buildResultCard
  int cardStart = -1;
  int cardEnd = -1;
  for (int i = buildEnd; i < lines.length; i++) {
    if (lines[i].contains('Widget _buildResultCard(')) { cardStart = i; }
    if (cardStart != -1 && lines[i].contains('Widget _row(')) { cardEnd = i; break; }
  }

  if (buildStart == -1 || buildEnd == -1 || cardStart == -1 || cardEnd == -1) {
    print('ERROR: Could not find markers. buildStart=$buildStart buildEnd=$buildEnd cardStart=$cardStart cardEnd=$cardEnd');
    return;
  }

  print('buildStart=$buildStart buildEnd=$buildEnd cardStart=$cardStart cardEnd=$cardEnd');

  String finalCode = lines.sublist(0, buildStart).join('\n')
      + '\n' + newBuild + '\n'
      + lines.sublist(buildEnd, cardStart).join('\n')
      + '\n' + cardFix + '\n'
      + lines.sublist(cardEnd).join('\n');

  File('lib/main.dart').writeAsStringSync(finalCode);
  print('Done — build method and _buildResultCard fully rewritten.');
}
