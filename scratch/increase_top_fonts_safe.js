const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf8');

// I will just replace the exact lines that define the font sizes for these text elements.
// To be very safe, I'll find the line index and replace it.
const lines = code.split('\n');
const idx = lines.findIndex(l => l.includes("final topRowChildren = ["));

if (idx !== -1) {
    for (let i = idx; i < idx + 40; i++) {
        if (lines[i].includes('fontSize: 12,')) {
            lines[i] = lines[i].replace('fontSize: 12,', 'fontSize: 13.5,');
        }
        if (lines[i].includes('fontSize: 9,')) {
            lines[i] = lines[i].replace('fontSize: 9,', 'fontSize: 11.5,');
        }
    }
}

// the desc text can be in two places (desktop vs mobile layout builder)
const descIdx1 = lines.findIndex(l => l.includes("child: Text(session['desc'] as String,"));
if (descIdx1 !== -1) {
    for (let i = descIdx1; i < descIdx1 + 10; i++) {
        if (lines[i].includes('fontSize: 10,')) {
            lines[i] = lines[i].replace('fontSize: 10,', 'fontSize: 12.5,');
        }
    }
}

const descIdx2 = lines.findIndex(l => l.includes("Text(session['desc'] as String,"));
if (descIdx2 !== -1) {
    // we want to skip the first one if it's the same, but findIndex gets the first one. Let's just loop from top to bottom
    for (let i = idx; i < idx + 100; i++) {
        if (lines[i].includes("Text(session['desc'] as String,")) {
             for (let j = i; j < i + 10; j++) {
                 if (lines[j].includes('fontSize: 10,')) {
                     lines[j] = lines[j].replace('fontSize: 10,', 'fontSize: 12.5,');
                 }
             }
        }
    }
}

fs.writeFileSync('lib/main.dart', lines.join('\n'));
console.log("Replaced fonts perfectly by index.");
