const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf8');

const replacements = [
  ["'正在前往 XM 官方认证开户通道...'", "AppLocalizations.of(context)!.msgOpeningXM"],
  ["'XM 官方认证开户通道 (专属活动)'", "AppLocalizations.of(context)!.titleXMBanner"],
  ["'点击立即注册，尊享极低点差与入金赠金'", "AppLocalizations.of(context)!.descXMBanner"],
  ["'吞没战法实战三句真诀 (必须焊死在脑海)：'", "AppLocalizations.of(context)!.titleMantra"],
  ["'① 做多确认看实体吞没 —— '", "AppLocalizations.of(context)!.mantra1Title"],
  ["'形态真假看 Body，后一根实体必须彻底吃掉前一根；'", "AppLocalizations.of(context)!.mantra1Desc"],
  ["'② 止损躲在全区最低影线底 —— '", "AppLocalizations.of(context)!.mantra2Title"],
  ["'取整片形态区域 (母烛 + 前置烛) 最低的下影线 (Lowest Wick) - 10p；'", "AppLocalizations.of(context)!.mantra2Desc"],
  ["'③ 50% 取自全区极高与极低的中点 —— '", "AppLocalizations.of(context)!.mantra3Title"],
  ["'(全区最高 High + 全区最低 Low) ÷ 2，绝不仅看单根母烛！'", "AppLocalizations.of(context)!.mantra3Desc"],
  ["'吞没结构与黄金口袋解剖蓝图'", "AppLocalizations.of(context)!.titleBlueprint"],
  ["'多重 K 线形态区'", "AppLocalizations.of(context)!.tagMultiK"],
  ["'黄金口袋 50% 模式：全区极值画网，回踩入场将止损精准压缩'", "AppLocalizations.of(context)!.descBlueprint"],
  ["'全区最高价 High'", "AppLocalizations.of(context)!.blueprintHigh"],
  ["'全区最低价 Low'", "AppLocalizations.of(context)!.blueprintLow"]
];

for (const [target, replacement] of replacements) {
  code = code.replace(target, replacement);
}

fs.writeFileSync('lib/main.dart', code);
console.log("Replaced strings in main.dart");
