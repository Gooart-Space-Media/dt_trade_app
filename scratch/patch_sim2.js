const fs = require('fs');

let mainCode = fs.readFileSync('lib/main.dart', 'utf-8');

const startIndex = mainCode.indexOf('class SurvivalSimulatorPage extends StatefulWidget {');

if (startIndex !== -1) {
  const before = mainCode.substring(0, startIndex);
  const newSimCalc = fs.readFileSync('scratch/sim_calc_fixed.dart', 'utf-8');
  
  fs.writeFileSync('lib/main.dart', before + newSimCalc + '\n');
  console.log('Successfully patched main.dart!');
} else {
  console.error('Could not find SurvivalSimulatorPage in main.dart');
}
