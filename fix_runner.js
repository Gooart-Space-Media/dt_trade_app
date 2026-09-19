const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

const dtLogicBal = `
            double runnerRR = 0;
            int runDice = rand.nextInt(100);
            if (runDice < 30) {
              runnerRR = 0;
            } else if (runDice < 70) {
              runnerRR = rr;
            } else if (runDice < 90) {
              runnerRR = rr + 1.0;
            } else {
              runnerRR = rr + 2.0;
            }
            balDt += (riskDt / 2.0 * 1.0) + (riskDt / 2.0 * runnerRR);`;

const dtLogicDt = `
            double runnerRR = 0;
            int runDice = rand.nextInt(100);
            if (runDice < 30) {
              runnerRR = 0;
            } else if (runDice < 70) {
              runnerRR = rr;
            } else if (runDice < 90) {
              runnerRR = rr + 1.0;
            } else {
              runnerRR = rr + 2.0;
            }
            dtBalance += (riskDt / 2.0 * 1.0) + (riskDt / 2.0 * runnerRR);`;

code = code.replace(/balDt \+= \(riskDt \/ 2\.0 \* 1\.0\) \+ \(riskDt \/ 2\.0 \* rr\);/g, dtLogicBal);
code = code.replace(/dtBalance \+= \(riskDt \/ 2\.0 \* 1\.0\) \+ \(riskDt \/ 2\.0 \* rr\);/g, dtLogicDt);

fs.writeFileSync('lib/main.dart', code);
console.log('Runner logic injected!');
