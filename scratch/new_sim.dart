  void runSimulation() {
    HapticFeedback.mediumImpact();
    
    int blownUpDtCount = 0;
    int blownUpStCount = 0;
    Random rand = Random();

    // Determine DT Trade 1 RR based on user's selected RR
    double dtTrade1RR = rr;
    if (rr == 1.5) dtTrade1RR = 1.0;
    else if (rr == 2.0) dtTrade1RR = 1.5;
    else if (rr == 3.0) dtTrade1RR = 2.0;

    for (int sim = 0; sim < 1000; sim++) {
      double balDt = startBal;
      double balSt = startBal;
      double peakDt = startBal;
      double peakSt = startBal;
      bool blowDt = false;
      bool blowSt = false;

      List<bool> simWins = List.generate(120, (_) => (rand.nextDouble() * 100) < winRate);

      for (int i = 0; i < 120; i++) {
        bool isWin = simWins[i];
        bool hitPartial = false;
        
        // Check if Single Track loses, but Dual Track hits Trade 1 target
        if (!isWin && rr > dtTrade1RR && rand.nextInt(100) < 30) {
          hitPartial = true;
        }

        if (!blowDt) {
          double riskDt = balDt * (riskPct / 100);
          if (isWin) {
            double runnerRR = 0;
            int runDice = rand.nextInt(100);
            if (runDice < 30) runnerRR = 0;
            else if (runDice < 70) runnerRR = rr;
            else if (runDice < 90) runnerRR = rr + 1.0;
            else runnerRR = rr + 2.0;
            balDt += (riskDt / 2.0 * dtTrade1RR) + (riskDt / 2.0 * runnerRR);
          } else if (hitPartial) {
            balDt += (riskDt / 2.0 * dtTrade1RR); // Trade 1 wins, Trade 2 breakeven (0)
          } else {
            balDt -= riskDt;
          }
          if (balDt > peakDt) peakDt = balDt;
          double dd = ((peakDt - balDt) / peakDt) * 100;
          if (dd >= 40 || balDt <= 0) blowDt = true;
        }

        if (!blowSt) {
          double riskSt = balSt * (riskPct / 100);
          if (isWin) {
            balSt += riskSt * rr;
          } else {
            balSt -= riskSt; // Even if hitPartial is true, ST held for rr and eventually lost
          }
          if (balSt > peakSt) peakSt = balSt;
          double dd = ((peakSt - balSt) / peakSt) * 100;
          if (dd >= 40 || balSt <= 0) blowSt = true;
        }
      }
      if (blowDt) blownUpDtCount++;
      if (blowSt) blownUpStCount++;
    }

    // Actual simulation run (1 time) for chart and table
    List<bool> actualWins = List.generate(120, (_) => (rand.nextDouble() * 100) < winRate);

    double dtBalance = startBal;
    double stBalance = startBal;
    double dtPeak = startBal;
    double stPeak = startBal;
    double dtMaxDrawdown = 0;
    double stMaxDrawdown = 0;
    int dtCurrentStreak = 0;
    int stCurrentStreak = 0;
    int dtMaxStreak = 0;
    int stMaxStreak = 0;
    bool dtBlownUp = false;
    bool stBlownUp = false;

    List<double> dtMonthlyProfits = [];
    List<double> dtEquityPoints = [startBal];
    List<double> stEquityPoints = [startBal];

    int tradeIndex = 0;
    for (int m = 1; m <= 12; m++) {
      double mStartDt = dtBalance;
      for (int i = 0; i < 10; i++) {
        bool isWin = actualWins[tradeIndex++];
        bool hitPartial = false;
        
        if (!isWin && rr > dtTrade1RR && rand.nextInt(100) < 30) {
          hitPartial = true;
        }
        
        // Dual Track Logic
        if (!dtBlownUp) {
          double riskDt = dtBalance * (riskPct / 100);
          if (isWin) {
            double runnerRR = 0;
            int runDice = rand.nextInt(100);
            if (runDice < 30) runnerRR = 0;
            else if (runDice < 70) runnerRR = rr;
            else if (runDice < 90) runnerRR = rr + 1.0;
            else runnerRR = rr + 2.0;
            
            dtBalance += (riskDt / 2.0 * dtTrade1RR) + (riskDt / 2.0 * runnerRR);
            dtCurrentStreak = 0;
          } else if (hitPartial) {
            dtBalance += (riskDt / 2.0 * dtTrade1RR);
            dtCurrentStreak = 0; // Partial win breaks the losing streak
          } else {
            dtBalance -= riskDt;
            dtCurrentStreak++;
            if (dtCurrentStreak > dtMaxStreak) dtMaxStreak = dtCurrentStreak;
          }
          if (dtBalance > dtPeak) dtPeak = dtBalance;
          double dd = ((dtPeak - dtBalance) / dtPeak) * 100;
          if (dd > dtMaxDrawdown) dtMaxDrawdown = dd;
          if (dd >= 40 || dtBalance <= 0) {
            dtBlownUp = true;
            dtBalance = 0;
          }
        }

        // Single Track Logic
        if (!stBlownUp) {
          double riskSt = stBalance * (riskPct / 100);
          if (isWin) {
            stBalance += riskSt * rr;
            stCurrentStreak = 0;
          } else {
            stBalance -= riskSt;
            stCurrentStreak++;
            if (stCurrentStreak > stMaxStreak) stMaxStreak = stCurrentStreak;
          }
          if (stBalance > stPeak) stPeak = stBalance;
          double dd = ((stPeak - stBalance) / stPeak) * 100;
          if (dd > stMaxDrawdown) stMaxDrawdown = dd;
          if (dd >= 40 || stBalance <= 0) {
            stBlownUp = true;
            stBalance = 0;
          }
        }
      }
      dtMonthlyProfits.add(dtBalance - mStartDt);
      dtEquityPoints.add(dtBalance);
      stEquityPoints.add(stBalance);
    }

