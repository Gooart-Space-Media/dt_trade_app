const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf8');
const lines = code.split('\n');

// 1405
if (lines[1405].includes('const Expanded(')) {
    lines[1405] = lines[1405].replace('const Expanded(', 'Expanded(');
}

// 1519
if (lines[1519].includes('const Expanded(')) {
    lines[1519] = lines[1519].replace('const Expanded(', 'Expanded(');
}

fs.writeFileSync('lib/main.dart', lines.join('\n'));
console.log("Fixed lines directly by index.");
