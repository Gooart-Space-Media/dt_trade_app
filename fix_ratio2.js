const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// 1. Change widths: Tip Box -> flex 4 (40%), Chart -> flex 6 (60%)
code = code.replace(
  /Expanded\(\s*flex: 3,\s*child: Container\(\s*padding: const EdgeInsets\.all\(10\),/,
  'Expanded(\n                      flex: 4,\n                      child: Container(\n                        padding: const EdgeInsets.all(10),'
);

// 2. Reduce Chart height: 180 -> 140
code = code.replace(
  /Expanded\(\s*flex: 6,\s*child: Container\(\s*height: 180,/,
  'Expanded(\n                      flex: 6,\n                      child: Container(\n                        height: 140,'
);

// We also need to stretch the Row cross axis so the tip box matches the chart height,
// or we can just let it wrap its content. The user wants the overall height shorter.
// By expanding the tip box to 40%, the text will take fewer lines, naturally reducing its height!
// Chart height reduced to 140.

fs.writeFileSync('lib/main.dart', code);
console.log('Done');
