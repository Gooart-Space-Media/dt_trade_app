const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');
const lines = code.split('\n');
const start = lines.findIndex(l => l.includes('class _OverlapCheckerPageState extends State<OverlapCheckerPage>'));
const end = lines.findIndex((l, i) => i > start && l.includes('class _AvoidCard extends StatelessWidget')) - 1;

let classCode = lines.slice(start, end).join('\n');

// 1. Add checklist to state variables
classCode = classCode.replace(
  "  String dir3 = '多';", 
  "  String dir3 = '多';\n  List<bool> checklist = [false, false, false, false];"
);

// 2. Change build definition to include isDesktop
classCode = classCode.replace(
  "  Widget build(BuildContext context) {\n    final allPairs = [...corePairs, ...minorPairs, ...observedPairs];",
  "  Widget build(BuildContext context) {\n    bool isDesktop = MediaQuery.of(context).size.width > 800;\n    final allPairs = [...corePairs, ...minorPairs, ...observedPairs];"
);

// 3. Wrap ListView with Center/Container
classCode = classCode.replace(
  "    return ListView(\n      padding: const EdgeInsets.all(10),\n      children: [",
  "    return Center(\n      child: Container(\n        constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : 750),\n        child: ListView(\n          padding: const EdgeInsets.all(10),\n          children: ["
);

// 4. Change Trade 1,2,3 into Row if isDesktop
const oldTrades = `        _buildDropdownRow('交易 1 (首选主线)', s1, dir1, allPairs, [], (p) => setState(() { s1 = p; s2 = null; s3 = null; }), (d) => setState(() => dir1 = d)),
        const SizedBox(height: 10),
        _buildDropdownRow('交易 2 (独立隔离)', s2, dir2, allPairs, [s1], (p) => setState(() { s2 = p; s3 = null; }), (d) => setState(() => dir2 = d)),
        const SizedBox(height: 10),
        _buildDropdownRow('交易 3 (独立隔离)', s3, dir3, allPairs, [s1, s2], (p) => setState(() => s3 = p), (d) => setState(() => dir3 = d)),`;
const newTrades = `        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDropdownRow('交易 1 (首选主线)', s1, dir1, allPairs, [], (p) => setState(() { s1 = p; s2 = null; s3 = null; }), (d) => setState(() => dir1 = d))),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdownRow('交易 2 (独立隔离)', s2, dir2, allPairs, [s1], (p) => setState(() { s2 = p; s3 = null; }), (d) => setState(() => dir2 = d))),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdownRow('交易 3 (独立隔离)', s3, dir3, allPairs, [s1, s2], (p) => setState(() => s3 = p), (d) => setState(() => dir3 = d))),
            ],
          )
        else
          Column(
            children: [
              _buildDropdownRow('交易 1 (首选主线)', s1, dir1, allPairs, [], (p) => setState(() { s1 = p; s2 = null; s3 = null; }), (d) => setState(() => dir1 = d)),
              const SizedBox(height: 10),
              _buildDropdownRow('交易 2 (独立隔离)', s2, dir2, allPairs, [s1], (p) => setState(() { s2 = p; s3 = null; }), (d) => setState(() => dir2 = d)),
              const SizedBox(height: 10),
              _buildDropdownRow('交易 3 (独立隔离)', s3, dir3, allPairs, [s1, s2], (p) => setState(() => s3 = p), (d) => setState(() => dir3 = d)),
            ],
          ),`;
classCode = classCode.replace(oldTrades, newTrades);

// 5. Add checklist UI and close Center/Container
const radarEnd = `            ],
          ),
        ),
      ],
    );`;
const checklistUI = `            ],
          ),
        ),
        const SizedBox(height: 24),
        // Checklist Section
        Row(
          children: [
            const Icon(Icons.fact_check_rounded, size: 18, color: Color(0xFF475569)),
            const SizedBox(width: 8),
            const Text('飞行员起飞前：最后 10 秒防呆自检', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const Spacer(),
            if (checklist.every((e) => e))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF22C55E), borderRadius: BorderRadius.circular(20)),
                child: const Text('准许执行 (CLEAR TO ENGAGE)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              )
          ],
        ),
        const SizedBox(height: 12),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildChecklistItem(0),
                    _buildChecklistItem(1),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _buildChecklistItem(2),
                    _buildChecklistItem(3),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildChecklistItem(0),
              _buildChecklistItem(1),
              _buildChecklistItem(2),
              _buildChecklistItem(3),
            ],
          ),
      ],
    )));`;
classCode = classCode.replace(radarEnd, checklistUI);

// 6. Add _buildChecklistItem method
const helperMethod = `  Widget _buildChecklistItem(int index) {
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

  Widget _buildDropdownRow`;
classCode = classCode.replace('  Widget _buildDropdownRow', helperMethod);

// Write back to main.dart
const newCode = lines.slice(0, start).join('\n') + '\n' + classCode + '\n' + lines.slice(end).join('\n');
fs.writeFileSync('lib/main.dart', newCode);
console.log('Successfully re-applied all changes!');
