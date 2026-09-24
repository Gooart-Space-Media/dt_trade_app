const fs = require('fs');

const zh = JSON.parse(fs.readFileSync('lib/l10n/app_zh.arb', 'utf8'));
const en = JSON.parse(fs.readFileSync('lib/l10n/app_en.arb', 'utf8'));
const ms = JSON.parse(fs.readFileSync('lib/l10n/app_ms.arb', 'utf8'));

const keys = {
  msgNoSelection: ["选择 2~3 个品种后，系统将自动自审同向汇率共振风险。", "Select 2-3 pairs to automatically audit directional correlation risks.", "Pilih 2-3 pasangan untuk audit automatik risiko korelasi arah."],
  msgShortRisk: ["⚠️ 危险重叠！当前 3 笔交易全部在单向【做空美元 (Short USD)】！属于同质化单向敞口，若非农/CPI数据强劲，将遭遇 6% 连环爆仓回撤！建议拆解或换交叉盘。", "⚠️ DANGER OVERLAP! All 3 trades are heavily shorting USD. This is a massive one-sided exposure. Strong NFP/CPI will trigger a 6% chain-reaction drawdown! Swap one out.", "⚠️ PERTINDIHAN BAHAYA! Ketiga-tiga dagangan menjual USD. Pendedahan sehala ini sangat besar. NFP/CPI kukuh akan cetuskan drawdown rantaian 6%! Tukar pasangan."],
  msgLongRisk: ["⚠️ 危险重叠！当前 3 笔交易全部在单向【做多美元 (Long USD)】！一旦美元反转将全部止损，建议降低同质化敞口。", "⚠️ DANGER OVERLAP! All 3 trades are heavily long on USD. A reversal will wipe out all stop losses. Reduce exposure.", "⚠️ PERTINDIHAN BAHAYA! Ketiga-tiga dagangan membeli USD. Pembalikan akan menyapu bersih semua stop loss. Kurangkan pendedahan."],
  msgSafe: ["✅ 晨间 10 秒自审通过：3 笔交易不存在单向同质化敞口，结构独立，可安全同时建仓（总日风险控制在 6% 内）！", "✅ 10s Morning Audit Passed: The 3 trades are independent with no heavy correlation. Safe to execute simultaneously (Risk within 6%).", "✅ Lulus Audit 10s Pagi: 3 dagangan bebas tanpa korelasi berat. Selamat dilaksanakan serentak (Risiko bawah 6%)."],
  
  avoidTitle: ["🚫 坚决规避的毒药品种 (The Avoid List)", "🚫 Toxic Pairs (The Avoid List)", "🚫 Pasangan Toksik (Senarai Elak)"],
  avoidDesc: ["以下四类品种在实战中看似有机会，实则暗藏点差与政策陷阱，强烈建议拉黑跳过：", "These pairs might look tempting but harbor massive spread/policy traps. Blacklist them:", "Pasangan ini nampak menarik tetapi mempunyai perangkap spread/polisi. Senaraihitamkannya:"],
  avoidCard1Title: ["1. 联系汇率挂钩类 (画直线)", "1. Pegged Currencies (Flatlines)", "1. Matawang Diikat (Garis Lurus)"],
  avoidCard1Reason: ["受央行强行挂钩制度约束，K线基本为水平直线，日波动甚至小于点差，毫无交易价值。", "Pegged by central banks, charts look like flatlines. Daily volatility is smaller than the spread. Zero trade value.", "Diikat bank pusat, graf mendatar. Volatiliti harian lebih kecil dari spread. Tiada nilai dagangan."],
  avoidCard2Title: ["2. 高息吃人断崖类 (点差过宽)", "2. High-Yield Exotics (Widened Spread)", "2. Eksotik Hasil Tinggi (Spread Luas)"],
  avoidCard2Reason: ["新兴市场货币恶性贬值，看似单边躺赚，但隔夜利息极其昂贵且极易发生政策跳空，利润全被磨光。", "Emerging markets hyper-devaluation. Huge overnight swap fees and massive policy gaps will destroy your profits.", "Penurunan nilai pasaran membangun. Yuran swap semalaman besar dan jurang polisi akan menghancurkan keuntungan."],
  avoidCard3Title: ["3. 极低流动性类 (严重滑点)", "3. Ultra-Low Liquidity (Severe Slippage)", "3. Kecairan Sangat Rendah (Slippage Teruk)"],
  avoidCard3Reason: ["挂单成交极不活跃，止损往往无法在预设点位成交，遭遇极端滑点击穿账户。", "Extremely inactive. Stop losses won't trigger at set prices, leading to devastating slippage.", "Sangat tidak aktif. Stop loss tidak akan diaktifkan pada harga ditetapkan, membawa slippage dahsyat."],
  avoidCard4Title: ["4. 恶劣交叉盘规避", "4. Toxic Cross Pairs", "4. Pasangan Silang Toksik"],
  avoidCard4Reason: ["虽然日均波幅极大，但点差同样极其昂贵，盈利空间往往刚好抵消高额交易成本。", "High daily range, but extremely expensive spreads. Profit margins just offset trading costs.", "Julat harian tinggi, tapi spread mahal. Margin untung hanya mengimbangi kos dagangan."],

  pageOverlapTitle: ["🛡️ 多单并行防呆与自审", "🛡️ Overlap & Exposure Checker", "🛡️ Semakan Pertindihan & Pendedahan"],
  btnAtlas: ["16品种图鉴", "16-Pair Atlas", "Atlas 16-Pasangan"],
  btnAvoid: ["毒药黑名单", "Toxic Blacklist", "Senarai Hitam Toksik"],
  txtStandard: ["规范选项：⭐ 7大核心货币对 (极低点差) + 🔹 9大次要交叉盘", "Standard: ⭐ 7 Core Pairs (Low Spread) + 🔹 9 Minors", "Standard: ⭐ 7 Pasangan Teras (Spread Rendah) + 🔹 9 Pasangan Kecil"],
  btnDetail: ["详解 >", "Details >", "Perincian >"],
  trade1: ["交易 1 (首选主线)", "Trade 1 (Primary)", "Dagangan 1 (Utama)"],
  trade2: ["交易 2 (独立隔离)", "Trade 2 (Isolated)", "Dagangan 2 (Terasing)"],
  trade3: ["交易 3 (独立隔离)", "Trade 3 (Isolated)", "Dagangan 3 (Terasing)"],
  dirLong: ["多", "Long", "Long"],
  dirShort: ["空", "Short", "Short"],
  radarRiskTitle: ["晨间自审预警：同质化过度曝险", "Morning Alert: Heavy Correlation Risk", "Amaran Pagi: Risiko Korelasi Berat"],
  radarSafeTitle: ["晨间 10 秒风控自审雷达", "10s Morning Risk Radar", "Radar Risiko 10s Pagi"],
  chkTitle: ["飞行员起飞前：最后 10 秒防呆自检", "Pre-Flight: Final 10s Dummy Check", "Prapenerbangan: Semakan Akhir 10s"],
  chkClear: ["准许执行 (CLEAR TO ENGAGE)", "CLEAR TO ENGAGE", "DIBENARKAN BERTINDAK (CLEAR)"],
  chk1: ["日内无重大数据发布 (如非农、CPI等核弹级数据)", "No major news today (e.g. NFP, CPI nuclear data)", "Tiada berita besar hari ini (cth. NFP, data nuklear CPI)"],
  chk2: ["情绪绝对平稳，未受上笔交易 (大赚/大亏) 的 FOMO 影响", "Emotionally stable, no FOMO from previous trade (big win/loss)", "Emosi stabil, tiada FOMO dari dagangan sebelumnya (untung/rugi besar)"],
  chk3: ["严格遵循 DT 双轨制，已预设 Trade 1 的保本与止盈", "Strictly following DT Dual Track, Trade 1 BE & TP set", "Patuhi Sistem DT, BE & TP Dagangan 1 telah ditetapkan"],
  chk4: ["单笔总风险严格控制在 2% 内，绝不抱有重仓扛单侥幸", "Total risk strictly within 2%, no heavy lot gambling", "Jumlah risiko di bawah 2%, tiada perjudian lot berat"]
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
