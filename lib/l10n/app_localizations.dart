import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'双轨风控大师 Pro'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get navHome;

  /// No description provided for @navRisk.
  ///
  /// In zh, this message translates to:
  /// **'组合防呆'**
  String get navRisk;

  /// No description provided for @navDual.
  ///
  /// In zh, this message translates to:
  /// **'双轨手数'**
  String get navDual;

  /// No description provided for @navSniper.
  ///
  /// In zh, this message translates to:
  /// **'吞没狙击'**
  String get navSniper;

  /// No description provided for @navTrend.
  ///
  /// In zh, this message translates to:
  /// **'复利走势'**
  String get navTrend;

  /// No description provided for @msgOpeningXM.
  ///
  /// In zh, this message translates to:
  /// **'正在前往 XM 官方认证开户通道...'**
  String get msgOpeningXM;

  /// No description provided for @titleXMBanner.
  ///
  /// In zh, this message translates to:
  /// **'XM 官方认证开户通道 (专属活动)'**
  String get titleXMBanner;

  /// No description provided for @descXMBanner.
  ///
  /// In zh, this message translates to:
  /// **'点击立即注册，尊享极低点差与入金赠金'**
  String get descXMBanner;

  /// No description provided for @titleMantra.
  ///
  /// In zh, this message translates to:
  /// **'吞没战法实战三句真诀 (必须焊死在脑海)：'**
  String get titleMantra;

  /// No description provided for @mantra1Title.
  ///
  /// In zh, this message translates to:
  /// **'① 做多确认看实体吞没 —— '**
  String get mantra1Title;

  /// No description provided for @mantra1Desc.
  ///
  /// In zh, this message translates to:
  /// **'形态真假看 Body，后一根实体必须彻底吃掉前一根；'**
  String get mantra1Desc;

  /// No description provided for @mantra2Title.
  ///
  /// In zh, this message translates to:
  /// **'② 止损躲在全区最低影线底 —— '**
  String get mantra2Title;

  /// No description provided for @mantra2Desc.
  ///
  /// In zh, this message translates to:
  /// **'取整片形态区域 (母烛 + 前置烛) 最低的下影线 (Lowest Wick) - 10p；'**
  String get mantra2Desc;

  /// No description provided for @mantra3Title.
  ///
  /// In zh, this message translates to:
  /// **'③ 50% 取自全区极高与极低的中点 —— '**
  String get mantra3Title;

  /// No description provided for @mantra3Desc.
  ///
  /// In zh, this message translates to:
  /// **'(全区最高 High + 全区最低 Low) ÷ 2，绝不仅看单根母烛！'**
  String get mantra3Desc;

  /// No description provided for @titleBlueprint.
  ///
  /// In zh, this message translates to:
  /// **'吞没结构与黄金口袋解剖蓝图'**
  String get titleBlueprint;

  /// No description provided for @tagMultiK.
  ///
  /// In zh, this message translates to:
  /// **'多重 K 线形态区'**
  String get tagMultiK;

  /// No description provided for @descBlueprint.
  ///
  /// In zh, this message translates to:
  /// **'黄金口袋 50% 模式：全区极值画网，回踩入场将止损精准压缩'**
  String get descBlueprint;

  /// No description provided for @blueprintHigh.
  ///
  /// In zh, this message translates to:
  /// **'全区最高价 High'**
  String get blueprintHigh;

  /// No description provided for @blueprintLow.
  ///
  /// In zh, this message translates to:
  /// **'全区最低价 Low'**
  String get blueprintLow;

  /// No description provided for @radarStatus1.
  ///
  /// In zh, this message translates to:
  /// **'🌅 晨间设单窗口'**
  String get radarStatus1;

  /// No description provided for @radarDesc1.
  ///
  /// In zh, this message translates to:
  /// **'D1 日线收盘，7:00-8:00 挂单后关闭软件 (Set & Forget)'**
  String get radarDesc1;

  /// No description provided for @radarCount1.
  ///
  /// In zh, this message translates to:
  /// **'距窗口关闭 {diff}分'**
  String radarCount1(String diff);

  /// No description provided for @radarStatus2.
  ///
  /// In zh, this message translates to:
  /// **'☕ 亚盘静默观察期'**
  String get radarStatus2;

  /// No description provided for @radarDesc2.
  ///
  /// In zh, this message translates to:
  /// **'让市场来找我。亚盘波动小，绝不因 FOMO 手动追单'**
  String get radarDesc2;

  /// No description provided for @radarCount2.
  ///
  /// In zh, this message translates to:
  /// **'距 15:00 伦敦盘 {h}h{m}m'**
  String radarCount2(String h, String m);

  /// No description provided for @radarStatus3.
  ///
  /// In zh, this message translates to:
  /// **'🇬🇧 伦敦盘爆发中'**
  String get radarStatus3;

  /// No description provided for @radarDesc3.
  ///
  /// In zh, this message translates to:
  /// **'欧洲资金进场，日线挂单迎来首波突破与测试'**
  String get radarDesc3;

  /// No description provided for @radarCount3.
  ///
  /// In zh, this message translates to:
  /// **'距 20:30 主战场 {h}h{m}m'**
  String radarCount3(String h, String m);

  /// No description provided for @radarStatus4.
  ///
  /// In zh, this message translates to:
  /// **'🔥 伦纽重叠主战场'**
  String get radarStatus4;

  /// No description provided for @radarDesc4.
  ///
  /// In zh, this message translates to:
  /// **'全天最大波动窗口！20:30-24:00 留意 Trade 1 止盈与推保本'**
  String get radarDesc4;

  /// No description provided for @radarCount4.
  ///
  /// In zh, this message translates to:
  /// **'距重叠期结束 {h}h{m}m'**
  String radarCount4(String h, String m);

  /// No description provided for @radarStatus5.
  ///
  /// In zh, this message translates to:
  /// **'🌙 纽约尾盘与休市'**
  String get radarStatus5;

  /// No description provided for @radarDesc5.
  ///
  /// In zh, this message translates to:
  /// **'市场趋缓，保持良好作息，迎接明日晨间开盘'**
  String get radarDesc5;

  /// No description provided for @radarCount5.
  ///
  /// In zh, this message translates to:
  /// **'距明日 07:00 晨盘 {h}h{m}m'**
  String radarCount5(String h, String m);

  /// No description provided for @msgNoSelection.
  ///
  /// In zh, this message translates to:
  /// **'选择 2~3 个品种后，系统将自动自审同向汇率共振风险。'**
  String get msgNoSelection;

  /// No description provided for @msgShortRisk.
  ///
  /// In zh, this message translates to:
  /// **'⚠️ 危险重叠！当前 3 笔交易全部在单向【做空美元 (Short USD)】！属于同质化单向敞口，若非农/CPI数据强劲，将遭遇 6% 连环爆仓回撤！建议拆解或换交叉盘。'**
  String get msgShortRisk;

  /// No description provided for @msgLongRisk.
  ///
  /// In zh, this message translates to:
  /// **'⚠️ 危险重叠！当前 3 笔交易全部在单向【做多美元 (Long USD)】！一旦美元反转将全部止损，建议降低同质化敞口。'**
  String get msgLongRisk;

  /// No description provided for @msgSafe.
  ///
  /// In zh, this message translates to:
  /// **'✅ 晨间 10 秒自审通过：3 笔交易不存在单向同质化敞口，结构独立，可安全同时建仓（总日风险控制在 6% 内）！'**
  String get msgSafe;

  /// No description provided for @avoidTitle.
  ///
  /// In zh, this message translates to:
  /// **'🚫 坚决规避的毒药品种 (The Avoid List)'**
  String get avoidTitle;

  /// No description provided for @avoidDesc.
  ///
  /// In zh, this message translates to:
  /// **'以下四类品种在实战中看似有机会，实则暗藏点差与政策陷阱，强烈建议拉黑跳过：'**
  String get avoidDesc;

  /// No description provided for @avoidCard1Title.
  ///
  /// In zh, this message translates to:
  /// **'1. 联系汇率挂钩类 (画直线)'**
  String get avoidCard1Title;

  /// No description provided for @avoidCard1Reason.
  ///
  /// In zh, this message translates to:
  /// **'受央行强行挂钩制度约束，K线基本为水平直线，日波动甚至小于点差，毫无交易价值。'**
  String get avoidCard1Reason;

  /// No description provided for @avoidCard2Title.
  ///
  /// In zh, this message translates to:
  /// **'2. 高息吃人断崖类 (点差过宽)'**
  String get avoidCard2Title;

  /// No description provided for @avoidCard2Reason.
  ///
  /// In zh, this message translates to:
  /// **'新兴市场货币恶性贬值，看似单边躺赚，但隔夜利息极其昂贵且极易发生政策跳空，利润全被磨光。'**
  String get avoidCard2Reason;

  /// No description provided for @avoidCard3Title.
  ///
  /// In zh, this message translates to:
  /// **'3. 极低流动性类 (严重滑点)'**
  String get avoidCard3Title;

  /// No description provided for @avoidCard3Reason.
  ///
  /// In zh, this message translates to:
  /// **'挂单成交极不活跃，止损往往无法在预设点位成交，遭遇极端滑点击穿账户。'**
  String get avoidCard3Reason;

  /// No description provided for @avoidCard4Title.
  ///
  /// In zh, this message translates to:
  /// **'4. 恶劣交叉盘规避'**
  String get avoidCard4Title;

  /// No description provided for @avoidCard4Reason.
  ///
  /// In zh, this message translates to:
  /// **'虽然日均波幅极大，但点差同样极其昂贵，盈利空间往往刚好抵消高额交易成本。'**
  String get avoidCard4Reason;

  /// No description provided for @pageOverlapTitle.
  ///
  /// In zh, this message translates to:
  /// **'🛡️ 多单并行防呆与自审'**
  String get pageOverlapTitle;

  /// No description provided for @btnAtlas.
  ///
  /// In zh, this message translates to:
  /// **'16品种图鉴'**
  String get btnAtlas;

  /// No description provided for @btnAvoid.
  ///
  /// In zh, this message translates to:
  /// **'毒药黑名单'**
  String get btnAvoid;

  /// No description provided for @txtStandard.
  ///
  /// In zh, this message translates to:
  /// **'规范选项：⭐ 7大核心货币对 (极低点差) + 🔹 9大次要交叉盘'**
  String get txtStandard;

  /// No description provided for @btnDetail.
  ///
  /// In zh, this message translates to:
  /// **'详解 >'**
  String get btnDetail;

  /// No description provided for @trade1.
  ///
  /// In zh, this message translates to:
  /// **'交易 1 (首选主线)'**
  String get trade1;

  /// No description provided for @trade2.
  ///
  /// In zh, this message translates to:
  /// **'交易 2 (独立隔离)'**
  String get trade2;

  /// No description provided for @trade3.
  ///
  /// In zh, this message translates to:
  /// **'交易 3 (独立隔离)'**
  String get trade3;

  /// No description provided for @dirLong.
  ///
  /// In zh, this message translates to:
  /// **'多'**
  String get dirLong;

  /// No description provided for @dirShort.
  ///
  /// In zh, this message translates to:
  /// **'空'**
  String get dirShort;

  /// No description provided for @radarRiskTitle.
  ///
  /// In zh, this message translates to:
  /// **'晨间自审预警：同质化过度曝险'**
  String get radarRiskTitle;

  /// No description provided for @radarSafeTitle.
  ///
  /// In zh, this message translates to:
  /// **'晨间 10 秒风控自审雷达'**
  String get radarSafeTitle;

  /// No description provided for @chkTitle.
  ///
  /// In zh, this message translates to:
  /// **'飞行员起飞前：最后 10 秒防呆自检'**
  String get chkTitle;

  /// No description provided for @chkClear.
  ///
  /// In zh, this message translates to:
  /// **'准许执行 (CLEAR TO ENGAGE)'**
  String get chkClear;

  /// No description provided for @chk1.
  ///
  /// In zh, this message translates to:
  /// **'日内无重大数据发布 (如非农、CPI等核弹级数据)'**
  String get chk1;

  /// No description provided for @chk2.
  ///
  /// In zh, this message translates to:
  /// **'情绪绝对平稳，未受上笔交易 (大赚/大亏) 的 FOMO 影响'**
  String get chk2;

  /// No description provided for @chk3.
  ///
  /// In zh, this message translates to:
  /// **'严格遵循 DT 双轨制，已预设 Trade 1 的保本与止盈'**
  String get chk3;

  /// No description provided for @chk4.
  ///
  /// In zh, this message translates to:
  /// **'单笔总风险严格控制在 2% 内，绝不抱有重仓扛单侥幸'**
  String get chk4;

  /// No description provided for @calcTableTitle.
  ///
  /// In zh, this message translates to:
  /// **'🧮 500 - 3,200 美元双轨最大手数对照表'**
  String get calcTableTitle;

  /// No description provided for @calcTableDesc.
  ///
  /// In zh, this message translates to:
  /// **'点击任意行可直接快速载入该资金配置 (总手数恒为偶数，保证 2 x 1% 完美平分)：'**
  String get calcTableDesc;

  /// No description provided for @calcTableRedLine.
  ///
  /// In zh, this message translates to:
  /// **'2% 红线: \${risk}'**
  String calcTableRedLine(String risk);

  /// No description provided for @calcTableNotAvailable.
  ///
  /// In zh, this message translates to:
  /// **'🚫 不可用 (超标)'**
  String get calcTableNotAvailable;

  /// No description provided for @calcAccountStd.
  ///
  /// In zh, this message translates to:
  /// **'🏢 XM 标准/Ultra Low (1手=100k)'**
  String get calcAccountStd;

  /// No description provided for @calcAccountMicro.
  ///
  /// In zh, this message translates to:
  /// **'🔬 XM Micro 微型 (1手=1k)'**
  String get calcAccountMicro;

  /// No description provided for @calcPointLink.
  ///
  /// In zh, this message translates to:
  /// **'点值梯队联动 (自动载入 ATR 止损基准): '**
  String get calcPointLink;

  /// No description provided for @calcCurrentPair.
  ///
  /// In zh, this message translates to:
  /// **'当前: '**
  String get calcCurrentPair;

  /// No description provided for @calcBalTitle.
  ///
  /// In zh, this message translates to:
  /// **'账户总资金 (Balance)'**
  String get calcBalTitle;

  /// No description provided for @calcRateTitle.
  ///
  /// In zh, this message translates to:
  /// **'当前汇率 (USD/MYR)'**
  String get calcRateTitle;

  /// No description provided for @calcRiskTitle.
  ///
  /// In zh, this message translates to:
  /// **'单笔总风险 (Risk %)'**
  String get calcRiskTitle;

  /// No description provided for @calcSlTitle.
  ///
  /// In zh, this message translates to:
  /// **'止损点数 (Stop Loss Pips)'**
  String get calcSlTitle;

  /// No description provided for @calcResultTitle.
  ///
  /// In zh, this message translates to:
  /// **'📊 双轨分仓执行计划'**
  String get calcResultTitle;

  /// No description provided for @calcResultMaxLoss.
  ///
  /// In zh, this message translates to:
  /// **'单笔最大允许亏损: '**
  String get calcResultMaxLoss;

  /// No description provided for @calcResultTotalLots.
  ///
  /// In zh, this message translates to:
  /// **'总开仓手数 (Total Lots)'**
  String get calcResultTotalLots;

  /// No description provided for @calcResultInsufficient.
  ///
  /// In zh, this message translates to:
  /// **'⚠️ 资金不足以执行 2% 风险标准，总手数低于 0.02 手'**
  String get calcResultInsufficient;

  /// No description provided for @calcResultTrade1.
  ///
  /// In zh, this message translates to:
  /// **'Trade 1: 1% 风险首战 (激进)'**
  String get calcResultTrade1;

  /// No description provided for @calcResultTrade2.
  ///
  /// In zh, this message translates to:
  /// **'Trade 2: 1% 风险次战 (保守)'**
  String get calcResultTrade2;

  /// No description provided for @iqTitle.
  ///
  /// In zh, this message translates to:
  /// **'🧠 Fight IQ: 当前品种蜡烛健康诊断'**
  String get iqTitle;

  /// No description provided for @iqGold1Title.
  ///
  /// In zh, this message translates to:
  /// **'🟡 黄金噪音小蜡烛 (< 150 Pips / < \$15)'**
  String get iqGold1Title;

  /// No description provided for @iqGold1Desc.
  ///
  /// In zh, this message translates to:
  /// **'机构未发力，多为震荡横盘噪音，极易假突破，不建议做突破挂单。'**
  String get iqGold1Desc;

  /// No description provided for @iqGold2Title.
  ///
  /// In zh, this message translates to:
  /// **'🟢 黄金标准舒适区 (150 ~ 250 Pips / \$15~\$25)'**
  String get iqGold2Title;

  /// No description provided for @iqGold2Desc.
  ///
  /// In zh, this message translates to:
  /// **'完美标准日线吞没！动能充沛，突破法与 50% 回撤法均可完美执行！'**
  String get iqGold2Desc;

  /// No description provided for @iqGold3Title.
  ///
  /// In zh, this message translates to:
  /// **'🔵 黄金偏大蜡烛 (250 ~ 350 Pips / \$25~\$35)'**
  String get iqGold3Title;

  /// No description provided for @iqGold3Desc.
  ///
  /// In zh, this message translates to:
  /// **'突破止损偏大，严禁追突破挂单！必须用 Fib 50% 回踩折半入场！'**
  String get iqGold3Desc;

  /// No description provided for @iqGold4Title.
  ///
  /// In zh, this message translates to:
  /// **'🛑 黄金极端力竭蜡烛 (> 350 Pips / > \$35)'**
  String get iqGold4Title;

  /// No description provided for @iqGold4Desc.
  ///
  /// In zh, this message translates to:
  /// **'情绪过热暴冲！次日极易深度反抽或扫损，系统强烈建议直接放弃！'**
  String get iqGold4Desc;

  /// No description provided for @iqFx1Title.
  ///
  /// In zh, this message translates to:
  /// **'🟡 比较短的蜡烛 (< 50 Pips)'**
  String get iqFx1Title;

  /// No description provided for @iqFx1Desc.
  ///
  /// In zh, this message translates to:
  /// **'日内波动偏小。此时 50% 回调位太近易被噪音扫损，建议仅采用【突破法挂单】。'**
  String get iqFx1Desc;

  /// No description provided for @iqFx2Title.
  ///
  /// In zh, this message translates to:
  /// **'🟢 标准外汇波动 (50 ~ 80 Pips)'**
  String get iqFx2Title;

  /// No description provided for @iqFx2Desc.
  ///
  /// In zh, this message translates to:
  /// **'完美舒适区！波动充足且方向明确，突破法与 50% 回调法均可完美执行！'**
  String get iqFx2Desc;

  /// No description provided for @iqFx3Title.
  ///
  /// In zh, this message translates to:
  /// **'🔵 偏大蜡烛 (80 ~ 100 Pips)'**
  String get iqFx3Title;

  /// No description provided for @iqFx3Desc.
  ///
  /// In zh, this message translates to:
  /// **'突破止损偏大。强烈建议使用【50% 回调法】，将入场风险折半压缩至 40~50 Pips！'**
  String get iqFx3Desc;

  /// No description provided for @iqFx4Title.
  ///
  /// In zh, this message translates to:
  /// **'🛑 极端力竭蜡烛 (> 100 Pips)'**
  String get iqFx4Title;

  /// No description provided for @iqFx4Desc.
  ///
  /// In zh, this message translates to:
  /// **'情绪力竭暴冲！盈亏比极差，系统强烈建议直接放弃交易，坚决不介入！'**
  String get iqFx4Desc;

  /// No description provided for @btnQuickSelect.
  ///
  /// In zh, this message translates to:
  /// **'快速选择'**
  String get btnQuickSelect;

  /// No description provided for @btnLiveRate.
  ///
  /// In zh, this message translates to:
  /// **'获取实时汇率'**
  String get btnLiveRate;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ms', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ms':
      return AppLocalizationsMs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
