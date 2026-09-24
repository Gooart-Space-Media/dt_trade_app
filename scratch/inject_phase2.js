const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf8');

// ==== OverlapCheckerPage ====
code = code.replace(
  "return {'hasRisk': false, 'msg': '选择 2~3 个品种后，系统将自动自审同向汇率共振风险。'};",
  "return {'hasRisk': false, 'msg': AppLocalizations.of(context)!.msgNoSelection};"
);

code = code.replace(
  "'msg':\n            '⚠️ 危险重叠！当前 3 笔交易全部在单向【做空美元 (Short USD)】！属于同质化单向敞口，若非农/CPI数据强劲，将遭遇 6% 连环爆仓回撤！建议拆解或换交叉盘。'",
  "'msg': AppLocalizations.of(context)!.msgShortRisk"
);

code = code.replace(
  "'msg': '⚠️ 危险重叠！当前 3 笔交易全部在单向【做多美元 (Long USD)】！一旦美元反转将全部止损，建议降低同质化敞口。'",
  "'msg': AppLocalizations.of(context)!.msgLongRisk"
);

code = code.replace(
  "'msg': '✅ 晨间 10 秒自审通过：3 笔交易不存在单向同质化敞口，结构独立，可安全同时建仓（总日风险控制在 6% 内）！'",
  "'msg': AppLocalizations.of(context)!.msgSafe"
);

// We need to pass context to _auditCorrelation
code = code.replace(
  "Map<String, dynamic> _auditCorrelation() {",
  "Map<String, dynamic> _auditCorrelation(BuildContext context) {"
);
code = code.replace(
  "final audit = _auditCorrelation();",
  "final audit = _auditCorrelation(context);"
);

// Avoid List Dialog
code = code.replace(
  "const Text('🚫 坚决规避的毒药品种 (The Avoid List)'",
  "Text(AppLocalizations.of(context)!.avoidTitle"
);
code = code.replace(
  "const Text('以下四类品种在实战中看似有机会，实则暗藏点差与政策陷阱，强烈建议拉黑跳过：'",
  "Text(AppLocalizations.of(context)!.avoidDesc"
);
// Remove const from ListView and children array in AvoidList
code = code.replace(
  "children: const [",
  "children: ["
);
// Replace hardcoded AvoidCards
code = code.replace(
  "title: '1. 联系汇率挂钩类 (画直线)',",
  "title: AppLocalizations.of(context)!.avoidCard1Title,"
);
code = code.replace(
  "reason: '受央行强行挂钩制度约束，K线基本为水平直线，日波动甚至小于点差，毫无交易价值。'",
  "reason: AppLocalizations.of(context)!.avoidCard1Reason"
);
code = code.replace(
  "title: '2. 高息吃人断崖类 (点差过宽)',",
  "title: AppLocalizations.of(context)!.avoidCard2Title,"
);
code = code.replace(
  "reason: '新兴市场货币恶性贬值，看似单边躺赚，但隔夜利息极其昂贵且极易发生政策跳空，利润全被磨光。'",
  "reason: AppLocalizations.of(context)!.avoidCard2Reason"
);
code = code.replace(
  "title: '3. 极低流动性类 (严重滑点)',",
  "title: AppLocalizations.of(context)!.avoidCard3Title,"
);
code = code.replace(
  "reason: '挂单成交极不活跃，止损往往无法在预设点位成交，遭遇极端滑点击穿账户。'",
  "reason: AppLocalizations.of(context)!.avoidCard3Reason"
);
code = code.replace(
  "title: '4. 恶劣交叉盘规避',",
  "title: AppLocalizations.of(context)!.avoidCard4Title,"
);
code = code.replace(
  "reason: '虽然日均波幅极大，但点差同样极其昂贵，盈利空间往往刚好抵消高额交易成本。'",
  "reason: AppLocalizations.of(context)!.avoidCard4Reason"
);

// Build method UI strings
code = code.replace(
  "const Text('🛡️ 多单并行防呆与自审'",
  "Text(AppLocalizations.of(context)!.pageOverlapTitle"
);
code = code.replace(
  "label: const Text('16品种图鉴'",
  "label: Text(AppLocalizations.of(context)!.btnAtlas"
);
code = code.replace(
  "label: const Text('毒药黑名单'",
  "label: Text(AppLocalizations.of(context)!.btnAvoid"
);
code = code.replace(
  "const Expanded(\n                        child: Text(\n                          '规范选项：⭐ 7大核心货币对 (极低点差) + 🔹 9大次要交叉盘',",
  "Expanded(\n                        child: Text(\n                          AppLocalizations.of(context)!.txtStandard,"
);
code = code.replace(
  "child: const Text('详解 >'",
  "child: Text(AppLocalizations.of(context)!.btnDetail"
);
// replace multiple occurrences of '交易 1 (首选主线)'
code = code.replace(/'交易 1 \(首选主线\)'/g, "AppLocalizations.of(context)!.trade1");
code = code.replace(/'交易 2 \(独立隔离\)'/g, "AppLocalizations.of(context)!.trade2");
code = code.replace(/'交易 3 \(独立隔离\)'/g, "AppLocalizations.of(context)!.trade3");
code = code.replace(/String dir1 = '多';/g, "String dir1 = 'Long';");
code = code.replace(/String dir2 = '多';/g, "String dir2 = 'Long';");
code = code.replace(/String dir3 = '多';/g, "String dir3 = 'Long';");
code = code.replace(/dir1 = prefs.getString\('ol_d1'\) \?\? '多';/g, "dir1 = prefs.getString('ol_d1') ?? 'Long';");
code = code.replace(/dir2 = prefs.getString\('ol_d2'\) \?\? '多';/g, "dir2 = prefs.getString('ol_d2') ?? 'Long';");
code = code.replace(/dir3 = prefs.getString\('ol_d3'\) \?\? '多';/g, "dir3 = prefs.getString('ol_d3') ?? 'Long';");
// Wait, the dropdown compares with '多' in _auditCorrelation:
// final isBuy = t['dir'] == '多'; -> final isBuy = t['dir'] == 'Long';
code = code.replace("final isBuy = t['dir'] == '多';", "final isBuy = t['dir'] == 'Long';");
// We also need to translate the dropdown items. This is in _buildDropdownRow:
// _buildDropdownRow(String label, String? selectedPair, String direction, ...)
// But the dropdown items are built dynamically. Let's see _buildDropdownRow:
// We need to look at how DropdownButton for direction is created.
code = code.replace(
  "DropdownMenuItem(value: '多', child: Text('多', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold))),",
  "DropdownMenuItem(value: 'Long', child: Text(AppLocalizations.of(context)!.dirLong, style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold))),"
);
code = code.replace(
  "DropdownMenuItem(value: '空', child: Text('空', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold))),",
  "DropdownMenuItem(value: 'Short', child: Text(AppLocalizations.of(context)!.dirShort, style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold))),"
);

code = code.replace(
  "'晨间自审预警：同质化过度曝险'\n                                  : '晨间 10 秒风控自审雷达',",
  "AppLocalizations.of(context)!.radarRiskTitle\n                                  : AppLocalizations.of(context)!.radarSafeTitle,"
);
code = code.replace(
  "Text('飞行员起飞前：最后 10 秒防呆自检',",
  "Text(AppLocalizations.of(context)!.chkTitle,"
);
code = code.replace(
  "const Text('准许执行 (CLEAR TO ENGAGE)'",
  "Text(AppLocalizations.of(context)!.chkClear"
);

code = code.replace(
  "final titles = [\n      '日内无重大数据发布 (如非农、CPI等核弹级数据)',\n      '情绪绝对平稳，未受上笔交易 (大赚/大亏) 的 FOMO 影响',\n      '严格遵循 DT 双轨制，已预设 Trade 1 的保本与止盈',\n      '单笔总风险严格控制在 2% 内，绝不抱有重仓扛单侥幸'\n    ];",
  "final titles = [\n      AppLocalizations.of(context)!.chk1,\n      AppLocalizations.of(context)!.chk2,\n      AppLocalizations.of(context)!.chk3,\n      AppLocalizations.of(context)!.chk4\n    ];"
);


// ==== LotSizeCalcPage ====
// _getFightIqDiagnosis requires context
code = code.replace(
  "Map<String, dynamic> _getFightIqDiagnosis(double pips) {",
  "Map<String, dynamic> _getFightIqDiagnosis(BuildContext context, double pips) {"
);
code = code.replace(
  "final fightIq = _getFightIqDiagnosis(slPips);",
  "final fightIq = _getFightIqDiagnosis(context, slPips);"
);

// IQ Gold Strings
code = code.replace(
  "'status': '🟡 黄金噪音小蜡烛 (< 150 Pips / < \\$15)'",
  "'status': AppLocalizations.of(context)!.iqGold1Title"
);
code = code.replace(
  "'desc': '机构未发力，多为震荡横盘噪音，极易假突破，不建议做突破挂单。'",
  "'desc': AppLocalizations.of(context)!.iqGold1Desc"
);
code = code.replace(
  "'status': '🟢 黄金标准舒适区 (150 ~ 250 Pips / \\$15~\\$25)'",
  "'status': AppLocalizations.of(context)!.iqGold2Title"
);
code = code.replace(
  "'desc': '完美标准日线吞没！动能充沛，突破法与 50% 回撤法均可完美执行！'",
  "'desc': AppLocalizations.of(context)!.iqGold2Desc"
);
code = code.replace(
  "'status': '🔵 黄金偏大蜡烛 (250 ~ 350 Pips / \\$25~\\$35)'",
  "'status': AppLocalizations.of(context)!.iqGold3Title"
);
code = code.replace(
  "'desc': '突破止损偏大，严禁追突破挂单！必须用 Fib 50% 回踩折半入场！'",
  "'desc': AppLocalizations.of(context)!.iqGold3Desc"
);
code = code.replace(
  "'status': '🛑 黄金极端力竭蜡烛 (> 350 Pips / > \\$35)'",
  "'status': AppLocalizations.of(context)!.iqGold4Title"
);
code = code.replace(
  "'desc': '情绪过热暴冲！次日极易深度反抽或扫损，系统强烈建议直接放弃！'",
  "'desc': AppLocalizations.of(context)!.iqGold4Desc"
);

// IQ FX Strings
code = code.replace(
  "'status': '🟡 比较短的蜡烛 (< 50 Pips)'",
  "'status': AppLocalizations.of(context)!.iqFx1Title"
);
code = code.replace(
  "'desc': '日内波动偏小。此时 50% 回调位太近易被噪音扫损，建议仅采用【突破法挂单】。'",
  "'desc': AppLocalizations.of(context)!.iqFx1Desc"
);
code = code.replace(
  "'status': '🟢 标准外汇波动 (50 ~ 80 Pips)'",
  "'status': AppLocalizations.of(context)!.iqFx2Title"
);
code = code.replace(
  "'desc': '完美舒适区！波动充足且方向明确，突破法与 50% 回调法均可完美执行！'",
  "'desc': AppLocalizations.of(context)!.iqFx2Desc"
);
code = code.replace(
  "'status': '🔵 偏大蜡烛 (80 ~ 100 Pips)'",
  "'status': AppLocalizations.of(context)!.iqFx3Title"
);
code = code.replace(
  "'desc': '突破止损偏大。强烈建议使用【50% 回调法】，将入场风险折半压缩至 40~50 Pips！'",
  "'desc': AppLocalizations.of(context)!.iqFx3Desc"
);
code = code.replace(
  "'status': '🛑 极端力竭蜡烛 (> 100 Pips)'",
  "'status': AppLocalizations.of(context)!.iqFx4Title"
);
code = code.replace(
  "'desc': '情绪力竭暴冲！盈亏比极差，系统强烈建议直接放弃交易，坚决不介入！'",
  "'desc': AppLocalizations.of(context)!.iqFx4Desc"
);

// Table Strings
code = code.replace(
  "const Text('🧮 500 - 3,200 美元双轨最大手数对照表'",
  "Text(AppLocalizations.of(context)!.calcTableTitle"
);
code = code.replace(
  "const Text('点击任意行可直接快速载入该资金配置 (总手数恒为偶数，保证 2 x 1% 完美平分)：'",
  "Text(AppLocalizations.of(context)!.calcTableDesc"
);
code = code.replace(
  "Text('2% 红线: \\$${row['risk']}',",
  "Text(AppLocalizations.of(context)!.calcTableRedLine(row['risk'].toString()),"
);
// replace multiple occurrences of 🚫 不可用 (超标)
code = code.replace(/'🚫 不可用 \(超标\)'/g, "AppLocalizations.of(context)!.calcTableNotAvailable");

// UI Elements LotSizeCalcPage
code = code.replace(
  "Text('🏢 XM 标准/Ultra Low (1手=100k)',",
  "Text(AppLocalizations.of(context)!.calcAccountStd,"
);
code = code.replace(
  "Text('🔬 XM Micro 微型 (1手=1k)',",
  "Text(AppLocalizations.of(context)!.calcAccountMicro,"
);
code = code.replace(
  "const Text('点值梯队联动 (自动载入 ATR 止损基准): '",
  "Text(AppLocalizations.of(context)!.calcPointLink"
);
code = code.replace(
  "Text('当前: ' + activePair,",
  "Text(AppLocalizations.of(context)!.calcCurrentPair + activePair,"
);

code = code.replace(
  "const Text('账户总资金 (Balance)'",
  "Text(AppLocalizations.of(context)!.calcBalTitle"
);
code = code.replace(
  "const Text('当前汇率 (USD/MYR)'",
  "Text(AppLocalizations.of(context)!.calcRateTitle"
);
code = code.replace(
  "const Text('单笔总风险 (Risk %)'",
  "Text(AppLocalizations.of(context)!.calcRiskTitle"
);
code = code.replace(
  "const Text('止损点数 (Stop Loss Pips)'",
  "Text(AppLocalizations.of(context)!.calcSlTitle"
);
code = code.replace(
  "const Text('📊 双轨分仓执行计划'",
  "Text(AppLocalizations.of(context)!.calcResultTitle"
);
code = code.replace(
  "const Text('单笔最大允许亏损: '",
  "Text(AppLocalizations.of(context)!.calcResultMaxLoss"
);
code = code.replace(
  "const Text('总开仓手数 (Total Lots)'",
  "Text(AppLocalizations.of(context)!.calcResultTotalLots"
);
code = code.replace(
  "const Text('⚠️ 资金不足以执行 2% 风险标准，总手数低于 0.02 手'",
  "Text(AppLocalizations.of(context)!.calcResultInsufficient"
);
code = code.replace(
  "const Text('Trade 1: 1% 风险首战 (激进)'",
  "Text(AppLocalizations.of(context)!.calcResultTrade1"
);
code = code.replace(
  "const Text('Trade 2: 1% 风险次战 (保守)'",
  "Text(AppLocalizations.of(context)!.calcResultTrade2"
);

code = code.replace(
  "const Text('🧠 Fight IQ: 当前品种蜡烛健康诊断'",
  "Text(AppLocalizations.of(context)!.iqTitle"
);
code = code.replace(
  "const Text('快速选择'",
  "Text(AppLocalizations.of(context)!.btnQuickSelect"
);
code = code.replace(
  "const Text('获取实时汇率'",
  "Text(AppLocalizations.of(context)!.btnLiveRate"
);

fs.writeFileSync('lib/main.dart', code);
console.log("Translation logic injected successfully");
