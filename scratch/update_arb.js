const fs = require('fs');

const zh = JSON.parse(fs.readFileSync('lib/l10n/app_zh.arb', 'utf8'));
const en = JSON.parse(fs.readFileSync('lib/l10n/app_en.arb', 'utf8'));
const ms = JSON.parse(fs.readFileSync('lib/l10n/app_ms.arb', 'utf8'));

const keys = {
  msgOpeningXM: ["正在前往 XM 官方认证开户通道...", "Opening XM Official Account Registration...", "Membuka Saluran Pendaftaran Akaun Rasmi XM..."],
  titleXMBanner: ["XM 官方认证开户通道 (专属活动)", "XM Official Account Registration (Exclusive)", "Saluran Pendaftaran Akaun Rasmi XM (Eksklusif)"],
  descXMBanner: ["点击立即注册，尊享极低点差与入金赠金", "Click to register now, enjoy ultra-low spreads and deposit bonuses", "Klik untuk daftar sekarang, nikmati spread sangat rendah dan bonus deposit"],
  titleMantra: ["吞没战法实战三句真诀 (必须焊死在脑海)：", "Three Mantras of Engulfing Strategy (Memorize this):", "Tiga Mantra Strategi Engulfing (Wajib Ingat):"],
  mantra1Title: ["① 做多确认看实体吞没 —— ", "① Long confirmation needs body engulfing —— ", "① Pengesahan Long perlukan engulfing body —— "],
  mantra1Desc: ["形态真假看 Body，后一根实体必须彻底吃掉前一根；", "Judge the pattern by Body, the latter body must completely swallow the former;", "Nilai corak dari Body, body kedua mesti telan body pertama sepenuhnya;"],
  mantra2Title: ["② 止损躲在全区最低影线底 —— ", "② Stop loss hides below the lowest wick —— ", "② Stop loss sembunyi di bawah wick terendah —— "],
  mantra2Desc: ["取整片形态区域 (母烛 + 前置烛) 最低的下影线 (Lowest Wick) - 10p；", "Take the lowest wick of the entire pattern area (Mother + Previous) - 10p;", "Ambil wick terendah dari seluruh kawasan corak (Mother + Previous) - 10p;"],
  mantra3Title: ["③ 50% 取自全区极高与极低的中点 —— ", "③ 50% is from the midpoint of highest and lowest —— ", "③ 50% adalah titik tengah tertinggi & terendah —— "],
  mantra3Desc: ["(全区最高 High + 全区最低 Low) ÷ 2，绝不仅看单根母烛！", "(Highest High + Lowest Low) ÷ 2, never just look at the single mother candle!", "(High Tertinggi + Low Terendah) ÷ 2, jangan hanya lihat single mother candle!"],
  titleBlueprint: ["吞没结构与黄金口袋解剖蓝图", "Engulfing Structure & Golden Pocket Blueprint", "Struktur Engulfing & Pelan Tindakan Golden Pocket"],
  tagMultiK: ["多重 K 线形态区", "Multi-Candlestick Pattern Zone", "Zon Corak Multi-Candlestick"],
  descBlueprint: ["黄金口袋 50% 模式：全区极值画网，回踩入场将止损精准压缩", "Golden Pocket 50% Mode: Draw fibs on extremes, entry on pullback precisely compresses stop loss", "Mod Golden Pocket 50%: Lukis fibs pada nilai ekstrem, entri pada pullback memampatkan stop loss dengan tepat"],
  blueprintHigh: ["全区最高价 High", "Highest Price High", "Harga Tertinggi High"],
  blueprintLow: ["全区最低价 Low", "Lowest Price Low", "Harga Terendah Low"],
};

for (const [k, v] of Object.entries(keys)) {
  zh[k] = v[0];
  en[k] = v[1];
  ms[k] = v[2];
}

fs.writeFileSync('lib/l10n/app_zh.arb', JSON.stringify(zh, null, 2));
fs.writeFileSync('lib/l10n/app_en.arb', JSON.stringify(en, null, 2));
fs.writeFileSync('lib/l10n/app_ms.arb', JSON.stringify(ms, null, 2));

console.log("ARB files updated.");
