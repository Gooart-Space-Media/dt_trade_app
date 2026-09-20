const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

const oldChecklistStr = `        ...List.generate(4, (index) {
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

const newChecklistLayout = `        if (isDesktop)
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
          ),`;

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

if (code.includes('...List.generate(4, (index) {')) {
  code = code.replace(oldChecklistStr, newChecklistLayout);
  code = code.replace('  Widget _buildDropdownRow', helperMethod);
  fs.writeFileSync('lib/main.dart', code);
  console.log('Successfully applied 2-column checklist layout!');
} else {
  console.log('Could not find the checklist block!');
}
