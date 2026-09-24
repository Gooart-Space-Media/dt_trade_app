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

  @override
  String get radarStatus1 => '🌅 Tetingkap Pesanan Pagi';

  @override
  String get radarDesc1 =>
      'D1 Tutup, buat pesanan 7:00-8:00 dan tutup aplikasi (Set & Forget)';

  @override
  String radarCount1(String diff) {
    return '${diff}m sehingga tetingkap ditutup';
  }

  @override
  String get radarStatus2 => '☕ Sesi Asia (Pemerhatian)';

  @override
  String get radarDesc2 =>
      'Biar pasaran datang. Volatiliti rendah, TIADA entri manual FOMO.';

  @override
  String radarCount2(String h, String m) {
    return 'Sesi London dalam masa ${h}h${m}m';
  }

  @override
  String get radarStatus3 => '🇬🇧 Breakout Sesi London';

  @override
  String get radarDesc3 =>
      'Dana Eropah masuk, ujian breakout pertama untuk pesanan harian';

  @override
  String radarCount3(String h, String m) {
    return 'Medan NY utama dalam masa ${h}h${m}m';
  }

  @override
  String get radarStatus4 => '🔥 Pertindihan London & NY (Volatiliti Tinggi)';

  @override
  String get radarDesc4 =>
      'Tetingkap volatiliti terbesar! 20:30-24:00 pantau TP1 dan pergerakan BE';

  @override
  String radarCount4(String h, String m) {
    return '${h}h${m}m sehingga pertindihan tamat';
  }

  @override
  String get radarStatus5 => '🌙 NY Ditutup & Pasaran Ditutup';

  @override
  String get radarDesc5 =>
      'Pasaran perlahan. Kekalkan rutin yang baik untuk pembukaan esok.';

  @override
  String radarCount5(String h, String m) {
    return 'Pembukaan esok dalam masa ${h}h${m}m';
  }

  @override
  String get msgNoSelection =>
      'Pilih 2-3 pasangan untuk audit automatik risiko korelasi arah.';

  @override
  String get msgShortRisk =>
      '⚠️ PERTINDIHAN BAHAYA! Ketiga-tiga dagangan menjual USD. Pendedahan sehala ini sangat besar. NFP/CPI kukuh akan cetuskan drawdown rantaian 6%! Tukar pasangan.';

  @override
  String get msgLongRisk =>
      '⚠️ PERTINDIHAN BAHAYA! Ketiga-tiga dagangan membeli USD. Pembalikan akan menyapu bersih semua stop loss. Kurangkan pendedahan.';

  @override
  String get msgSafe =>
      '✅ Lulus Audit 10s Pagi: 3 dagangan bebas tanpa korelasi berat. Selamat dilaksanakan serentak (Risiko bawah 6%).';

  @override
  String get avoidTitle => '🚫 Pasangan Toksik (Senarai Elak)';

  @override
  String get avoidDesc =>
      'Pasangan ini nampak menarik tetapi mempunyai perangkap spread/polisi. Senaraihitamkannya:';

  @override
  String get avoidCard1Title => '1. Matawang Diikat (Garis Lurus)';

  @override
  String get avoidCard1Reason =>
      'Diikat bank pusat, graf mendatar. Volatiliti harian lebih kecil dari spread. Tiada nilai dagangan.';

  @override
  String get avoidCard2Title => '2. Eksotik Hasil Tinggi (Spread Luas)';

  @override
  String get avoidCard2Reason =>
      'Penurunan nilai pasaran membangun. Yuran swap semalaman besar dan jurang polisi akan menghancurkan keuntungan.';

  @override
  String get avoidCard3Title => '3. Kecairan Sangat Rendah (Slippage Teruk)';

  @override
  String get avoidCard3Reason =>
      'Sangat tidak aktif. Stop loss tidak akan diaktifkan pada harga ditetapkan, membawa slippage dahsyat.';

  @override
  String get avoidCard4Title => '4. Pasangan Silang Toksik';

  @override
  String get avoidCard4Reason =>
      'Julat harian tinggi, tapi spread mahal. Margin untung hanya mengimbangi kos dagangan.';

  @override
  String get pageOverlapTitle => '🛡️ Semakan Pertindihan & Pendedahan';

  @override
  String get btnAtlas => 'Atlas 16-Pasangan';

  @override
  String get btnAvoid => 'Senarai Hitam Toksik';

  @override
  String get txtStandard =>
      'Standard: ⭐ 7 Pasangan Teras (Spread Rendah) + 🔹 9 Pasangan Kecil';

  @override
  String get btnDetail => 'Perincian >';

  @override
  String get trade1 => 'Dagangan 1 (Utama)';

  @override
  String get trade2 => 'Dagangan 2 (Terasing)';

  @override
  String get trade3 => 'Dagangan 3 (Terasing)';

  @override
  String get dirLong => 'Long';

  @override
  String get dirShort => 'Short';

  @override
  String get radarRiskTitle => 'Amaran Pagi: Risiko Korelasi Berat';

  @override
  String get radarSafeTitle => 'Radar Risiko 10s Pagi';

  @override
  String get chkTitle => 'Prapenerbangan: Semakan Akhir 10s';

  @override
  String get chkClear => 'DIBENARKAN BERTINDAK (CLEAR)';

  @override
  String get chk1 => 'Tiada berita besar hari ini (cth. NFP, data nuklear CPI)';

  @override
  String get chk2 =>
      'Emosi stabil, tiada FOMO dari dagangan sebelumnya (untung/rugi besar)';

  @override
  String get chk3 => 'Patuhi Sistem DT, BE & TP Dagangan 1 telah ditetapkan';

  @override
  String get chk4 => 'Jumlah risiko di bawah 2%, tiada perjudian lot berat';

  @override
  String get calcTableTitle =>
      '🧮 Jadual Lot Maksimum Dual Track \$500 - \$3,200';

  @override
  String get calcTableDesc =>
      'Ketik mana-mana baris untuk muat konfigurasi modal (Jumlah lot sentiasa genap untuk perpisahan 2 x 1%):';

  @override
  String calcTableRedLine(String risk) {
    return 'Garisan Merah 2%: \$$risk';
  }

  @override
  String get calcTableNotAvailable => '🚫 T/A (Melebihi Risiko)';

  @override
  String get calcAccountStd => '🏢 XM Standard/Ultra Low (1 Lot=100k)';

  @override
  String get calcAccountMicro => '🔬 XM Micro (1 Lot=1k)';

  @override
  String get calcPointLink => 'Pautan Tier Nilai Pip (Auto ATR Stop Loss): ';

  @override
  String get calcCurrentPair => 'Semasa: ';

  @override
  String get calcBalTitle => 'Baki Akaun';

  @override
  String get calcRateTitle => 'Kadar Pertukaran (USD/MYR)';

  @override
  String get calcRiskTitle => 'Jumlah Risiko per Dagangan (%)';

  @override
  String get calcSlTitle => 'Stop Loss (Pips)';

  @override
  String get calcResultTitle => '📊 Pelan Pelaksanaan Dual Track';

  @override
  String get calcResultMaxLoss => 'Maksimum Kerugian Dibenarkan: ';

  @override
  String get calcResultTotalLots => 'Jumlah Lot Pelaksanaan';

  @override
  String get calcResultInsufficient =>
      '⚠️ Baki tidak mencukupi untuk risiko 2%, jumlah lot bawah 0.02';

  @override
  String get calcResultTrade1 => 'Trade 1: 1% Risiko (Agresif)';

  @override
  String get calcResultTrade2 => 'Trade 2: 1% Risiko (Konservatif)';

  @override
  String get iqTitle => '🧠 Fight IQ: Diagnosis Kesihatan Lilin';

  @override
  String get iqGold1Title => '🟡 Lilin Kecil Bunyi Emas (< 150 Pips / < \$15)';

  @override
  String get iqGold1Desc =>
      'Institusi tidak aktif, kebanyakannya bunyi mendatar. Risiko tinggi fakeout. Pesanan breakout pending tidak digalakkan.';

  @override
  String get iqGold2Title =>
      '🟢 Zon Selesa Standard Emas (150 ~ 250 Pips / \$15~\$25)';

  @override
  String get iqGold2Desc =>
      'Engulfing harian standard sempurna! Momentum tinggi, kaedah Breakout dan Pullback 50% berfungsi dengan sempurna!';

  @override
  String get iqGold3Title => '🔵 Lilin Besar Emas (250 ~ 350 Pips / \$25~\$35)';

  @override
  String get iqGold3Desc =>
      'Stop loss breakout terlalu besar. JANGAN buat pesanan breakout pending! Mesti guna entri pullback 50% Fib untuk separuh risiko!';

  @override
  String get iqGold4Title =>
      '🛑 Lilin Keletihan Ekstrem Emas (> 350 Pips / > \$35)';

  @override
  String get iqGold4Desc =>
      'Lonjakan emosi terlalu panas! Risiko tinggi pembalikan dalam atau stop out esok. Sistem amat mengesyorkan abaikan!';

  @override
  String get iqFx1Title => '🟡 Lilin Pendek (< 50 Pips)';

  @override
  String get iqFx1Desc =>
      'Volatiliti harian kecil. Tahap pullback 50% terlalu dekat dan berisiko dihentikan oleh bunyi. Pesanan breakout pending sahaja.';

  @override
  String get iqFx2Title => '🟢 Volatiliti FX Standard (50 ~ 80 Pips)';

  @override
  String get iqFx2Desc =>
      'Zon selesa sempurna! Volatiliti mencukupi dan arah jelas. Kaedah Breakout dan Pullback 50% berfungsi dengan sempurna!';

  @override
  String get iqFx3Title => '🔵 Lilin Besar (80 ~ 100 Pips)';

  @override
  String get iqFx3Desc =>
      'Stop loss breakout terlalu besar. Amat mengesyorkan 【Kaedah Pullback 50%】 untuk mampatkan risiko entri ke 40-50 Pips!';

  @override
  String get iqFx4Title => '🛑 Lilin Keletihan Ekstrem (> 100 Pips)';

  @override
  String get iqFx4Desc =>
      'Lonjakan keletihan! Nisbah risiko-ganjaran teruk. Sistem amat mengesyorkan abaikan dagangan sepenuhnya!';

  @override
  String get btnQuickSelect => 'Pilih Cepat';

  @override
  String get btnLiveRate => 'Kadar Langsung';
}
