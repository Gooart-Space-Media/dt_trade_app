const fs = require('fs');

let mainCode = fs.readFileSync('lib/main.dart', 'utf-8');

const simCalcRegex = /class SurvivalSimulatorPage extends StatefulWidget \{[\s\S]*?(?=class MainScreen extends StatefulWidget \{)/;

const newSimCalc = fs.readFileSync('scratch/sim_calc_fixed.dart', 'utf-8');

if (mainCode.match(simCalcRegex)) {
  mainCode = mainCode.replace(simCalcRegex, newSimCalc + '\n\n');
  fs.writeFileSync('lib/main.dart', mainCode);
  console.log('Successfully patched main.dart with SurvivalSimulatorPage!');
} else {
  console.error('Regex did not match!');
}
