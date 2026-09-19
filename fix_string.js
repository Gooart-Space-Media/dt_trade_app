const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');
const searchString = "textStr = '\\';";
const replacement = "textStr = '-';";
code = code.split(searchString).join(replacement);
fs.writeFileSync('lib/main.dart', code);
console.log('Fixed unterminated string');
