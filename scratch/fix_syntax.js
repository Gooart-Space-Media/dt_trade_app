const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');
code = code.replace(/\\\$\{/g, '\\$\\${');
fs.writeFileSync('lib/main.dart', code);
console.log('Fixed syntax errors!');
