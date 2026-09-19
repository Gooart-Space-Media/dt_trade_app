import 'dart:io';

void main() {
  String code = File('lib/main.dart').readAsStringSync();

  // 1. Rewrite _buildResultCard with 2-column stats layout
  String newCard = r'''
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('\$${finalBal.toStringAsFixed(0)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: valueColor)),
              const SizedBox(width: 8),
              Text('≈ RM ${(finalBal * 4.5).toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, thickness: 1)),
          Row(
            children: [
              Expanded(child: _statItem('单笔最大风控', maxRisk, isBlownUp ? const Color(0xFFDC2626) : color)),
              const SizedBox(width: 8),
              Expanded(child: _statItem('最大回撤', '${drawdown.toStringAsFixed(1)}%', ddColor)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _statItem('破产熔断率', '${blowRate.toStringAsFixed(1)}%', brColor)),
              const SizedBox(width: 8),
              Expanded(child: _statItem('最大连亏', '$maxStreak 次', Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey))),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
''';

  // 2. Rewrite rightPanel to put tip box LEFT of chart (side by side)
  String newRightPanel = r'''
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Tip box
                    Container(
                      width: 160,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡 概率论破局真相', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF312E81))),
                          const SizedBox(height: 6),
                          const Text(
                            '传统单轨交易最致命的心态痛点是浮盈 1.5R 却侧漏翻车扫损。而 DT 双轨战法通过 Trade 1 提前落袋保本 + Trade 2 零风险奔跑，将最大回撤显著压缩，从数学概率底层彻底消灭爆仓！',
                            style: TextStyle(fontSize: 10, color: Color(0xFF312E81), height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right: Chart
                    Expanded(
                      child: Container(
                        height: 180,
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: const [
                    Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                    SizedBox(width: 6),
                    Text('逐月利润拆解 (DT 双轨):', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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
''';

  var lines = code.split('\n');

  // Find and replace _buildResultCard + _row
  int cardStart = -1;
  int cardEnd = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Widget _buildResultCard(')) { cardStart = i; }
    if (cardStart != -1 && i > cardStart && lines[i].contains('Widget _row(')) { cardEnd = i; break; }
  }

  // Find and replace rightPanel
  int rightStart = -1;
  int rightEnd = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Widget rightPanel = ')) { rightStart = i; }
    if (rightStart != -1 && i > rightStart + 5) {
      // Find the matching line that starts the desktop layout section
      if (lines[i].trimLeft().startsWith('if (isDesktop)')) { rightEnd = i; break; }
    }
  }

  if (cardStart == -1 || cardEnd == -1 || rightStart == -1 || rightEnd == -1) {
    print('ERROR: cardStart=$cardStart cardEnd=$cardEnd rightStart=$rightStart rightEnd=$rightEnd');
    return;
  }

  print('cardStart=$cardStart cardEnd=$cardEnd rightStart=$rightStart rightEnd=$rightEnd');

  // Build final code:
  // 1. Everything before rightPanel
  // 2. New rightPanel
  // 3. Everything from isDesktop to cardStart
  // 4. New card + _statItem
  // 5. Everything after _row (skip old _row since we replace it with _statItem)

  // Actually, let's keep _row for other uses and just add _statItem
  // But we need to be careful. Let me just replace the two sections.

  // Replace rightPanel section
  String part1 = lines.sublist(0, rightStart).join('\n');
  String part2 = lines.sublist(rightEnd).join('\n'); // from isDesktop onwards
  String codeWithNewRight = part1 + '\n' + newRightPanel + '\n' + part2;

  // Now replace _buildResultCard in the updated code
  lines = codeWithNewRight.split('\n');
  cardStart = -1;
  cardEnd = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Widget _buildResultCard(')) { cardStart = i; }
    if (cardStart != -1 && i > cardStart && lines[i].contains('Widget _row(')) { cardEnd = i; break; }
  }

  if (cardStart == -1 || cardEnd == -1) {
    print('ERROR after right panel replace: cardStart=$cardStart cardEnd=$cardEnd');
    return;
  }

  String finalCode = lines.sublist(0, cardStart).join('\n') + '\n' + newCard + '\n' + lines.sublist(cardEnd).join('\n');
  File('lib/main.dart').writeAsStringSync(finalCode);
  print('Done — ResultCard 2-column layout + side-by-side tip/chart.');
}
