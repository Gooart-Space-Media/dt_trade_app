const fs = require('fs');
const code = fs.readFileSync('lib/main.dart', 'utf8');
const regex = /'([^'\\]*[\u4e00-\u9fa5]+[^'\\]*)'|"([^"\\]*[\u4e00-\u9fa5]+[^"\\]*)"/g;
const matches = new Set();
let m;
while ((m = regex.exec(code)) !== null) {
  matches.add(m[1] || m[2]);
}
console.log('Total unique Chinese strings:', matches.size);
const arr = Array.from(matches);
fs.writeFileSync('scratch/zh_strings.json', JSON.stringify(arr, null, 2));
