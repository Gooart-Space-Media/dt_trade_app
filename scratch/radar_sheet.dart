  void _showRadarBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Get current time
            final now = DateTime.now().toUtc().add(const Duration(hours: 8)); // MYT is UTC+8
            final h = now.hour;
            final m = now.minute;
            final totalMinutes = h * 60 + m;

            // Helper to determine status and countdown
            Map<String, dynamic> getSessionData(int startH, int startM, int endH, int endM, bool crossesMidnight) {
              int startTotal = startH * 60 + startM;
              int endTotal = endH * 60 + endM;
              
              bool isActive = false;
              if (crossesMidnight) {
                isActive = totalMinutes >= startTotal || totalMinutes < endTotal;
              } else {
                isActive = totalMinutes >= startTotal && totalMinutes < endTotal;
              }

              String countdown = '';
              if (isActive) {
                // Time until close
                int diff = crossesMidnight && totalMinutes >= startTotal
                    ? (endTotal + 24 * 60) - totalMinutes
                    : endTotal - totalMinutes;
                int dh = diff ~/ 60;
                int dm = diff % 60;
                countdown = '距收盘还有 ${dh}h${dm.toString().padLeft(2, '0')}m';
              } else {
                // Time until open
                int diff = startTotal - totalMinutes;
                if (diff < 0) diff += 24 * 60;
                int dh = diff ~/ 60;
                int dm = diff % 60;
                countdown = '距开盘还有 ${dh}h${dm.toString().padLeft(2, '0')}m';
              }
              
              return {
                'active': isActive,
                'countdown': countdown,
              };
            }

            final sydney = getSessionData(5, 0, 14, 0, false);
            final tokyo = getSessionData(8, 0, 17, 0, false);
            final london = getSessionData(15, 0, 0, 0, true); // 15:00 to 24:00 (00:00)
            final newYork = getSessionData(20, 0, 5, 0, true);
            final overlap = getSessionData(20, 30, 0, 0, true); // 20:30 to 24:00

            Widget buildCard(String title, String emoji, String timeRange, String subLeft, String desc, List<String> chips, Map<String, dynamic> data) {
              bool active = data['active'];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active ? const Color(0xFFF59E0B) : Theme.of(context).dividerColor.withOpacity(0.2),
                    width: active ? 1.5 : 1.0,
                  ),
                  boxShadow: active ? [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.1), blurRadius: 8, spreadRadius: 1)] : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      TextSpan(text: '  $timeRange', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ]
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: active ? const Color(0xFF16A34A).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: active ? const Color(0xFF16A34A) : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(active ? '交易中' : '休盘中', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: active ? const Color(0xFF16A34A) : Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(subLeft, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(data['countdown'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: active ? const Color(0xFFD97706) : Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(desc, style: const TextStyle(fontSize: 12, height: 1.4)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('推荐品种: ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: chips.map((c) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(c, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Notch
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.radar_rounded, color: Color(0xFF2563EB), size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '全球四大外汇盘口实时时钟与伦纽重叠雷达',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('MYT (GMT+8)', style: TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Text(
                      '根据 Notion 货币对最佳时段研究，严格在活跃流动性窗口做单，杜绝垃圾时段噪音损耗：',
                      style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4),
                    ),
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  // List
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        buildCard(
                          '悉尼盘 (Sydney)', '🌏', '05:00 - 14:00',
                          '悉尼 / 惠灵顿',
                          '全天最早开市，澳纽商品直盘与兄弟交叉盘平缓启动，波动偏温和',
                          ['AUDUSD 澳美', 'AUDNZD 澳纽', 'NZDUSD 纽美'],
                          sydney,
                        ),
                        buildCard(
                          '东京/亚洲盘 (Tokyo)', '🗾', '08:00 - 17:00',
                          '东京 / 香港 / 新加坡',
                          '日元利差交易核心主场，中国宏观数据多在此刻公布，常奠定全天底色',
                          ['USDJPY 美日', 'EURJPY 欧日', 'GBPJPY 镑日', 'AUDJPY 澳日', 'AUDUSD 澳美'],
                          tokyo,
                        ),
                        buildCard(
                          '伦敦盘 (London)', '🏰', '15:00 - 00:00',
                          '伦敦 / 法兰克福',
                          '欧洲大资金疯狂涌入，全球外汇成交中枢，突破形态首波引爆期',
                          ['EURUSD 欧美', 'GBPUSD 镑美', 'EURJPY 欧日', 'GBPJPY 镑日', 'EURGBP 欧镑'],
                          london,
                        ),
                        buildCard(
                          '纽约盘 (New York)', '🗽', '20:00 - 05:00',
                          '纽约 / 多伦多',
                          '美联储与大宗商品主导，非农/CPI/利率决议重磅数据多在美盘爆发',
                          ['EURUSD 欧美', 'GBPUSD 镑美', 'USDCAD 美加', 'USDJPY 美日', 'XAUUSD 现货黄金'],
                          newYork,
                        ),
                        buildCard(
                          '伦纽黄金重叠期 (Overlap)', '🔥', '20:30 - 00:00',
                          '伦敦 + 纽约 双核共振',
                          '全天波动与流动性巅峰！7大核心直盘与现货黄金全面爆发，触碰 1:1 TP1 止盈并推保本的关键时段',
                          ['EURUSD 欧美', 'GBPUSD 镑美', 'USDJPY 美日', 'USDCAD 美加', 'XAUUSD 现货黄金', 'GBPJPY 镑日'],
                          overlap,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
