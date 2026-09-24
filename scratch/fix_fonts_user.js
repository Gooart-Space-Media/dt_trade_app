const fs = require('fs');
let lines = fs.readFileSync('lib/main.dart', 'utf8').split('\n');

const bannerIdx = lines.findIndex(l => l.includes('Widget _buildXMAffiliateBanner'));
const blueprintIdx = lines.findIndex(l => l.includes('Widget _buildBlueprintCard'));

// Banner desc: 13.5 -> 14.5
for(let i=bannerIdx; i<bannerIdx+50; i++) {
    if (lines[i].includes('fontSize: 13.5)')) lines[i] = lines[i].replace('fontSize: 13.5)', 'fontSize: 14.5)');
}

// Blueprint chart text (High, Low, Stop Loss): 10 -> 12.5
for(let i=blueprintIdx; i<blueprintIdx+150; i++) {
    if (lines[i].includes('fontSize: 10,')) lines[i] = lines[i].replace('fontSize: 10,', 'fontSize: 12.5,');
    if (lines[i].includes('fontSize: 10)')) lines[i] = lines[i].replace('fontSize: 10)', 'fontSize: 12.5)');
}

fs.writeFileSync('lib/main.dart', lines.join('\n'));
console.log("Replaced fonts exactly.");
