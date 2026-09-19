const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');
const lines = code.split('\n');

const start = lines.findIndex(l => l.includes('void runSimulation() {'));
const end = lines.findIndex((l, i) => i > start && l.includes('setState(() {'));

const newSim = fs.readFileSync('scratch/new_sim.dart', 'utf-8');

const newCode = lines.slice(0, start).join('\n') + '\n' + newSim + lines.slice(end).join('\n');
fs.writeFileSync('lib/main.dart', newCode);
console.log('Replaced runSimulation!');
