const fs = require('fs');

const zh = JSON.parse(fs.readFileSync('lib/l10n/app_zh.arb', 'utf8'));
const en = JSON.parse(fs.readFileSync('lib/l10n/app_en.arb', 'utf8'));
const ms = JSON.parse(fs.readFileSync('lib/l10n/app_ms.arb', 'utf8'));

const keys = {
  radarStatus1: ["🌅 晨间设单窗口", "🌅 Morning Order Window", "🌅 Tetingkap Pesanan Pagi"],
  radarDesc1: ["D1 日线收盘，7:00-8:00 挂单后关闭软件 (Set & Forget)", "D1 Closes, set orders 7:00-8:00 and close app (Set & Forget)", "D1 Tutup, buat pesanan 7:00-8:00 dan tutup aplikasi (Set & Forget)"],
  radarCount1: ["距窗口关闭 {diff}分", "{diff}m until window closes", "{diff}m sehingga tetingkap ditutup"],
  radarStatus2: ["☕ 亚盘静默观察期", "☕ Asian Session (Observation)", "☕ Sesi Asia (Pemerhatian)"],
  radarDesc2: ["让市场来找我。亚盘波动小，绝不因 FOMO 手动追单", "Let the market come. Low volatility, NO FOMO manual entries.", "Biar pasaran datang. Volatiliti rendah, TIADA entri manual FOMO."],
  radarCount2: ["距 15:00 伦敦盘 {h}h{m}m", "London Session in {h}h{m}m", "Sesi London dalam masa {h}h{m}m"],
  radarStatus3: ["🇬🇧 伦敦盘爆发中", "🇬🇧 London Session Breakout", "🇬🇧 Breakout Sesi London"],
  radarDesc3: ["欧洲资金进场，日线挂单迎来首波突破与测试", "European funds enter, first breakout test for daily orders", "Dana Eropah masuk, ujian breakout pertama untuk pesanan harian"],
  radarCount3: ["距 20:30 主战场 {h}h{m}m", "Main NY battle in {h}h{m}m", "Medan NY utama dalam masa {h}h{m}m"],
  radarStatus4: ["🔥 伦纽重叠主战场", "🔥 London & NY Overlap (High Volatility)", "🔥 Pertindihan London & NY (Volatiliti Tinggi)"],
  radarDesc4: ["全天最大波动窗口！20:30-24:00 留意 Trade 1 止盈与推保本", "Biggest volatility window! 20:30-24:00 monitor TP1 and BE moves", "Tetingkap volatiliti terbesar! 20:30-24:00 pantau TP1 dan pergerakan BE"],
  radarCount4: ["距重叠期结束 {h}h{m}m", "{h}h{m}m until overlap ends", "{h}h{m}m sehingga pertindihan tamat"],
  radarStatus5: ["🌙 纽约尾盘与休市", "🌙 NY Close & Market Closed", "🌙 NY Ditutup & Pasaran Ditutup"],
  radarDesc5: ["市场趋缓，保持良好作息，迎接明日晨间开盘", "Market slows. Maintain good routine for tomorrow's open.", "Pasaran perlahan. Kekalkan rutin yang baik untuk pembukaan esok."],
  radarCount5: ["距明日 07:00 晨盘 {h}h{m}m", "Tomorrow's open in {h}h{m}m", "Pembukaan esok dalam masa {h}h{m}m"],
};

for (const [k, v] of Object.entries(keys)) {
  zh[k] = v[0];
  en[k] = v[1];
  ms[k] = v[2];
  
  // Add placeholders for count variables
  if (k.startsWith('radarCount')) {
    if (k === 'radarCount1') {
        zh['@' + k] = { placeholders: { diff: { type: "String" } } };
        en['@' + k] = { placeholders: { diff: { type: "String" } } };
        ms['@' + k] = { placeholders: { diff: { type: "String" } } };
    } else {
        zh['@' + k] = { placeholders: { h: { type: "String" }, m: { type: "String" } } };
        en['@' + k] = { placeholders: { h: { type: "String" }, m: { type: "String" } } };
        ms['@' + k] = { placeholders: { h: { type: "String" }, m: { type: "String" } } };
    }
  }
}

fs.writeFileSync('lib/l10n/app_zh.arb', JSON.stringify(zh, null, 2));
fs.writeFileSync('lib/l10n/app_en.arb', JSON.stringify(en, null, 2));
fs.writeFileSync('lib/l10n/app_ms.arb', JSON.stringify(ms, null, 2));

console.log("ARB files updated.");
