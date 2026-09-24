const fs = require('fs');
const lines = fs.readFileSync('lib/main.dart', 'utf8').split('\n');

const bannerIdx = lines.findIndex(l => l.includes('Widget _buildXMAffiliateBanner'));
const mantraIdx = lines.findIndex(l => l.includes('Widget _buildMantraLine'));
const mantraCardIdx = lines.findIndex(l => l.includes('Widget _buildMantraCard'));
const blueprintIdx = lines.findIndex(l => l.includes('Widget _buildBlueprintCard'));

// Banner title: 13 -> 15.5
for(let i=bannerIdx; i<bannerIdx+50; i++) {
    if (lines[i].includes('fontSize: 13,')) lines[i] = lines[i].replace('fontSize: 13,', 'fontSize: 15.5,');
    if (lines[i].includes('fontSize: 12)')) lines[i] = lines[i].replace('fontSize: 12)', 'fontSize: 13.5)');
}

// MantraCard Title: 13 -> 15.5
for(let i=mantraCardIdx; i<mantraCardIdx+50; i++) {
    if (lines[i].includes('fontSize: 13,')) lines[i] = lines[i].replace('fontSize: 13,', 'fontSize: 15.5,');
}

// Mantra Line: 11.5 -> 14
for(let i=mantraIdx; i<mantraIdx+20; i++) {
    if (lines[i].includes('fontSize: 11.5,')) lines[i] = lines[i].replace('fontSize: 11.5,', 'fontSize: 14,');
    if (lines[i].includes('height: 1.4,')) lines[i] = lines[i].replace('height: 1.4,', 'height: 1.5,');
}

// Blueprint Title: 15 -> 17
// Blueprint Tag: 10 -> 12
// Blueprint Desc: 11 -> 13.5
for(let i=blueprintIdx; i<blueprintIdx+60; i++) {
    if (lines[i].includes('fontSize: 15,')) lines[i] = lines[i].replace('fontSize: 15,', 'fontSize: 17,');
    if (lines[i].includes('fontSize: 10,')) lines[i] = lines[i].replace('fontSize: 10,', 'fontSize: 12,');
    if (lines[i].includes('fontSize: 11,')) lines[i] = lines[i].replace('fontSize: 11,', 'fontSize: 13.5,');
}

fs.writeFileSync('lib/main.dart', lines.join('\n'));
console.log("Replaced fonts exactly.");
