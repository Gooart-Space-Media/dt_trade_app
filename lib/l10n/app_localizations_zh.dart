// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '双轨风控大师 Pro';

  @override
  String get navHome => '首页';

  @override
  String get navRisk => '组合防呆';

  @override
  String get navDual => '双轨手数';

  @override
  String get navSniper => '吞没狙击';

  @override
  String get navTrend => '复利走势';

  @override
  String get msgOpeningXM => '正在前往 XM 官方认证开户通道...';

  @override
  String get titleXMBanner => 'XM 官方认证开户通道 (专属活动)';

  @override
  String get descXMBanner => '点击立即注册，尊享极低点差与入金赠金';

  @override
  String get titleMantra => '吞没战法实战三句真诀 (必须焊死在脑海)：';

  @override
  String get mantra1Title => '① 做多确认看实体吞没 —— ';

  @override
  String get mantra1Desc => '形态真假看 Body，后一根实体必须彻底吃掉前一根；';

  @override
  String get mantra2Title => '② 止损躲在全区最低影线底 —— ';

  @override
  String get mantra2Desc => '取整片形态区域 (母烛 + 前置烛) 最低的下影线 (Lowest Wick) - 10p；';

  @override
  String get mantra3Title => '③ 50% 取自全区极高与极低的中点 —— ';

  @override
  String get mantra3Desc => '(全区最高 High + 全区最低 Low) ÷ 2，绝不仅看单根母烛！';

  @override
  String get titleBlueprint => '吞没结构与黄金口袋解剖蓝图';

  @override
  String get tagMultiK => '多重 K 线形态区';

  @override
  String get descBlueprint => '黄金口袋 50% 模式：全区极值画网，回踩入场将止损精准压缩';

  @override
  String get blueprintHigh => '全区最高价 High';

  @override
  String get blueprintLow => '全区最低价 Low';

  @override
  String get radarStatus1 => '🌅 晨间设单窗口';

  @override
  String get radarDesc1 => 'D1 日线收盘，7:00-8:00 挂单后关闭软件 (Set & Forget)';

  @override
  String radarCount1(String diff) {
    return '距窗口关闭 $diff分';
  }

  @override
  String get radarStatus2 => '☕ 亚盘静默观察期';

  @override
  String get radarDesc2 => '让市场来找我。亚盘波动小，绝不因 FOMO 手动追单';

  @override
  String radarCount2(String h, String m) {
    return '距 15:00 伦敦盘 ${h}h${m}m';
  }

  @override
  String get radarStatus3 => '🇬🇧 伦敦盘爆发中';

  @override
  String get radarDesc3 => '欧洲资金进场，日线挂单迎来首波突破与测试';

  @override
  String radarCount3(String h, String m) {
    return '距 20:30 主战场 ${h}h${m}m';
  }

  @override
  String get radarStatus4 => '🔥 伦纽重叠主战场';

  @override
  String get radarDesc4 => '全天最大波动窗口！20:30-24:00 留意 Trade 1 止盈与推保本';

  @override
  String radarCount4(String h, String m) {
    return '距重叠期结束 ${h}h${m}m';
  }

  @override
  String get radarStatus5 => '🌙 纽约尾盘与休市';

  @override
  String get radarDesc5 => '市场趋缓，保持良好作息，迎接明日晨间开盘';

  @override
  String radarCount5(String h, String m) {
    return '距明日 07:00 晨盘 ${h}h${m}m';
  }

  @override
  String get msgNoSelection => '选择 2~3 个品种后，系统将自动自审同向汇率共振风险。';

  @override
  String get msgShortRisk =>
      '⚠️ 危险重叠！当前 3 笔交易全部在单向【做空美元 (Short USD)】！属于同质化单向敞口，若非农/CPI数据强劲，将遭遇 6% 连环爆仓回撤！建议拆解或换交叉盘。';

  @override
  String get msgLongRisk =>
      '⚠️ 危险重叠！当前 3 笔交易全部在单向【做多美元 (Long USD)】！一旦美元反转将全部止损，建议降低同质化敞口。';

  @override
  String get msgSafe =>
      '✅ 晨间 10 秒自审通过：3 笔交易不存在单向同质化敞口，结构独立，可安全同时建仓（总日风险控制在 6% 内）！';

  @override
  String get avoidTitle => '🚫 坚决规避的毒药品种 (The Avoid List)';

  @override
  String get avoidDesc => '以下四类品种在实战中看似有机会，实则暗藏点差与政策陷阱，强烈建议拉黑跳过：';

  @override
  String get avoidCard1Title => '1. 联系汇率挂钩类 (画直线)';

  @override
  String get avoidCard1Reason => '受央行强行挂钩制度约束，K线基本为水平直线，日波动甚至小于点差，毫无交易价值。';

  @override
  String get avoidCard2Title => '2. 高息吃人断崖类 (点差过宽)';

  @override
  String get avoidCard2Reason => '新兴市场货币恶性贬值，看似单边躺赚，但隔夜利息极其昂贵且极易发生政策跳空，利润全被磨光。';

  @override
  String get avoidCard3Title => '3. 极低流动性类 (严重滑点)';

  @override
  String get avoidCard3Reason => '挂单成交极不活跃，止损往往无法在预设点位成交，遭遇极端滑点击穿账户。';

  @override
  String get avoidCard4Title => '4. 恶劣交叉盘规避';

  @override
  String get avoidCard4Reason => '虽然日均波幅极大，但点差同样极其昂贵，盈利空间往往刚好抵消高额交易成本。';

  @override
  String get pageOverlapTitle => '🛡️ 多单并行防呆与自审';

  @override
  String get btnAtlas => '16品种图鉴';

  @override
  String get btnAvoid => '毒药黑名单';

  @override
  String get txtStandard => '规范选项：⭐ 7大核心货币对 (极低点差) + 🔹 9大次要交叉盘';

  @override
  String get btnDetail => '详解 >';

  @override
  String get trade1 => '交易 1 (首选主线)';

  @override
  String get trade2 => '交易 2 (独立隔离)';

  @override
  String get trade3 => '交易 3 (独立隔离)';

  @override
  String get dirLong => '多';

  @override
  String get dirShort => '空';

  @override
  String get radarRiskTitle => '晨间自审预警：同质化过度曝险';

  @override
  String get radarSafeTitle => '晨间 10 秒风控自审雷达';

  @override
  String get chkTitle => '飞行员起飞前：最后 10 秒防呆自检';

  @override
  String get chkClear => '准许执行 (CLEAR TO ENGAGE)';

  @override
  String get chk1 => '日内无重大数据发布 (如非农、CPI等核弹级数据)';

  @override
  String get chk2 => '情绪绝对平稳，未受上笔交易 (大赚/大亏) 的 FOMO 影响';

  @override
  String get chk3 => '严格遵循 DT 双轨制，已预设 Trade 1 的保本与止盈';

  @override
  String get chk4 => '单笔总风险严格控制在 2% 内，绝不抱有重仓扛单侥幸';

  @override
  String get calcTableTitle => '🧮 500 - 3,200 美元双轨最大手数对照表';

  @override
  String get calcTableDesc => '点击任意行可直接快速载入该资金配置 (总手数恒为偶数，保证 2 x 1% 完美平分)：';

  @override
  String calcTableRedLine(String risk) {
    return '2% 红线: \$$risk';
  }

  @override
  String get calcTableNotAvailable => '🚫 不可用 (超标)';

  @override
  String get calcAccountStd => '🏢 XM 标准/Ultra Low (1手=100k)';

  @override
  String get calcAccountMicro => '🔬 XM Micro 微型 (1手=1k)';

  @override
  String get calcPointLink => '点值梯队联动 (自动载入 ATR 止损基准): ';

  @override
  String get calcCurrentPair => '当前: ';

  @override
  String get calcBalTitle => '账户总资金 (Balance)';

  @override
  String get calcRateTitle => '当前汇率 (USD/MYR)';

  @override
  String get calcRiskTitle => '单笔总风险 (Risk %)';

  @override
  String get calcSlTitle => '止损点数 (Stop Loss Pips)';

  @override
  String get calcResultTitle => '📊 双轨分仓执行计划';

  @override
  String get calcResultMaxLoss => '单笔最大允许亏损: ';

  @override
  String get calcResultTotalLots => '总开仓手数 (Total Lots)';

  @override
  String get calcResultInsufficient => '⚠️ 资金不足以执行 2% 风险标准，总手数低于 0.02 手';

  @override
  String get calcResultTrade1 => 'Trade 1: 1% 风险首战 (激进)';

  @override
  String get calcResultTrade2 => 'Trade 2: 1% 风险次战 (保守)';

  @override
  String get iqTitle => '🧠 Fight IQ: 当前品种蜡烛健康诊断';

  @override
  String get iqGold1Title => '🟡 黄金噪音小蜡烛 (< 150 Pips / < \$15)';

  @override
  String get iqGold1Desc => '机构未发力，多为震荡横盘噪音，极易假突破，不建议做突破挂单。';

  @override
  String get iqGold2Title => '🟢 黄金标准舒适区 (150 ~ 250 Pips / \$15~\$25)';

  @override
  String get iqGold2Desc => '完美标准日线吞没！动能充沛，突破法与 50% 回撤法均可完美执行！';

  @override
  String get iqGold3Title => '🔵 黄金偏大蜡烛 (250 ~ 350 Pips / \$25~\$35)';

  @override
  String get iqGold3Desc => '突破止损偏大，严禁追突破挂单！必须用 Fib 50% 回踩折半入场！';

  @override
  String get iqGold4Title => '🛑 黄金极端力竭蜡烛 (> 350 Pips / > \$35)';

  @override
  String get iqGold4Desc => '情绪过热暴冲！次日极易深度反抽或扫损，系统强烈建议直接放弃！';

  @override
  String get iqFx1Title => '🟡 比较短的蜡烛 (< 50 Pips)';

  @override
  String get iqFx1Desc => '日内波动偏小。此时 50% 回调位太近易被噪音扫损，建议仅采用【突破法挂单】。';

  @override
  String get iqFx2Title => '🟢 标准外汇波动 (50 ~ 80 Pips)';

  @override
  String get iqFx2Desc => '完美舒适区！波动充足且方向明确，突破法与 50% 回调法均可完美执行！';

  @override
  String get iqFx3Title => '🔵 偏大蜡烛 (80 ~ 100 Pips)';

  @override
  String get iqFx3Desc => '突破止损偏大。强烈建议使用【50% 回调法】，将入场风险折半压缩至 40~50 Pips！';

  @override
  String get iqFx4Title => '🛑 极端力竭蜡烛 (> 100 Pips)';

  @override
  String get iqFx4Desc => '情绪力竭暴冲！盈亏比极差，系统强烈建议直接放弃交易，坚决不介入！';

  @override
  String get btnQuickSelect => '快速选择';

  @override
  String get btnLiveRate => '获取实时汇率';
}
