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
}
