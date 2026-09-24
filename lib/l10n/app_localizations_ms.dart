// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'Pakar Risiko Dual-Track Pro';

  @override
  String get navHome => 'Utama';

  @override
  String get navRisk => 'Semakan';

  @override
  String get navDual => 'Lot Dual';

  @override
  String get navSniper => 'Sniper';

  @override
  String get navTrend => 'Trend';

  @override
  String get msgOpeningXM => 'Membuka Saluran Pendaftaran Akaun Rasmi XM...';

  @override
  String get titleXMBanner => 'Saluran Pendaftaran Akaun Rasmi XM (Eksklusif)';

  @override
  String get descXMBanner =>
      'Klik untuk daftar sekarang, nikmati spread sangat rendah dan bonus deposit';

  @override
  String get titleMantra => 'Tiga Mantra Strategi Engulfing (Wajib Ingat):';

  @override
  String get mantra1Title => '① Pengesahan Long perlukan engulfing body —— ';

  @override
  String get mantra1Desc =>
      'Nilai corak dari Body, body kedua mesti telan body pertama sepenuhnya;';

  @override
  String get mantra2Title => '② Stop loss sembunyi di bawah wick terendah —— ';

  @override
  String get mantra2Desc =>
      'Ambil wick terendah dari seluruh kawasan corak (Mother + Previous) - 10p;';

  @override
  String get mantra3Title =>
      '③ 50% adalah titik tengah tertinggi & terendah —— ';

  @override
  String get mantra3Desc =>
      '(High Tertinggi + Low Terendah) ÷ 2, jangan hanya lihat single mother candle!';

  @override
  String get titleBlueprint =>
      'Struktur Engulfing & Pelan Tindakan Golden Pocket';

  @override
  String get tagMultiK => 'Zon Corak Multi-Candlestick';

  @override
  String get descBlueprint =>
      'Mod Golden Pocket 50%: Lukis fibs pada nilai ekstrem, entri pada pullback memampatkan stop loss dengan tepat';

  @override
  String get blueprintHigh => 'Harga Tertinggi High';

  @override
  String get blueprintLow => 'Harga Terendah Low';
}
