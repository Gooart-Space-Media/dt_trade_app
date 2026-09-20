const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8').replace(/\r\n/g, '\n');

// 1. Find LotSizeCalcPage build method
const startClass = code.indexOf('class _LotSizeCalcPageState extends State<LotSizeCalcPage>');
const startBuild = code.indexOf('  Widget build(BuildContext context) {', startClass);
const startReturn = code.indexOf('    return ListView(', startBuild);
const endBuild = code.indexOf('  }\n}', startBuild); // We might need a better way to find the end

// Actually, I can just replace specific strings inside `_LotSizeCalcPageState`.

// 1. Expand the quick pair list
code = code.replace(
  "['EURUSD', 'USDJPY', 'AUDUSD', 'GBPUSD'].map((pair) {",
  "kWatchlistPairs.map((p) => p.symbol).toList().map((pair) {"
);

// 2. Add isDesktop
code = code.replace(
  "    final fightIq = _getFightIqDiagnosis(slPips);\n\n    return ListView(",
  "    final fightIq = _getFightIqDiagnosis(slPips);\n    bool isDesktop = MediaQuery.of(context).size.width > 800;\n\n    final leftChildren = <Widget>["
);

// 3. Find where left children ends and right children begins
code = code.replace(
  "        // 结果卡片\n        Card(",
  "        ];\n\n    final rightChildren = <Widget>[\n        // 结果卡片\n        Card("
);

// 4. Find the end of the ListView and replace it with the LayoutBuilder
// The ListView ends with `      ],\n    );` right before `  }\n}`.
const endOfListViewRegex = /      \],\n    \);\n  \}/;
code = code.replace(endOfListViewRegex, `
    ];

    if (isDesktop) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: leftChildren,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: rightChildren,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return ListView(
        padding: const EdgeInsets.all(10),
        children: [...leftChildren, ...rightChildren],
      );
    }
  }`);

fs.writeFileSync('lib/main.dart', code);
console.log('Fixed Tab 2 layout!');
