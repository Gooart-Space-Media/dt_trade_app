  Widget build(BuildContext context) {
    int decimals = isGold ? 2 : ((highPrice ?? 0) > 10 ? 3 : 5);
    double pipMultiplier = isGold ? 10 : ((highPrice ?? 0) > 10 ? 100 : 10000);

    bool hasData = (highPrice != null && lowPrice != null && highPrice! > lowPrice!);
    double range = 0;

    // 10 pips 假突破缓冲 & 9 pips 止损缓冲
    double pEntry = selectedTimeframe == 'D1' ? 10.0 : 3.0;
    if (entryMode == 2) pEntry = 0;
    double bufferEntry = pEntry / pipMultiplier;
    double pSl = selectedTimeframe == 'D1' ? 9.0 : 3.0;
    double bufferSl = pSl / pipMultiplier;

    double breakoutEntry = 0;
    double breakoutSl = 0;
    double breakoutRisk = 0;
    double fib50 = 0;
    double fib618 = 0;
    double fibSl = 0;
    double fib50Risk = 0;
    double fib618Risk = 0;
    double be40 = 0;
    double beBody = 0;

    double currentRiskPips = 0;
    double riskAmountUsd = 0;
    double tradeLot = 0.01;

    if (hasData) {
      range = highPrice! - lowPrice!;
      // 突破模式计算
      breakoutEntry = isLong ? highPrice! + bufferEntry : lowPrice! - bufferEntry;
      breakoutSl = isLong ? lowPrice! - bufferSl : highPrice! + bufferSl;
      breakoutRisk = (breakoutEntry - breakoutSl).abs();

      // 黄金口袋 Fib 50% & 61.8% 狙击入场位计算
      fib50 = isLong ? highPrice! - range * 0.50 : lowPrice! + range * 0.50;
      fib618 = isLong ? highPrice! - range * 0.618 : lowPrice! + range * 0.618;
      fibSl = isLong ? lowPrice! - bufferSl : highPrice! + bufferSl;
      fib50Risk = (fib50 - fibSl).abs();
      fib618Risk = (fib618 - fibSl).abs();

      currentRiskPips = (entryMode == 1) ? (fib50Risk * pipMultiplier) : (breakoutRisk * pipMultiplier);
      riskAmountUsd = userBalance * (userRisk / 100.0);
      double rawTotalLots = currentRiskPips > 0 ? (riskAmountUsd / (currentRiskPips * 10.0)) : 0.0;
      tradeLot = isDualTrack ? (rawTotalLots / 2.0) : rawTotalLots;
      if (tradeLot < 0.01 && tradeLot > 0) tradeLot = 0.01;

      // 双重推保本点位 (Notion Part 3: 40 pips 规则 & 实体等长规则)
      double entryForBe = (entryMode == 1) ? fib50 : breakoutEntry;
      be40 = isLong ? entryForBe + (40 / pipMultiplier) : entryForBe - (40 / pipMultiplier);
      beBody = isLong ? entryForBe + range : entryForBe - range;
    }

    final currentPairInfo = getWatchlistPair(selectedPair);

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        // 模式切换：突破挂单 vs 黄金口袋 Fib vs 极值突破
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() { entryMode = 1; _saveState('tp_mode', 1); }); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: entryMode == 1 ? const Color(0xFFD97706) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('🎯 黄金口袋', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: entryMode == 1 ? Colors.white : Colors.grey))),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() { entryMode = 0; _saveState('tp_mode', 0); }); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: entryMode == 0 ? const Color(0xFF2563EB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('🚀 常规突破', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: entryMode == 0 ? Colors.white : Colors.grey))),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() { entryMode = 2; _saveState('tp_mode', 2); }); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: entryMode == 2 ? const Color(0xFF9333EA) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('⚡ 极值突破', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: entryMode == 2 ? Colors.white : Colors.grey))),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Timeframe Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('执行级别 (Timeframe):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ToggleButtons(
              constraints: const BoxConstraints(minHeight: 40, minWidth: 50),
              borderRadius: BorderRadius.circular(8),
              isSelected: ['D1', 'H4', 'H1', 'M15'].map((t) => t == selectedTimeframe).toList(),
              onPressed: (idx) {
                HapticFeedback.selectionClick();
                setState(() { selectedTimeframe = ['D1', 'H4', 'H1', 'M15'][idx]; _saveState('tp_timeframe', selectedTimeframe); });
              },
              children: const [
                Text('D1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text('H4', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text('H1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text('M15', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 双轨/单轨切换
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() { isDualTrack = true; _saveState('tp_dual_track', true); }); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isDualTrack ? const Color(0xFF059669) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('⚖️ 双轨 1%+1%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDualTrack ? Colors.white : Colors.grey))),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() { isDualTrack = false; _saveState('tp_dual_track', false); }); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !isDualTrack ? const Color(0xFFDC2626) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('🎯 单轨 2%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: !isDualTrack ? Colors.white : Colors.grey))),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 模式切换：突破挂单 vs 黄金口袋 Fib
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() { entryMode = 1; _saveState('tp_mode', 1); });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: (entryMode == 1) ? const Color(0xFFD97706) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('🎯 黄金口袋 (Fib 50~61.8%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: (entryMode == 1) ? Colors.white : Colors.grey)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() { entryMode = 0; _saveState('tp_mode', 0); });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !(entryMode == 1) ? const Color(0xFF2563EB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('🚀 常规突破 (+10pips缓冲)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: !(entryMode == 1) ? Colors.white : Colors.grey)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ToggleButtons(
              isSelected: [isLong, !isLong],
              borderRadius: BorderRadius.circular(8),
              constraints: const BoxConstraints(minWidth: 65, minHeight: 32),
              selectedColor: Colors.white,
              fillColor: isLong ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              onPressed: (idx) => setState(() => isLong = idx == 0),
              children: const [
                Text('做多 (BUY)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('做空 (SELL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => showWatchlistAtlasDialog(context, onSelect: (p) => _selectWatchlistPair(p)),
              icon: const Icon(Icons.menu_book_rounded, size: 14, color: Color(0xFF2563EB)),
              label: const Text('16品种图鉴', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            ),
          ],
        ),

        const SizedBox(height: 10),
        // 当前选中品种高阶信息标牌
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: currentPairInfo.isCore
                ? const Color(0xFFFEF3C7).withOpacity(0.45)
                : (currentPairInfo.isGold ? const Color(0xFFFFFBEB) : const Color(0xFFEFF6FF).withOpacity(0.55)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: currentPairInfo.isCore
                  ? const Color(0xFFF59E0B).withOpacity(0.4)
                  : (currentPairInfo.isGold ? const Color(0xFFD97706).withOpacity(0.4) : const Color(0xFF60A5FA).withOpacity(0.4)),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: currentPairInfo.isCore
                      ? const Color(0xFFF59E0B)
                      : (currentPairInfo.isGold ? const Color(0xFFD97706) : const Color(0xFF2563EB)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  currentPairInfo.categoryLabel,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${currentPairInfo.symbol} (${currentPairInfo.chineseName})',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          currentPairInfo.isJpy ? '· 3位报价' : (currentPairInfo.isGold ? '· 2位报价' : '· 5位报价'),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentPairInfo.session,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentPairInfo.feature,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),
        // 核心与次要分类过滤标签
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryFilterChip('all', '全部 (17)'),
              const SizedBox(width: 6),
              _buildCategoryFilterChip('core', '⭐ 核心 (7)'),
              const SizedBox(width: 6),
              _buildCategoryFilterChip('minor', '🔹 次要 (9)'),
              const SizedBox(width: 6),
              _buildCategoryFilterChip('observed', '🥇 黄金 (1)'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 品种横向滚动 Chips (标注核心/次要/黄金)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: displayedPairs.map((p) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _buildPairChipV2(p),
            )).toList(),
          ),
        ),

        const SizedBox(height: 12),
        TextFormField(
          controller: _highCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: '吞没形态蜡烛最高点 (Candle High)',
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (v) { setState(() => highPrice = double.tryParse(v)); _saveState('tp_high', v); },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _lowCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: '吞没形态蜡烛最低点 (Candle Low)',
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (v) { setState(() => lowPrice = double.tryParse(v)); _saveState('tp_low', v); },
        ),
        const SizedBox(height: 16),

        if (hasData) ...[
          if (entryMode == 1) ...[
            // 黄金口袋 Fib 5618 狙击结果
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFFDE68A)),
              ),
              color: const Color(0xFFFFFDF5),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🎯 黄金口袋 (Fib 50%~61.8% 绝杀狙击位)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                          child: Text('形态总长: ${(range * pipMultiplier).toStringAsFixed(1)} Pips', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildPriceCard(context, 'Fib 50% 狙击入场', fib50.toStringAsFixed(decimals), '止损仅 ${(fib50Risk * pipMultiplier).toStringAsFixed(1)} Pips (折半)', const Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        _buildPriceCard(context, 'Fib 61.8% 绝杀入场', fib618.toStringAsFixed(decimals), '止损仅 ${(fib618Risk * pipMultiplier).toStringAsFixed(1)} Pips', const Color(0xFFB45309)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildPriceCard(context, '硬性止损位 (极值外9pips)', fibSl.toStringAsFixed(decimals), '无论在哪个回踩入场，统一此止损', const Color(0xFFDC2626)),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text('💎 稳健与奔跑双目标点位 (以 50% 入场测算):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriceCard(context, 'Trade 1 (1:1 落袋)', (isLong ? fib50 + fib50Risk : fib50 - fib50Risk).toStringAsFixed(decimals), '到此立刻平仓，推保本', const Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        _buildPriceCard(context, 'Trade 2 (1:2 波段)', (isLong ? fib50 + fib50Risk * 2 : fib50 - fib50Risk * 2).toStringAsFixed(decimals), '长线奔跑目标 1', const Color(0xFF059669)),
                        const SizedBox(width: 8),
                        _buildPriceCard(context, 'Trade 2 (1:3 暴利)', (isLong ? fib50 + fib50Risk * 3 : fib50 - fib50Risk * 3).toStringAsFixed(decimals), '日线趋势波段', const Color(0xFF15803D)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // 常规突破入场结果
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2))),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🚀 突破挂单入场 (含10pips假突破缓冲)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                        Text('止损空间: ${(breakoutRisk * pipMultiplier).toStringAsFixed(1)} Pips', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildPriceCard(context, '挂单入场价 (Buy/Sell Stop)', breakoutEntry.toStringAsFixed(decimals), '极值外+10 Pips缓冲防假破', const Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        _buildPriceCard(context, '止损价格 (SL)', breakoutSl.toStringAsFixed(decimals), '极值外+9 Pips缓冲', const Color(0xFFDC2626)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        _buildPriceCard(context, 'Trade 1 (1:1 落袋)', (isLong ? breakoutEntry + breakoutRisk : breakoutEntry - breakoutRisk).toStringAsFixed(decimals), '落袋后立即推保本', const Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        _buildPriceCard(context, 'Trade 2 (1:2 跑单)', (isLong ? breakoutEntry + breakoutRisk * 2 : breakoutEntry - breakoutRisk * 2).toStringAsFixed(decimals), '第二结构阻力', const Color(0xFF059669)),
                        const SizedBox(width: 8),
                        _buildPriceCard(context, 'Trade 2 (1:3 奔跑)', (isLong ? breakoutEntry + breakoutRisk * 3 : breakoutEntry - breakoutRisk * 3).toStringAsFixed(decimals), '大趋势锁定', const Color(0xFF15803D)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Center(child: Text('💡 点击任意绿色/蓝色价格卡片，直接复制价格到剪贴板', style: TextStyle(fontSize: 11, color: Colors.grey))),

          const SizedBox(height: 12),
          // 联动双轨推荐手数卡片
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: (entryMode == 1) ? const Color(0xFFFDE68A) : const Color(0xFFBFDBFE)),
            ),
            color: (entryMode == 1) ? const Color(0xFFFFFDF5) : const Color(0xFFF8FAFC),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '💰 ${isDualTrack ? "双轨" : "单轨"}联动推荐手数 (本金 \$${userBalance.toStringAsFixed(0)} · 风控 $userRisk%)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: (entryMode == 1) ? const Color(0xFFB45309) : const Color(0xFF1E40AF)),
                      ),
                      Text('单笔止损: ${currentRiskPips.toStringAsFixed(1)} Pips', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (isDualTrack) ...[
                        Column(
                          children: [
                            const Text('Trade 1 (1:1保本仓)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text('${tradeLot.toStringAsFixed(2)} 手', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
                          ],
                        ),
                        const Text('➕', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Column(
                          children: [
                            const Text('Trade 2 (波段奔跑仓)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text('${tradeLot.toStringAsFixed(2)} 手', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                          ],
                        ),
                      ] else ...[
                        Column(
                          children: [
                            const Text('单轨全仓 (2% 风险)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text('${tradeLot.toStringAsFixed(2)} 手', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
                          ],
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                        child: Text('总风险 \$${riskAmountUsd.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 🛡️ 双重推保本精准测算器 (Notion Part 3 战法心法)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.4)),
            ),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF064E3B).withOpacity(0.18)
                : const Color(0xFFF0FDF4),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 18, color: Color(0xFF059669)),
                          SizedBox(width: 6),
                          Text(
                            '🛡️ 双重推保本精准测算器 (Notion Part 3)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('锁定 0 风险', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '行情到达以下任一触发位后，立即将 Trade 2 止损推至开仓价（保本），开启完全无风险奔跑模式：',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildPriceCard(
                        context,
                        '规则 A：+40 Pips 推保本位',
                        be40.toStringAsFixed(decimals),
                        '触碰即推保本至开仓价',
                        const Color(0xFF059669),
                      ),
                      const SizedBox(width: 8),
                      _buildPriceCard(
                        context,
                        '规则 B：实体等长推保本位',
                        beBody.toStringAsFixed(decimals),
                        '走完 ${(range * pipMultiplier).toStringAsFixed(1)}p 即推保本',
                        const Color(0xFF0D9488),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.directions_run_rounded, size: 14, color: Color(0xFF059669)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '🏃 Runner 离场绝学：Trade 2 绝不手动提前平仓，死拿直到大级别 (D1) 出现反向吞没！',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ⚔️ T.S.C.F. 四维共振评级雷达 (Timon Weller 核心胜率诊断)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: (_tscfRating['color'] as Color).withOpacity(0.4)),
            ),
            color: Theme.of(context).brightness == Brightness.dark
                ? (_tscfRating['color'] as Color).withOpacity(0.15)
                : (_tscfRating['bg'] as Color),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.radar_rounded, size: 18, color: Color(0xFF2563EB)),
                          SizedBox(width: 6),
                          Text(
                            '⚔️ T.S.C.F. 四维共振评级雷达',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (_tscfRating['color'] as Color).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: (_tscfRating['color'] as Color).withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _tscfRating['stars'] as String,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: _tscfRating['color'] as Color),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _tscfRating['title'] as String,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _tscfRating['color'] as Color),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _tscfRating['desc'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildTscfChip(
                        '📈 Trend 顺势',
                        'D1 顺应主趋势，绝不逆势摸顶摸底',
                        _tscfTrend,
                        (v) => setState(() => _tscfTrend = v),
                      ),
                      _buildTscfChip(
                        '🧱 Structure 关键结构',
                        '位于线图支撑/阻力海绵弹射带',
                        _tscfStructure,
                        (v) => setState(() => _tscfStructure = v),
                      ),
                      _buildTscfChip(
                        '🕯️ Candlestick 确认形态',
                        '日线已完整收盘，实体饱满吞没/PinBar',
                        _tscfCandle,
                        (v) => setState(() => _tscfCandle = v),
                      ),
                      _buildTscfChip(
                        '🎯 Fib 黄金口袋',
                        '回踩 50%~61.8% 黄金回撤位',
                        _tscfFib,
                        (v) => setState(() => _tscfFib = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 🛡️ 吞没战法 · 开单前 5 项铁律自检 (Pre-Flight Checklist)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: _allChecked ? const Color(0xFF10B981) : Colors.amber.withOpacity(0.5)),
            ),
            color: _allChecked
                ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF064E3B).withOpacity(0.25) : const Color(0xFFF0FDF4))
                : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF78350F).withOpacity(0.2) : const Color(0xFFFFFBEB)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(_allChecked ? Icons.verified_rounded : Icons.security_rounded, size: 18, color: _allChecked ? const Color(0xFF059669) : const Color(0xFFD97706)),
                          const SizedBox(width: 6),
                          Text(
                            '🛡️ 开单前 5 项风控铁律自检',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _allChecked ? const Color(0xFF059669) : const Color(0xFFB45309)),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                        onPressed: _toggleAllChecks,
                        icon: Icon(_allChecked ? Icons.restart_alt_rounded : Icons.done_all_rounded, size: 15),
                        label: Text(_allChecked ? '重置' : '全选合格', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildCheckItem('🕯️ 1. 收盘确认：D1/H4 实体已明确收线，绝不在未收盘前抢跑', _checkClosed, (v) => setState(() => _checkClosed = v ?? false)),
                  _buildCheckItem(isGold ? '📏 2. 动能健康：极值在 150~250 Pips (\$15~\$25) 黄金区间' : '📏 2. 动能健康：极值在 50~100 Pips 黄金区间，非噪音非衰竭', _checkFightIq, (v) => setState(() => _checkFightIq = v ?? false)),
                  _buildCheckItem(isGold ? '🛡️ 3. 双缓冲保护：入场+10p假破缓冲，止损+20p (\$2) 黄金结构缓冲' : '🛡️ 3. 双缓冲保护：入场+10pips假破缓冲，止损+9pips结构缓冲', _checkBuffer, (v) => setState(() => _checkBuffer = v ?? false)),
                  _buildCheckItem('⚖️ 4. 双轨分仓：严格 1%+1% 挂单，单笔总风险锁定在 2% 资金红线内', _checkTwinLot, (v) => setState(() => _checkTwinLot = v ?? false)),
                  _buildCheckItem('🧠 5. Set & Forget：挂单后绝不手动追单，到 1:1 必须保本平半仓', _checkMindset, (v) => setState(() => _checkMindset = v ?? false)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _allChecked ? const Color(0xFF10B981).withOpacity(0.12) : Colors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _allChecked ? '✅ 铁律自审全部通过！心如止水，执行挂单！' : '⚠️ 战法铁律：请逐项自审确认，坚决杜绝冲动交易。',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _allChecked ? const Color(0xFF047857) : const Color(0xFFB45309)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 双操作按钮：一键复制指令 + 存入战术计划
          Row(
            children: [
              Expanded(
                flex: 7,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: (entryMode == 1) ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _copyFullTradePlan(
                    decimals: decimals,
                    currentRiskPips: currentRiskPips,
                    riskAmountUsd: riskAmountUsd,
                    tradeLot: tradeLot,
                    fib50: fib50,
                    fibSl: fibSl,
                    fib50Risk: fib50Risk,
                    breakoutEntry: breakoutEntry,
                    breakoutSl: breakoutSl,
                    breakoutRisk: breakoutRisk,
                    be40: be40,
                    beBody: beBody,
                  ),
                  icon: const Icon(Icons.copy_all_rounded, size: 17),
                  label: const Text('📋 一键复制指令', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(color: (entryMode == 1) ? const Color(0xFFD97706) : const Color(0xFF2563EB), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _addCurrentPlan(
                    decimals: decimals,
                    currentRiskPips: currentRiskPips,
                    riskAmountUsd: riskAmountUsd,
                    tradeLot: tradeLot,
                    fib50: fib50,
                    fibSl: fibSl,
                    fib50Risk: fib50Risk,
                    breakoutEntry: breakoutEntry,
                    breakoutSl: breakoutSl,
                    breakoutRisk: breakoutRisk,
                    be40: be40,
                    beBody: beBody,
                  ),
                  icon: const Icon(Icons.bookmark_add_rounded, size: 17),
                  label: const Text('📌 存入今日计划', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.touch_app_rounded, size: 40, color: Color(0xFFD97706)),
                  const SizedBox(height: 10),
                  const Text('等待输入蜡烛极值', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    highPrice != null && lowPrice != null && highPrice! <= lowPrice!
                        ? '⚠️ 最高点必须大于最低点，请检查输入数值'
                        : '请输入吞没蜡烛形态的最高价与最低价，系统将自动测算黄金口袋狙击点位或突破挂单报价。',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 18),
        // 📌 今日实战挂单战术簿
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 18, color: Color(0xFF2563EB)),
                        const SizedBox(width: 6),
                        Text('📌 今日挂单战术簿 (${_savedPlans.length} 笔)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (_savedPlans.isNotEmpty)
                      Row(
                        children: [
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            onPressed: _exportJournalToNotionReport,
                            icon: const Icon(Icons.description_outlined, size: 14),
                            label: const Text('📋 导出Notion日报', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 6)),
                            onPressed: _clearAllPlans,
                            child: const Text('清空', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
                        ],
                      ),
                  ],
                ),
                if (_savedPlans.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B).withOpacity(0.6)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCol('总挂单', '${_savedPlans.length}', const Color(0xFF2563EB)),
                        _buildStatCol('挂单中', '${_savedPlans.where((e) => e['status'] == '⏳ 挂单中').length}', const Color(0xFFD97706)),
                        _buildStatCol('1:1保本', '${_savedPlans.where((e) => e['status'] == '🎯 1:1已推保本' || e['status'] == '🛡️ 保本离场').length}', const Color(0xFF059669)),
                        _buildStatCol('全止盈', '${_savedPlans.where((e) => e['status'] == '💰 全部止盈').length}', const Color(0xFF16A34A)),
                        _buildStatCol('止损', '${_savedPlans.where((e) => e['status'] == '❌ 已止损').length}', const Color(0xFFDC2626)),
                        _buildStatCol(
                          '胜率',
                          () {
                            final tp = _savedPlans.where((e) => e['status'] == '💰 全部止盈').length;
                            final be = _savedPlans.where((e) => e['status'] == '🎯 1:1已推保本' || e['status'] == '🛡️ 保本离场').length;
                            final sl = _savedPlans.where((e) => e['status'] == '❌ 已止损').length;
                            final closed = tp + be + sl;
                            return closed > 0 ? '${(((tp + be) / closed) * 100).toStringAsFixed(0)}%' : '-';
                          }(),
                          const Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                if (_savedPlans.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.assignment_outlined, size: 28, color: Colors.grey),
                        SizedBox(height: 6),
                        Text('暂无保存的挂单计划', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        SizedBox(height: 2),
                        Text('在上方测算出点位后，点击“📌 存入今日计划”即可随时追踪开单', style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ] else ...[
                  Column(
                    children: _savedPlans.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map<String, dynamic> item = entry.value;
                      return _buildSavedPlanItem(idx, item);
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        // 机械化推保护点计算器
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.security, size: 16, color: Color(0xFF059669)),
                    SizedBox(width: 6),
                    Text('机械化移动止损参考 (Trailing Stop)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('当价格跑赢 1:1 后，或者进入下一交易日，将止损移至前一日极值外加缓冲：', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('做多防守 (昨日最低 - 15pips):', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(
                      hasData ? (lowPrice! - (15 / pipMultiplier)).toStringAsFixed(decimals) : '--',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('做空防守 (昨日最高 + 15pips):', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(
                      hasData ? (highPrice! + (15 / pipMultiplier)).toStringAsFixed(decimals) : '--',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }