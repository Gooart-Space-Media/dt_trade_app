import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurvivalSimulatorPage extends StatefulWidget {
  const SurvivalSimulatorPage({super.key});

  @override
  State<SurvivalSimulatorPage> createState() => _SurvivalSimulatorPageState();
}

class _SurvivalSimulatorPageState extends State<SurvivalSimulatorPage> {
  final TextEditingController _balCtrl = TextEditingController(text: '700');
  final TextEditingController _winCtrl = TextEditingController(text: '50');
  final TextEditingController _riskCtrl = TextEditingController(text: '2');

  double startBal = 700;
  double winRate = 50;
  double riskPct = 2;
  double rr = 2.0;

  Map<String, dynamic>? simResult;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      startBal = prefs.getDouble('sim_bal') ?? 700;
      winRate = prefs.getDouble('sim_win') ?? 50;
      riskPct = prefs.getDouble('sim_risk') ?? 2;
      rr = prefs.getDouble('sim_rr') ?? 2.0;

      _balCtrl.text = startBal.toStringAsFixed(0);
      _winCtrl.text = winRate.toStringAsFixed(0);
      _riskCtrl.text = riskPct.toStringAsFixed(0);
    });
    if (simResult == null) {
      runSimulation();
    }
  }

  void runSimulation() {
    HapticFeedback.mediumImpact();
    
    // Calculate blown up rate with monte carlo (1000 iterations of 120 trades)
    int blownUpDtCount = 0;
    int blownUpStCount = 0;
    Random rand = Random();

    for (int sim = 0; sim < 1000; sim++) {
      double balDt = startBal;
      double balSt = startBal;
      double peakDt = startBal;
      double peakSt = startBal;
      bool blowDt = false;
      bool blowSt = false;

      // Pre-generate 120 wins/losses for fair comparison in this monte carlo run
      List<bool> simWins = List.generate(120, (_) => (rand.nextDouble() * 100) < winRate);

      for (int i = 0; i < 120; i++) {
        bool isWin = simWins[i];
        if (!blowDt) {
          double riskDt = balDt * (riskPct / 100);
          if (isWin) {
            balDt += (riskDt / 2.0 * 1.0) + (riskDt / 2.0 * rr);
          } else {
            balDt -= riskDt;
          }
          if (balDt > peakDt) peakDt = balDt;
          double dd = ((peakDt - balDt) / peakDt) * 100;
          if (dd >= 40 || balDt <= 0) blowDt = true;
        }
        if (!blowSt) {
          double riskSt = balSt * (riskPct / 100);
          if (isWin) {
            balSt += riskSt * rr;
          } else {
            balSt -= riskSt;
          }
          if (balSt > peakSt) peakSt = balSt;
          double dd = ((peakSt - balSt) / peakSt) * 100;
          if (dd >= 40 || balSt <= 0) blowSt = true;
        }
      }
      if (blowDt) blownUpDtCount++;
      if (blowSt) blownUpStCount++;
    }

    // Actual simulation run (1 time) for chart and table
    List<bool> actualWins = List.generate(120, (_) => (rand.nextDouble() * 100) < winRate);

    double dtBalance = startBal;
    double stBalance = startBal;
    double dtPeak = startBal;
    double stPeak = startBal;
    double dtMaxDrawdown = 0;
    double stMaxDrawdown = 0;
    int dtCurrentStreak = 0;
    int stCurrentStreak = 0;
    int dtMaxStreak = 0;
    int stMaxStreak = 0;
    bool dtBlownUp = false;
    bool stBlownUp = false;

    List<double> dtMonthlyProfits = [];
    List<double> dtEquityPoints = [startBal];
    List<double> stEquityPoints = [startBal];

    int tradeIndex = 0;
    for (int m = 1; m <= 12; m++) {
      double mStartDt = dtBalance;
      for (int i = 0; i < 10; i++) {
        bool isWin = actualWins[tradeIndex++];
        
        // Dual Track Logic
        if (!dtBlownUp) {
          double riskDt = dtBalance * (riskPct / 100);
          if (isWin) {
            dtBalance += (riskDt / 2.0 * 1.0) + (riskDt / 2.0 * rr);
            dtCurrentStreak = 0;
          } else {
            dtBalance -= riskDt;
            dtCurrentStreak++;
            if (dtCurrentStreak > dtMaxStreak) dtMaxStreak = dtCurrentStreak;
          }
          if (dtBalance > dtPeak) dtPeak = dtBalance;
          double dd = ((dtPeak - dtBalance) / dtPeak) * 100;
          if (dd > dtMaxDrawdown) dtMaxDrawdown = dd;
          if (dd >= 40 || dtBalance <= 0) {
            dtBlownUp = true;
            dtBalance = 0;
          }
        }

        // Single Track Logic
        if (!stBlownUp) {
          double riskSt = stBalance * (riskPct / 100);
          if (isWin) {
            stBalance += riskSt * rr;
            stCurrentStreak = 0;
          } else {
            stBalance -= riskSt;
            stCurrentStreak++;
            if (stCurrentStreak > stMaxStreak) stMaxStreak = stCurrentStreak;
          }
          if (stBalance > stPeak) stPeak = stBalance;
          double dd = ((stPeak - stBalance) / stPeak) * 100;
          if (dd > stMaxDrawdown) stMaxDrawdown = dd;
          if (dd >= 40 || stBalance <= 0) {
            stBlownUp = true;
            stBalance = 0;
          }
        }
      }
      dtMonthlyProfits.add(dtBalance - mStartDt);
      dtEquityPoints.add(dtBalance);
      stEquityPoints.add(stBalance);
    }

    setState(() {
      simResult = {
        'dtFinal': dtBalance,
        'stFinal': stBalance,
        'dtMaxStreak': dtMaxStreak,
        'stMaxStreak': stMaxStreak,
        'dtDrawdown': dtMaxDrawdown,
        'stDrawdown': stMaxDrawdown,
        'dtBlownUp': dtBlownUp,
        'stBlownUp': stBlownUp,
        'dtBlowRate': (blownUpDtCount / 1000.0) * 100,
        'stBlowRate': (blownUpStCount / 1000.0) * 100,
        'dtMonthly': dtMonthlyProfits,
        'dtEquity': dtEquityPoints,
        'stEquity': stEquityPoints,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    double riskAmount = startBal * (riskPct / 100);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBanner(
          icon: Icons.insights,
          title: '蒙特卡洛 12 个月复利与走势演练',
          desc: '用客观概率打破赌徒侥幸心理。模拟连续12个月后资金曲线，直观感受风控红线的威力和回撤规律。',
          color: const Color(0xFFE11D48),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _balCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: '本金 (USD)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                onChanged: (v) {
                  startBal = double.tryParse(v) ?? 700;
                  SharedPreferences.getInstance().then((p) => p.setDouble('sim_bal', startBal));
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _winCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: '胜率 (%)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                onChanged: (v) {
                  winRate = double.tryParse(v) ?? 50;
                  SharedPreferences.getInstance().then((p) => p.setDouble('sim_win', winRate));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _riskCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: '单笔风险 (%)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                onChanged: (v) {
                  riskPct = double.tryParse(v) ?? 2;
                  SharedPreferences.getInstance().then((p) => p.setDouble('sim_risk', riskPct));
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<double>(
                value: rr,
                decoration: InputDecoration(labelText: '盈亏比 (RR)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFF475569),
          ),
          onPressed: runSimulation,
          icon: const Icon(Icons.casino),
          label: const Text('🎲 运行 12 个月实战走势推演', style: TextStyle(fontWeight: FontWeight.bold)),
        ),

        if (simResult != null) ...[
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.compare_arrows, color: Colors.blueAccent, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('双轨分仓 vs 传统单轨 12个月实战对比', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: const Text('DT 终极抗风险', style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: Colors.blueAccent.withOpacity(0.08),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.blueAccent, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '演练生效参数：单笔总风控 % (\{riskAmount.toStringAsFixed(0)}) - DT双轨拆分为 2x% (各\{(riskAmount/2).toStringAsFixed(0)}) · 初始本金 \{startBal.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 11, color: Colors.blueAccent, fontWeight: FontWeight.w600),
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
                          title: 'DT 双轨 (2x% = %)',
                          subtitle: '风控: \{riskAmount.toStringAsFixed(0)} (A:\{(riskAmount/2).toStringAsFixed(0)}+B:\{(riskAmount/2).toStringAsFixed(0)})',
                          finalBal: simResult!['dtFinal'],
                          maxRisk: '\{riskAmount.toStringAsFixed(0)} (%)',
                          drawdown: simResult!['dtDrawdown'],
                          blowRate: simResult!['dtBlowRate'],
                          maxStreak: simResult!['dtMaxStreak'],
                          color: const Color(0xFF10B981),
                          isBlownUp: simResult!['dtBlownUp'],
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildResultCard(
                          title: '传统单轨 (1x%)',
                          subtitle: '单笔死扛风控: \{riskAmount.toStringAsFixed(0)} (无保本)',
                          finalBal: simResult!['stFinal'],
                          maxRisk: '\{riskAmount.toStringAsFixed(0)} (%)',
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.show_chart, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('资金净值走势对比 (Dual Equity Curve):', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const Spacer(),
                      _buildLegend(const Color(0xFF10B981), '双轨分仓'),
                      const SizedBox(width: 8),
                      _buildLegend(const Color(0xFF8B5CF6), '传统单轨'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 160,
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
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 11, color: Color(0xFF312E81), height: 1.4),
                            children: [
                              TextSpan(text: '概率论破局真相：', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '传统单轨交易最致命的心态痛点是浮盈 1.5R 却侧漏翻车扫损。而 DT 双轨战法通过 1:1 提前落袋保本 + Trade 2 零风险奔跑，将最大回撤显著压缩，从数学概率底层彻底消灭爆仓！'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: const [
                      Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('逐月利润拆解 (DT 双轨):', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(12, (idx) {
                      final val = (simResult!['dtMonthly'] as List<double>)[idx];
                      
                      Color bgColor;
                      Color borderColor;
                      Color textColor;
                      String textStr;

                      if (val == 0) {
                        bgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
                        borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
                        textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
                        textStr = '\';
                      } else if (val > 0) {
                        bgColor = isDark ? const Color(0xFF064E3B).withOpacity(0.3) : const Color(0xFFF0FDF4);
                        borderColor = isDark ? const Color(0xFF059669).withOpacity(0.4) : const Color(0xFFBBF7D0);
                        textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF15803D);
                        textStr = '+\{val.toStringAsFixed(0)}';
                      } else {
                        bgColor = isDark ? const Color(0xFF7F1D1D).withOpacity(0.3) : const Color(0xFFFEF2F2);
                        borderColor = isDark ? const Color(0xFFDC2626).withOpacity(0.4) : const Color(0xFFFECACA);
                        textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
                        textStr = '-\{val.abs().toStringAsFixed(0)}';
                      }

                      return Container(
                        width: (MediaQuery.of(context).size.width - 96) / 4,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            Text('月', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
                            Text(textStr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

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
      padding: const EdgeInsets.all(12),
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
              Expanded(child: Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color))),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('\{finalBal.toStringAsFixed(0)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: valueColor)),
          Text('≈ RM ', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, thickness: 1)),
          _row('单笔最大风控', maxRisk, isBlownUp ? const Color(0xFFDC2626) : color),
          const SizedBox(height: 4),
          _row('最大回撤', '%', ddColor),
          const SizedBox(height: 4),
          _row('破产熔断率', '%', brColor),
          const SizedBox(height: 4),
          _row('最大连亏', ' 次', Colors.grey),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color vColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: vColor)),
      ],
    );
  }

  Widget _buildBanner({required IconData icon, required String title, required String desc, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 11, color: color.withOpacity(0.85), height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DualEquityCurvePainter extends CustomPainter {
  final List<double> dtPoints;
  final List<double> stPoints;
  final bool dtBlownUp;
  final bool stBlownUp;

  DualEquityCurvePainter({
    required this.dtPoints,
    required this.stPoints,
    required this.dtBlownUp,
    required this.stBlownUp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dtPoints.isEmpty || stPoints.isEmpty) return;

    double maxVal = max(dtPoints.reduce(max), stPoints.reduce(max));
    double minVal = min(dtPoints.reduce(min), stPoints.reduce(min));
    if (maxVal == minVal) {
      maxVal += 100;
      minVal -= 100;
    }
    double range = maxVal - minVal;

    void drawLine(List<double> points, Color color, bool blownUp) {
      final paintLine = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      final paintFill = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.2), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;

      final path = Path();
      final fillPath = Path();

      for (int i = 0; i < points.length; i++) {
        double x = (i / (points.length - 1)) * size.width;
        double y = size.height - ((points[i] - minVal) / range) * (size.height - 20) - 10;

        if (i == 0) {
          path.moveTo(x, y);
          fillPath.moveTo(x, size.height);
          fillPath.lineTo(x, y);
        } else {
          path.lineTo(x, y);
          fillPath.lineTo(x, y);
        }
      }

      fillPath.lineTo(size.width, size.height);
      fillPath.close();

      canvas.drawPath(fillPath, paintFill);
      canvas.drawPath(path, paintLine);

      final dotPaint = Paint()..color = color;
      double endX = size.width;
      double endY = size.height - ((points.last - minVal) / range) * (size.height - 20) - 10;
      canvas.drawCircle(Offset(endX, endY), 4, dotPaint);
    }

    drawLine(stPoints, stBlownUp ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6), stBlownUp);
    drawLine(dtPoints, dtBlownUp ? const Color(0xFFEF4444) : const Color(0xFF10B981), dtBlownUp);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
