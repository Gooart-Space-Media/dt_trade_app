const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// 1. Reduce Tip Box width (flex 3), expand chart (flex 6) -> 33% / 66%
code = code.replace(
  /Expanded\(\s*flex: 1,\s*child: Container\(\s*padding: const EdgeInsets\.all\(10\),/,
  'Expanded(\n                      flex: 3,\n                      child: Container(\n                        padding: const EdgeInsets.all(10),'
);
code = code.replace(
  /Expanded\(\s*flex: 1,\s*child: Container\(\s*height: 180,/,
  'Expanded(\n                      flex: 6,\n                      child: Container(\n                        height: 180,'
);

// 2. Monthly Grid: change Column to Row
const oldGrid = `                          child: Column(
                            children: [
                              Text('月', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                              const SizedBox(height: 2),
                              Text(textStr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: textColor)),
                            ],
                          ),`;

const newGrid = `                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('月', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                                Text(textStr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: textColor)),
                              ],
                            ),
                          ),`;

if (code.includes(oldGrid)) {
    code = code.replace(oldGrid, newGrid);
    console.log('Grid replaced');
} else {
    console.log('WARNING: oldGrid not found');
}

fs.writeFileSync('lib/main.dart', code);
console.log('Done');
