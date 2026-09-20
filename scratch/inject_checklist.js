const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// Insert checklist state
const stateInsert = `
  String dir3 = '多';
  List<bool> checklist = [false, false, false, false];
`;
code = code.replace("  String dir3 = '多';", stateInsert);

// Insert checklist UI below radar
const radarEndStr = `          child: Column(
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
        ),`;

const checklistUI = `        ),
        
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
        ...List.generate(4, (index) {
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
        }),`;

if (code.includes('晨间自审预警：同质化过度曝险')) {
    code = code.replace(radarEndStr, radarEndStr.replace('),', checklistUI));
    fs.writeFileSync('lib/main.dart', code);
    console.log('Successfully injected checklist!');
} else {
    console.log('Could not find radar string');
}
