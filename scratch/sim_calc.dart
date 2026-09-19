  class SurvivalSimulatorPage extends StatefulWidget {
  const SurvivalSimulatorPage({super.key});

  @override
  State<SurvivalSimulatorPage> createState() => _SurvivalSimulatorPageState();
}

class _SurvivalSimulatorPageState extends State<SurvivalSimulatorPage> {
  final TextEditingController _balCtrl = TextEditingController(text: '1000');
  final TextEditingController _winCtrl = TextEditingController(text: '50');
  final TextEditingController _riskCtrl = TextEditingController(text: '2');

  double startBal = 1000;
  double winRate = 50;
  double riskPct = 2;
  double rr = 2.0;
  bool simDualTrack = true;

  Map<String, dynamic>? simResult;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      startBal = prefs.getDouble('sim_bal') ?? 1000;
      winRate = prefs.getDouble('sim_win') ?? 50;
      riskPct = prefs.getDouble('sim_risk') ?? 2;
      rr = prefs.getDouble('sim_rr') ?? 2.0;
      simDualTrack = prefs.getBool('sim_dual') ?? true;

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
    double balance = startBal;
    double peak = startBal;
    double maxDrawdown = 0;
    int currentStreak = 0;
    int maxStreak = 0;
    bool blownUp = false;
    int blownUpMonth = -1;
    List<double> monthlyProfits = [];
    List<double> equityPoints = [startBal];

    Random rand = Random();

    for (int m = 1; m <= 12; m++) {
      double mStart = balance;
      for (int i = 0; i < 10; i++) {
        if (blownUp) continue;
        bool isWin = (rand.nextDouble() * 100) < winRate;
        double risk = balance * (riskPct / 100);
        if (isWin) {
          double payout = simDualTrack ? (risk / 2.0 * 1.0 + risk / 2.0 * rr) : (risk * rr);
          balance += payout;
          currentStreak = 0;
        } else {
          balance -= risk;
          currentStreak++;
          if (currentStreak > maxStreak) maxStreak = currentStreak;
        }
        if (balance > peak) peak = balance;
        double dd = ((peak - balance) / peak) * 100;
        if (dd > maxDrawdown) maxDrawdown = dd;
        if (dd >= 40 || balance <= 0) {
          if (!blownUp) {
            blownUp = true;
            blownUpMonth = m;
          }
          balance = 0;
        }
      }
      monthlyProfits.add(balance - mStart);
      equityPoints.add(balance);
    }

    setState(() {
      simResult = {
        'finalBal': balance,
        'maxStreak': maxStreak,
        'drawdown': maxDrawdown,
        'blownUp': blownUp,
        'blownUpMonth': blownUpMonth,
        'monthly': monthlyProfits,
        'equity': equityPoints,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  startBal = double.tryParse(v) ?? 1000;
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
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: SwitchListTile(
            title: const Text('执行双轨分仓 (1%+1%)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text(simDualTrack ? '盈利计算: +1R (保本仓) + ${rr}R (波段仓)' : '盈利计算: 全仓单轨 +${rr}R', style: const TextStyle(fontSize: 12)),
            activeColor: const Color(0xFF059669),
            value: simDualTrack,
            onChanged: (v) {
              setState(() => simDualTrack = v);
              SharedPreferences.getInstance().then((p) => p.setBool('sim_dual', v));
            },
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: runSimulation,
          icon: const Icon(Icons.casino),
          label: const Text('🎲 运行 12 个月实战走势推演', style: TextStyle(fontWeight: FontWeight.bold)),
        ),

        if (simResult != null) ...[
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2))),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('12 个月后最终资金', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('\$${(simResult!['finalBal'] as double).toStringAsFixed(2)}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: simResult!['blownUp'] ? Colors.red : null)),
                  Text('≈ RM ${((simResult!['finalBal'] as double) * 4.5).toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  if (simResult!['blownUp'] as bool? ?? false) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
                          const SizedBox(width: 4),
                          Text(
                            simResult!['blownUpMonth'] != null && simResult!['blownUpMonth'] > 0
                                ? '已触发 40% 回撤熔断（第 ${simResult!['blownUpMonth']} 月爆仓清算，后续已停止交易）'
                                : '已触发 40% 回撤风控熔断（爆仓清算）',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('最大连亏', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('${simResult!['maxStreak']} 次', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('资金最大回撤', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('${(simResult!['drawdown'] as double).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('📈 资金净值走势曲线 (Equity Curve):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 140,
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      painter: EquityCurvePainter(
                        points: simResult!['equity'] as List<double>,
                        isBlownUp: simResult!['blownUp'] as bool,
                        isDark: Theme.of(context).brightness == Brightness.dark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('📅 逐月利润拆解:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(12, (idx) {
                      final val = (simResult!['monthly'] as List<double>)[idx];
                      final bool isBlownUp = simResult!['blownUp'] as bool? ?? false;
                      final int blownUpMonth = simResult!['blownUpMonth'] as int? ?? -1;
                      final bool isAfterBlownUp = isBlownUp && blownUpMonth != -1 && (idx + 1) > blownUpMonth;

                      final isDark = Theme.of(context).brightness == Brightness.dark;

                      Color bgColor;
                      Color borderColor;
                      Color textColor;
                      String textStr;

                      if (isAfterBlownUp || val == 0) {
                        // 爆仓后月份或零损益月份：纯灰色
                        bgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
                        borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
                        textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
                        textStr = '\$0';
                      } else if (val > 0) {
                        // 盈利月份：绿色
                        bgColor = isDark ? const Color(0xFF064E3B).withOpacity(0.3) : const Color(0xFFF0FDF4);
                        borderColor = isDark ? const Color(0xFF059669).withOpacity(0.4) : const Color(0xFFBBF7D0);
                        textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF15803D);
                        textStr = '+\$${val.toStringAsFixed(0)}';
                      } else {
                        // 亏损月份：红色（负号在美元符号前：-$xxx）
                        bgColor = isDark ? const Color(0xFF7F1D1D).withOpacity(0.3) : const Color(0xFFFEF2F2);
                        borderColor = isDark ? const Color(0xFFDC2626).withOpacity(0.4) : const Color(0xFFFECACA);
                        textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
                        textStr = '-\$${val.abs().toStringAsFixed(0)}';
                      }

                      return Container(
                        width: (MediaQuery.of(context).size.width - 96) / 4,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${idx + 1}月',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isAfterBlownUp ? FontWeight.normal : FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            Text(
                              textStr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// -------------------------------------------------------------
// 资金曲线绘制器 (CustomPainter)
// -------------------------------------------------------------
class EquityCurvePainter extends CustomPainter {
  final List<double> points;
  final bool isBlownUp;
  final bool isDark;

  EquityCurvePainter({required this.points, required this.isBlownUp, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    double maxVal = points.reduce(max);
    double minVal = points.reduce(min);
    if (maxVal == minVal) {
      maxVal += 100;
      minVal -= 100;
    }
    double range = maxVal - minVal;

    final paintLine = Paint()
      ..color = isBlownUp ? const Color(0xFFDC2626) : const Color(0xFF10B981)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isBlownUp ? const Color(0xFFDC2626) : const Color(0xFF10B981)).withOpacity(0.3),
          Colors.transparent,
        ],
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

    final dotPaint = Paint()..color = isBlownUp ? Colors.red : const Color(0xFF10B981);
    double endX = size.width;
    double endY = size.height - ((points.last - minVal) / range) * (size.height - 20) - 10;
    canvas.drawCircle(Offset(endX, endY), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 通用卡片横幅
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
