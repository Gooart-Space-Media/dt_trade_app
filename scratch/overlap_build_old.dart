  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    final allPairs = [...corePairs, ...minorPairs, ...observedPairs];
    bool isComplete = (s1 != null && s2 != null && s3 != null);
    final audit = _auditCorrelation();

    return Center(
        child: Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : 750),
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 4,
                  children: [
                    const Text('🛡️ 多单并行防呆与自审',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6)),
                          onPressed: () => showWatchlistAtlasDialog(context),
                          icon: const Icon(Icons.menu_book_rounded,
                              size: 15, color: Color(0xFFF59E0B)),
                          label: const Text('16品种图鉴',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFF59E0B),
                                  fontWeight: FontWeight.bold)),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6)),
                          onPressed: _showAvoidListDialog,
                          icon: const Icon(Icons.warning_amber_rounded,
                              size: 15, color: Colors.red),
                          label: const Text('毒药黑名单',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded,
                          size: 16, color: Color(0xFFD97706)),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          '规范选项：⭐ 7大核心货币对 (极低点差) + 🔹 9大次要交叉盘',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      InkWell(
                        onTap: () => showWatchlistAtlasDialog(context),
                        child: const Text('详解 >',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF59E0B))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _buildDropdownRow(
                              '交易 1 (首选主线)', s1, dir1, allPairs, [], (p) {
                        setState(() {
                          s1 = p;
                          s2 = null;
                          s3 = null;
                        });
                        _saveState('ol_s1', p);
                        _saveState('ol_s2', null);
                        _saveState('ol_s3', null);
                      }, (d) {
                        setState(() => dir1 = d);
                        _saveState('ol_d1', d);
                      })),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildDropdownRow(
                              '交易 2 (独立隔离)', s2, dir2, allPairs, [s1], (p) {
                        setState(() {
                          s2 = p;
                          s3 = null;
                        });
                        _saveState('ol_s2', p);
                        _saveState('ol_s3', null);
                      }, (d) {
                        setState(() => dir2 = d);
                        _saveState('ol_d2', d);
                      })),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildDropdownRow(
                              '交易 3 (独立隔离)', s3, dir3, allPairs, [s1, s2], (p) {
                        setState(() => s3 = p);
                        _saveState('ol_s3', p);
                      }, (d) {
                        setState(() => dir3 = d);
                        _saveState('ol_d3', d);
                      })),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildDropdownRow('交易 1 (首选主线)', s1, dir1, allPairs, [],
                          (p) {
                        setState(() {
                          s1 = p;
                          s2 = null;
                          s3 = null;
                        });
                        _saveState('ol_s1', p);
                        _saveState('ol_s2', null);
                        _saveState('ol_s3', null);
                      }, (d) {
                        setState(() => dir1 = d);
                        _saveState('ol_d1', d);
                      }),
                      const SizedBox(height: 10),
                      _buildDropdownRow('交易 2 (独立隔离)', s2, dir2, allPairs, [s1],
                          (p) {
                        setState(() {
                          s2 = p;
                          s3 = null;
                        });
                        _saveState('ol_s2', p);
                        _saveState('ol_s3', null);
                      }, (d) {
                        setState(() => dir2 = d);
                        _saveState('ol_d2', d);
                      }),
                      const SizedBox(height: 10),
                      _buildDropdownRow(
                          '交易 3 (独立隔离)', s3, dir3, allPairs, [s1, s2], (p) {
                        setState(() => s3 = p);
                        _saveState('ol_s3', p);
                      }, (d) {
                        setState(() => dir3 = d);
                        _saveState('ol_d3', d);
                      }),
                    ],
                  ),
                const SizedBox(height: 16),

                // 晨间 10 秒单向敞口自审雷达卡片
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (audit['hasRisk'] as bool)
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF450a0a)
                            : const Color(0xFFFEF2F2))
                        : (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF022c22)
                            : const Color(0xFFF0FDF4)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: (audit['hasRisk'] as bool)
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF7f1d1d)
                                : const Color(0xFFFECACA))
                            : (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF14532d)
                                : const Color(0xFFBBF7D0))),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                              (audit['hasRisk'] as bool)
                                  ? Icons.warning_rounded
                                  : Icons.radar_rounded,
                              size: 18,
                              color: (audit['hasRisk'] as bool)
                                  ? Colors.red
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF4ade80)
                                      : const Color(0xFF15803D))),
                          const SizedBox(width: 6),
                          Text(
                              (audit['hasRisk'] as bool)
                                  ? '晨间自审预警：同质化过度曝险'
                                  : '晨间 10 秒风控自审雷达',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: (audit['hasRisk'] as bool)
                                      ? Colors.red
                                      : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF4ade80)
                                          : const Color(0xFF15803D)))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(audit['msg'] as String,
                          style: TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: (audit['hasRisk'] as bool)
                                  ? (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFfca5a5)
                                      : const Color(0xFF991B1B))
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF86efac)
                                      : const Color(0xFF166534)))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(Icons.fact_check_rounded,
                        size: 18,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white60
                            : const Color(0xFF475569)),
                    const SizedBox(width: 8),
                    Text('飞行员起飞前：最后 10 秒防呆自检',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : const Color(0xFF334155))),
                    const Spacer(),
                    if (checklist.every((e) => e))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('准许执行 (CLEAR TO ENGAGE)',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
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
            )));
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
        _saveState('ol_chk_${index}', checklist[index] ? 'true' : 'false');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isChecked
              ? (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF022C22)
                  : const Color(0xFFF0FDF4))
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isChecked
                  ? const Color(0xFF4ADE80)
                  : Theme.of(context).dividerColor.withOpacity(0.2)),
          boxShadow: isChecked
              ? [
                  BoxShadow(
                      color: const Color(0xFF4ADE80).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF22C55E) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: isChecked
                        ? const Color(0xFF22C55E)
                        : Colors.grey.shade400,
                    width: 2),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titles[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                  color: isChecked
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFF166534))
                      : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : const Color(0xFF475569)),
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }