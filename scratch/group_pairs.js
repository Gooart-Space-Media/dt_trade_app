const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8').replace(/\r\n/g, '\n');

// 1. Inject _buildPairButton and the group rendering logic
const newHelper = `
  Widget _buildPairButton(String pair) {
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
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFEF3C7) : Colors.transparent,
          border: Border.all(color: active ? const Color(0xFFF59E0B) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(pair, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? const Color(0xFFD97706) : Colors.grey.shade700)),
      ),
    );
  }

  Widget _buildPairGroup(String title, List<String> pairs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 4),
          child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),
        Wrap(
          children: pairs.map((p) => _buildPairButton(p)).toList(),
        ),
      ],
    );
  }

  Widget build(BuildContext context) {`;

code = code.replace("  Widget build(BuildContext context) {", newHelper);

// 2. Replace the old quick pair section
const oldQuickPairRegex = /        Row\(\n          children: \[\n            const Text\('快速联动品种 \(自动载入 ATR 止损基准\): ', style: TextStyle\(fontSize: 11, color: Colors\.grey\)\),\n            Text\('当前: ' \+ activePair, style: const TextStyle\(fontSize: 11, fontWeight: FontWeight\.bold, color: Color\(0xFFD97706\)\)\),\n          \],\n        \),\n        const SizedBox\(height: 8\),\n        SingleChildScrollView\([\s\S]*?child: Text\(pair, style: TextStyle\(fontSize: 12, fontWeight: active \? FontWeight\.bold : FontWeight\.normal, color: active \? const Color\(0xFFD97706\) : Colors\.grey\.shade700\)\),\n                \),\n              \);\n            \}\)\.toList\(\),\n          \),\n        \),/;

const newQuickPair = `        Row(
          children: [
            const Text('点值梯队联动 (自动载入 ATR 止损基准): ', style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text('当前: ' + activePair, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPairGroup('🥇 第一梯队：绝对恒定组 ($0.10)', ['EURUSD', 'GBPUSD', 'AUDUSD', 'NZDUSD']),
              _buildPairGroup('🛡️ 第二梯队：超级防御组 (~$0.06)', ['USDJPY', 'EURJPY', 'GBPJPY', 'AUDJPY', 'CADJPY', 'AUDNZD']),
              _buildPairGroup('📉 第三梯队：安全打折组 (~$0.07)', ['USDCAD', 'AUDCAD', 'EURCAD']),
              _buildPairGroup('⚠️ 第四梯队：点值溢价组 (警惕微超)', ['USDCHF', 'EURGBP']),
              _buildPairGroup('👑 独立品种：美黄金 (0.1$ = 1Pip)', ['XAUUSD']),
            ],
          ),
        ),`;

code = code.replace(oldQuickPairRegex, newQuickPair);

fs.writeFileSync('lib/main.dart', code);
console.log('Grouped pairs into tiers!');
