const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// The code currently has:
// Expanded(
//   flex: 2,
//   child: Container(
//     padding: const EdgeInsets.all(10),

code = code.replace(
  /Expanded\(\s*flex: \d+,\s*child: Container\(\s*padding: const EdgeInsets\.all\(10\),/,
  'Expanded(\n                      flex: 4,\n                      child: Container(\n                        padding: const EdgeInsets.all(10),'
);

// Chart height:
// Expanded(
//   flex: 6,
//   child: Container(
//     height: 140, // or 180

code = code.replace(
  /Expanded\(\s*flex: \d+,\s*child: Container\(\s*height: \d+,/,
  'Expanded(\n                      flex: 6,\n                      child: Container(\n                        height: 180,'
);

fs.writeFileSync('lib/main.dart', code);
console.log('Done');
