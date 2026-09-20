const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// 1. Insert _buildMantraCard and _buildBlueprintCard inside _TpCalculatorPageState
const targetMethodInsertion = '  Widget _buildCheckItem(String title, bool val, ValueChanged<bool?> onChanged) {';

const newMethods = `  Widget _buildMantraCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF451A03) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF9A3412) : const Color(0xFFFDBA74).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('吞没战法实战 3 句真诀 (必须刻在 DNA 里)：', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFFDBA74) : const Color(0xFF9A3412))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMantraLine(context, '1) 顺大势逆小势：', '只要大周期 (H4/D1) 没破位，小周期的逆向吞没直接无视！'),
          _buildMantraLine(context, '2) 必须吃掉前一根的实体：', '不能只包住引线，一定要实体包实体，越饱满越好！'),
          _buildMantraLine(context, '3) 不要追离均线太远的吞没：', '如果价格已经暴涨/暴跌偏离均线极远，这叫强弩之末，极易反抽！'),
        ],
      ),
    );
  }

  Widget _buildMantraLine(BuildContext context, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 11.5, height: 1.4, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF431407)),
          children: [
            TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: desc),
          ],
        ),
      ),
    );
  }

  Widget _buildBlueprintCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('🧲', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A)),
                    children: [
                      const TextSpan(text: '吞没结构与黄金口袋狙击蓝图 '),
                      TextSpan(text: '图中以做多(Buy) 为例，阴阳反包，回调寻找黄金坑狙击', style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 20, left: 100, right: 20,
                  child: Row(
                    children: [
                      const Expanded(child: _DashedLine(color: Color(0xFF22C55E))),
                      const SizedBox(width: 8),
                      Text('形态最高点 (Candle High)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF22C55E))),
                    ],
                  ),
                ),
                Positioned(
                  top: 70, left: 100, right: 20,
                  child: Row(
                    children: [
                      const Expanded(child: _DashedLine(color: Color(0xFFF59E0B))),
                      const SizedBox(width: 8),
                      Text('Fib 50% / 61.8% 黄金坑', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20, left: 100, right: 20,
                  child: Row(
                    children: [
                      const Expanded(child: _DashedLine(color: Color(0xFFEF4444))),
                      const SizedBox(width: 8),
                      Text('形态最低点 (Candle Low)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 25, left: 20,
                  child: Column(
                    children: [
                      Container(width: 2, height: 15, color: const Color(0xFFEF4444)),
                      Container(width: 14, height: 35, color: const Color(0xFFEF4444)),
                      Container(width: 2, height: 10, color: const Color(0xFFEF4444)),
                      const SizedBox(height: 4),
                      const Text('前 K', style: TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20, left: 60,
                  child: Column(
                    children: [
                      Container(width: 2, height: 10, color: const Color(0xFF22C55E)),
                      Container(width: 22, height: 95, color: const Color(0xFF22C55E)),
                      Container(width: 2, height: 15, color: const Color(0xFF22C55E)),
                      const SizedBox(height: 4),
                      const Text('吞没大 K 线', style: TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(context, '✅', '实体反包'),
              const SizedBox(width: 12),
              _buildBadge(context, '🩸', '阴阳交替'),
              const SizedBox(width: 12),
              _buildBadge(context, '🔋', '动能强劲'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF022C22) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '实战规律：通常大K线突破后，价格会回踩其波段的 50%~61.8% 确认支撑，这里是盈亏比极佳的进场点。',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF86EFAC) : const Color(0xFF166534)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String title, bool val, ValueChanged<bool?> onChanged) {`;

code = code.replace(targetMethodInsertion, newMethods);

// 2. Add _DashedLine class outside
const dashedLineClass = `class _DashedLine extends StatelessWidget {
  final Color color;
  const _DashedLine({required this.color});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}

`;
code = code.replace('class CustomTrackShape extends RoundedRectSliderTrackShape {', dashedLineClass + 'class CustomTrackShape extends RoundedRectSliderTrackShape {');

// 3. Insert into leftChildren
const searchStr1 = `        // 品种自动折行展示 (Wrap)
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: displayedPairs.map((p) => _buildPairChipV2(p)).toList(),
        ),

        const SizedBox(height: 12),
        Row(
          children: [`;
const repStr1 = `        // 品种自动折行展示 (Wrap)
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: displayedPairs.map((p) => _buildPairChipV2(p)).toList(),
        ),

        _buildMantraCard(context),

        const SizedBox(height: 6),
        Row(
          children: [`;
code = code.replace(searchStr1, repStr1);

const searchStr2 = `              child: TextFormField(
                controller: _lowCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '最低点 (Candle Low)',
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) { setState(() => lowPrice = double.tryParse(v)); _saveState('tp_low', v); },
              ),
            ),
          ],
        ),`;
const repStr2 = `              child: TextFormField(
                controller: _lowCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '最低点 (Candle Low)',
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) { setState(() => lowPrice = double.tryParse(v)); _saveState('tp_low', v); },
              ),
            ),
          ],
        ),
        
        _buildBlueprintCard(context),`;
code = code.replace(searchStr2, repStr2);

fs.writeFileSync('lib/main.dart', code);
console.log('Injected missing components!');
