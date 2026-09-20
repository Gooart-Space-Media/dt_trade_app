const fs = require('fs');
const lines = fs.readFileSync('lib/main.dart', 'utf-8').split('\n');

const stateStart = lines.findIndex(l => l.includes('class _MainScreenState'));
const buildStart = lines.findIndex((l, i) => i > stateStart && l.includes('Widget build(BuildContext context)'));

const radarCode = fs.readFileSync('scratch/radar_sheet.dart', 'utf-8').split('\n');
lines.splice(buildStart, 0, ...radarCode);

// Find actions: [
const actionsIdx = lines.findIndex((l, i) => i > buildStart && l.includes('actions: ['));

const iconBtnCode = `          IconButton(
            icon: const Icon(Icons.radar_rounded, color: Color(0xFF2563EB)),
            tooltip: '盘口雷达',
            onPressed: () {
              HapticFeedback.selectionClick();
              _showRadarBottomSheet(context);
            },
          ),`;

lines.splice(actionsIdx + 1, 0, ...iconBtnCode.split('\n'));

fs.writeFileSync('lib/main.dart', lines.join('\n'));
console.log('Successfully injected radar dialog and icon!');
