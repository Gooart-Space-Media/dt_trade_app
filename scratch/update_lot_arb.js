const fs = require('fs');

const zh = JSON.parse(fs.readFileSync('lib/l10n/app_zh.arb', 'utf8'));
const en = JSON.parse(fs.readFileSync('lib/l10n/app_en.arb', 'utf8'));
const ms = JSON.parse(fs.readFileSync('lib/l10n/app_ms.arb', 'utf8'));

const keys = {
  calcTableTitle: ["🧮 500 - 3,200 美元双轨最大手数对照表", "🧮 $500 - $3,200 Dual Track Max Lot Table", "🧮 Jadual Lot Maksimum Dual Track $500 - $3,200"],
  calcTableDesc: ["点击任意行可直接快速载入该资金配置 (总手数恒为偶数，保证 2 x 1% 完美平分)：", "Tap any row to quickly load the capital config (Total lots always even for perfect 2 x 1% split):", "Ketik mana-mana baris untuk muat konfigurasi modal (Jumlah lot sentiasa genap untuk perpisahan 2 x 1%):"],
  calcTableRedLine: ["2% 红线: ${risk}", "2% Redline: ${risk}", "Garisan Merah 2%: ${risk}"],
  calcTableNotAvailable: ["🚫 不可用 (超标)", "🚫 N/A (Exceeds Risk)", "🚫 T/A (Melebihi Risiko)"],
  
  calcAccountStd: ["🏢 XM 标准/Ultra Low (1手=100k)", "🏢 XM Standard/Ultra Low (1 Lot=100k)", "🏢 XM Standard/Ultra Low (1 Lot=100k)"],
  calcAccountMicro: ["🔬 XM Micro 微型 (1手=1k)", "🔬 XM Micro (1 Lot=1k)", "🔬 XM Micro (1 Lot=1k)"],
  
  calcPointLink: ["点值梯队联动 (自动载入 ATR 止损基准): ", "Pip Value Tier Link (Auto ATR Stop Loss): ", "Pautan Tier Nilai Pip (Auto ATR Stop Loss): "],
  calcCurrentPair: ["当前: ", "Current: ", "Semasa: "],
  
  calcBalTitle: ["账户总资金 (Balance)", "Account Balance", "Baki Akaun"],
  calcRateTitle: ["当前汇率 (USD/MYR)", "Exchange Rate (USD/MYR)", "Kadar Pertukaran (USD/MYR)"],
  calcRiskTitle: ["单笔总风险 (Risk %)", "Total Risk per Trade (%)", "Jumlah Risiko per Dagangan (%)"],
  calcSlTitle: ["止损点数 (Stop Loss Pips)", "Stop Loss (Pips)", "Stop Loss (Pips)"],
  
  calcResultTitle: ["📊 双轨分仓执行计划", "📊 Dual Track Execution Plan", "📊 Pelan Pelaksanaan Dual Track"],
  calcResultMaxLoss: ["单笔最大允许亏损: ", "Max Allowed Loss per Trade: ", "Maksimum Kerugian Dibenarkan: "],
  calcResultTotalLots: ["总开仓手数 (Total Lots)", "Total Execution Lots", "Jumlah Lot Pelaksanaan"],
  calcResultInsufficient: ["⚠️ 资金不足以执行 2% 风险标准，总手数低于 0.02 手", "⚠️ Insufficient balance for 2% risk, total lots under 0.02", "⚠️ Baki tidak mencukupi untuk risiko 2%, jumlah lot bawah 0.02"],
  calcResultTrade1: ["Trade 1: 1% 风险首战 (激进)", "Trade 1: 1% Risk (Aggressive)", "Trade 1: 1% Risiko (Agresif)"],
  calcResultTrade2: ["Trade 2: 1% 风险次战 (保守)", "Trade 2: 1% Risk (Conservative)", "Trade 2: 1% Risiko (Konservatif)"],
  
  // Fight IQ
  iqTitle: ["🧠 Fight IQ: 当前品种蜡烛健康诊断", "🧠 Fight IQ: Candle Health Diagnosis", "🧠 Fight IQ: Diagnosis Kesihatan Lilin"],
  
  iqGold1Title: ["🟡 黄金噪音小蜡烛 (< 150 Pips / < $15)", "🟡 Gold Noise Small Candle (< 150 Pips / < $15)", "🟡 Lilin Kecil Bunyi Emas (< 150 Pips / < $15)"],
  iqGold1Desc: ["机构未发力，多为震荡横盘噪音，极易假突破，不建议做突破挂单。", "Institutions inactive, mostly sideways noise. High risk of fakeouts. Pending breakout orders not recommended.", "Institusi tidak aktif, kebanyakannya bunyi mendatar. Risiko tinggi fakeout. Pesanan breakout pending tidak digalakkan."],
  iqGold2Title: ["🟢 黄金标准舒适区 (150 ~ 250 Pips / $15~$25)", "🟢 Gold Standard Comfort Zone (150 ~ 250 Pips / $15~$25)", "🟢 Zon Selesa Standard Emas (150 ~ 250 Pips / $15~$25)"],
  iqGold2Desc: ["完美标准日线吞没！动能充沛，突破法与 50% 回撤法均可完美执行！", "Perfect standard daily engulfing! High momentum, both Breakout and 50% Pullback methods work perfectly!", "Engulfing harian standard sempurna! Momentum tinggi, kaedah Breakout dan Pullback 50% berfungsi dengan sempurna!"],
  iqGold3Title: ["🔵 黄金偏大蜡烛 (250 ~ 350 Pips / $25~$35)", "🔵 Gold Large Candle (250 ~ 350 Pips / $25~$35)", "🔵 Lilin Besar Emas (250 ~ 350 Pips / $25~$35)"],
  iqGold3Desc: ["突破止损偏大，严禁追突破挂单！必须用 Fib 50% 回踩折半入场！", "Breakout stop loss too large. NO pending breakout orders! Must use Fib 50% pullback entry to halve the risk!", "Stop loss breakout terlalu besar. JANGAN buat pesanan breakout pending! Mesti guna entri pullback 50% Fib untuk separuh risiko!"],
  iqGold4Title: ["🛑 黄金极端力竭蜡烛 (> 350 Pips / > $35)", "🛑 Gold Extreme Exhaustion Candle (> 350 Pips / > $35)", "🛑 Lilin Keletihan Ekstrem Emas (> 350 Pips / > $35)"],
  iqGold4Desc: ["情绪过热暴冲！次日极易深度反抽或扫损，系统强烈建议直接放弃！", "Overheated emotion surge! High risk of deep reversal or stop out next day. System strongly recommends skipping!", "Lonjakan emosi terlalu panas! Risiko tinggi pembalikan dalam atau stop out esok. Sistem amat mengesyorkan abaikan!"],
  
  iqFx1Title: ["🟡 比较短的蜡烛 (< 50 Pips)", "🟡 Short Candle (< 50 Pips)", "🟡 Lilin Pendek (< 50 Pips)"],
  iqFx1Desc: ["日内波动偏小。此时 50% 回调位太近易被噪音扫损，建议仅采用【突破法挂单】。", "Small daily volatility. 50% pullback level is too close and risks being stopped out by noise. Breakout pending orders only.", "Volatiliti harian kecil. Tahap pullback 50% terlalu dekat dan berisiko dihentikan oleh bunyi. Pesanan breakout pending sahaja."],
  iqFx2Title: ["🟢 标准外汇波动 (50 ~ 80 Pips)", "🟢 Standard FX Volatility (50 ~ 80 Pips)", "🟢 Volatiliti FX Standard (50 ~ 80 Pips)"],
  iqFx2Desc: ["完美舒适区！波动充足且方向明确，突破法与 50% 回调法均可完美执行！", "Perfect comfort zone! Sufficient volatility and clear direction. Both Breakout and 50% Pullback methods work perfectly!", "Zon selesa sempurna! Volatiliti mencukupi dan arah jelas. Kaedah Breakout dan Pullback 50% berfungsi dengan sempurna!"],
  iqFx3Title: ["🔵 偏大蜡烛 (80 ~ 100 Pips)", "🔵 Large Candle (80 ~ 100 Pips)", "🔵 Lilin Besar (80 ~ 100 Pips)"],
  iqFx3Desc: ["突破止损偏大。强烈建议使用【50% 回调法】，将入场风险折半压缩至 40~50 Pips！", "Breakout stop loss too large. Strongly recommend 【50% Pullback method】 to compress entry risk to 40-50 Pips!", "Stop loss breakout terlalu besar. Amat mengesyorkan 【Kaedah Pullback 50%】 untuk mampatkan risiko entri ke 40-50 Pips!"],
  iqFx4Title: ["🛑 极端力竭蜡烛 (> 100 Pips)", "🛑 Extreme Exhaustion Candle (> 100 Pips)", "🛑 Lilin Keletihan Ekstrem (> 100 Pips)"],
  iqFx4Desc: ["情绪力竭暴冲！盈亏比极差，系统强烈建议直接放弃交易，坚决不介入！", "Exhaustion surge! Terrible risk-reward ratio. System strongly recommends skipping the trade entirely!", "Lonjakan keletihan! Nisbah risiko-ganjaran teruk. Sistem amat mengesyorkan abaikan dagangan sepenuhnya!"],
  
  btnQuickSelect: ["快速选择", "Quick Select", "Pilih Cepat"],
  btnLiveRate: ["获取实时汇率", "Live Rate", "Kadar Langsung"]
};

for (const [k, v] of Object.entries(keys)) {
  zh[k] = v[0];
  en[k] = v[1];
  ms[k] = v[2];
  
  if (k === 'calcTableRedLine') {
    zh['@' + k] = { placeholders: { risk: { type: "String" } } };
    en['@' + k] = { placeholders: { risk: { type: "String" } } };
    ms['@' + k] = { placeholders: { risk: { type: "String" } } };
  }
}

fs.writeFileSync('lib/l10n/app_zh.arb', JSON.stringify(zh, null, 2));
fs.writeFileSync('lib/l10n/app_en.arb', JSON.stringify(en, null, 2));
fs.writeFileSync('lib/l10n/app_ms.arb', JSON.stringify(ms, null, 2));

console.log("ARB files updated.");
