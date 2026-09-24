// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dual-Track Risk Master Pro';

  @override
  String get navHome => 'Home';

  @override
  String get navRisk => 'Risk Check';

  @override
  String get navDual => 'Dual Lots';

  @override
  String get navSniper => 'Sniper';

  @override
  String get navTrend => 'Compounding';

  @override
  String get msgOpeningXM => 'Opening XM Official Account Registration...';

  @override
  String get titleXMBanner => 'XM Official Account Registration (Exclusive)';

  @override
  String get descXMBanner =>
      'Click to register now, enjoy ultra-low spreads and deposit bonuses';

  @override
  String get titleMantra =>
      'Three Mantras of Engulfing Strategy (Memorize this):';

  @override
  String get mantra1Title => '① Long confirmation needs body engulfing —— ';

  @override
  String get mantra1Desc =>
      'Judge the pattern by Body, the latter body must completely swallow the former;';

  @override
  String get mantra2Title => '② Stop loss hides below the lowest wick —— ';

  @override
  String get mantra2Desc =>
      'Take the lowest wick of the entire pattern area (Mother + Previous) - 10p;';

  @override
  String get mantra3Title =>
      '③ 50% is from the midpoint of highest and lowest —— ';

  @override
  String get mantra3Desc =>
      '(Highest High + Lowest Low) ÷ 2, never just look at the single mother candle!';

  @override
  String get titleBlueprint => 'Engulfing Structure & Golden Pocket Blueprint';

  @override
  String get tagMultiK => 'Multi-Candlestick Pattern Zone';

  @override
  String get descBlueprint =>
      'Golden Pocket 50% Mode: Draw fibs on extremes, entry on pullback precisely compresses stop loss';

  @override
  String get blueprintHigh => 'Highest Price High';

  @override
  String get blueprintLow => 'Lowest Price Low';

  @override
  String get radarStatus1 => '🌅 Morning Order Window';

  @override
  String get radarDesc1 =>
      'D1 Closes, set orders 7:00-8:00 and close app (Set & Forget)';

  @override
  String radarCount1(String diff) {
    return '${diff}m until window closes';
  }

  @override
  String get radarStatus2 => '☕ Asian Session (Observation)';

  @override
  String get radarDesc2 =>
      'Let the market come. Low volatility, NO FOMO manual entries.';

  @override
  String radarCount2(String h, String m) {
    return 'London Session in ${h}h${m}m';
  }

  @override
  String get radarStatus3 => '🇬🇧 London Session Breakout';

  @override
  String get radarDesc3 =>
      'European funds enter, first breakout test for daily orders';

  @override
  String radarCount3(String h, String m) {
    return 'Main NY battle in ${h}h${m}m';
  }

  @override
  String get radarStatus4 => '🔥 London & NY Overlap (High Volatility)';

  @override
  String get radarDesc4 =>
      'Biggest volatility window! 20:30-24:00 monitor TP1 and BE moves';

  @override
  String radarCount4(String h, String m) {
    return '${h}h${m}m until overlap ends';
  }

  @override
  String get radarStatus5 => '🌙 NY Close & Market Closed';

  @override
  String get radarDesc5 =>
      'Market slows. Maintain good routine for tomorrow\'s open.';

  @override
  String radarCount5(String h, String m) {
    return 'Tomorrow\'s open in ${h}h${m}m';
  }

  @override
  String get msgNoSelection =>
      'Select 2-3 pairs to automatically audit directional correlation risks.';

  @override
  String get msgShortRisk =>
      '⚠️ DANGER OVERLAP! All 3 trades are heavily shorting USD. This is a massive one-sided exposure. Strong NFP/CPI will trigger a 6% chain-reaction drawdown! Swap one out.';

  @override
  String get msgLongRisk =>
      '⚠️ DANGER OVERLAP! All 3 trades are heavily long on USD. A reversal will wipe out all stop losses. Reduce exposure.';

  @override
  String get msgSafe =>
      '✅ 10s Morning Audit Passed: The 3 trades are independent with no heavy correlation. Safe to execute simultaneously (Risk within 6%).';

  @override
  String get avoidTitle => '🚫 Toxic Pairs (The Avoid List)';

  @override
  String get avoidDesc =>
      'These pairs might look tempting but harbor massive spread/policy traps. Blacklist them:';

  @override
  String get avoidCard1Title => '1. Pegged Currencies (Flatlines)';

  @override
  String get avoidCard1Reason =>
      'Pegged by central banks, charts look like flatlines. Daily volatility is smaller than the spread. Zero trade value.';

  @override
  String get avoidCard2Title => '2. High-Yield Exotics (Widened Spread)';

  @override
  String get avoidCard2Reason =>
      'Emerging markets hyper-devaluation. Huge overnight swap fees and massive policy gaps will destroy your profits.';

  @override
  String get avoidCard3Title => '3. Ultra-Low Liquidity (Severe Slippage)';

  @override
  String get avoidCard3Reason =>
      'Extremely inactive. Stop losses won\'t trigger at set prices, leading to devastating slippage.';

  @override
  String get avoidCard4Title => '4. Toxic Cross Pairs';

  @override
  String get avoidCard4Reason =>
      'High daily range, but extremely expensive spreads. Profit margins just offset trading costs.';

  @override
  String get pageOverlapTitle => '🛡️ Overlap & Exposure Checker';

  @override
  String get btnAtlas => '16-Pair Atlas';

  @override
  String get btnAvoid => 'Toxic Blacklist';

  @override
  String get txtStandard =>
      'Standard: ⭐ 7 Core Pairs (Low Spread) + 🔹 9 Minors';

  @override
  String get btnDetail => 'Details >';

  @override
  String get trade1 => 'Trade 1 (Primary)';

  @override
  String get trade2 => 'Trade 2 (Isolated)';

  @override
  String get trade3 => 'Trade 3 (Isolated)';

  @override
  String get dirLong => 'Long';

  @override
  String get dirShort => 'Short';

  @override
  String get radarRiskTitle => 'Morning Alert: Heavy Correlation Risk';

  @override
  String get radarSafeTitle => '10s Morning Risk Radar';

  @override
  String get chkTitle => 'Pre-Flight: Final 10s Dummy Check';

  @override
  String get chkClear => 'CLEAR TO ENGAGE';

  @override
  String get chk1 => 'No major news today (e.g. NFP, CPI nuclear data)';

  @override
  String get chk2 =>
      'Emotionally stable, no FOMO from previous trade (big win/loss)';

  @override
  String get chk3 => 'Strictly following DT Dual Track, Trade 1 BE & TP set';

  @override
  String get chk4 => 'Total risk strictly within 2%, no heavy lot gambling';

  @override
  String get calcTableTitle => '🧮 \$500 - \$3,200 Dual Track Max Lot Table';

  @override
  String get calcTableDesc =>
      'Tap any row to quickly load the capital config (Total lots always even for perfect 2 x 1% split):';

  @override
  String calcTableRedLine(String risk) {
    return '2% Redline: \$$risk';
  }

  @override
  String get calcTableNotAvailable => '🚫 N/A (Exceeds Risk)';

  @override
  String get calcAccountStd => '🏢 XM Standard/Ultra Low (1 Lot=100k)';

  @override
  String get calcAccountMicro => '🔬 XM Micro (1 Lot=1k)';

  @override
  String get calcPointLink => 'Pip Value Tier Link (Auto ATR Stop Loss): ';

  @override
  String get calcCurrentPair => 'Current: ';

  @override
  String get calcBalTitle => 'Account Balance';

  @override
  String get calcRateTitle => 'Exchange Rate (USD/MYR)';

  @override
  String get calcRiskTitle => 'Total Risk per Trade (%)';

  @override
  String get calcSlTitle => 'Stop Loss (Pips)';

  @override
  String get calcResultTitle => '📊 Dual Track Execution Plan';

  @override
  String get calcResultMaxLoss => 'Max Allowed Loss per Trade: ';

  @override
  String get calcResultTotalLots => 'Total Execution Lots';

  @override
  String get calcResultInsufficient =>
      '⚠️ Insufficient balance for 2% risk, total lots under 0.02';

  @override
  String get calcResultTrade1 => 'Trade 1: 1% Risk (Aggressive)';

  @override
  String get calcResultTrade2 => 'Trade 2: 1% Risk (Conservative)';

  @override
  String get iqTitle => '🧠 Fight IQ: Candle Health Diagnosis';

  @override
  String get iqGold1Title => '🟡 Gold Noise Small Candle (< 150 Pips / < \$15)';

  @override
  String get iqGold1Desc =>
      'Institutions inactive, mostly sideways noise. High risk of fakeouts. Pending breakout orders not recommended.';

  @override
  String get iqGold2Title =>
      '🟢 Gold Standard Comfort Zone (150 ~ 250 Pips / \$15~\$25)';

  @override
  String get iqGold2Desc =>
      'Perfect standard daily engulfing! High momentum, both Breakout and 50% Pullback methods work perfectly!';

  @override
  String get iqGold3Title =>
      '🔵 Gold Large Candle (250 ~ 350 Pips / \$25~\$35)';

  @override
  String get iqGold3Desc =>
      'Breakout stop loss too large. NO pending breakout orders! Must use Fib 50% pullback entry to halve the risk!';

  @override
  String get iqGold4Title =>
      '🛑 Gold Extreme Exhaustion Candle (> 350 Pips / > \$35)';

  @override
  String get iqGold4Desc =>
      'Overheated emotion surge! High risk of deep reversal or stop out next day. System strongly recommends skipping!';

  @override
  String get iqFx1Title => '🟡 Short Candle (< 50 Pips)';

  @override
  String get iqFx1Desc =>
      'Small daily volatility. 50% pullback level is too close and risks being stopped out by noise. Breakout pending orders only.';

  @override
  String get iqFx2Title => '🟢 Standard FX Volatility (50 ~ 80 Pips)';

  @override
  String get iqFx2Desc =>
      'Perfect comfort zone! Sufficient volatility and clear direction. Both Breakout and 50% Pullback methods work perfectly!';

  @override
  String get iqFx3Title => '🔵 Large Candle (80 ~ 100 Pips)';

  @override
  String get iqFx3Desc =>
      'Breakout stop loss too large. Strongly recommend 【50% Pullback method】 to compress entry risk to 40-50 Pips!';

  @override
  String get iqFx4Title => '🛑 Extreme Exhaustion Candle (> 100 Pips)';

  @override
  String get iqFx4Desc =>
      'Exhaustion surge! Terrible risk-reward ratio. System strongly recommends skipping the trade entirely!';

  @override
  String get btnQuickSelect => 'Quick Select';

  @override
  String get btnLiveRate => 'Live Rate';
}
