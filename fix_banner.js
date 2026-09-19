const fs = require('fs');
let code = fs.readFileSync('lib/main.dart', 'utf-8');

// 1. Fix flex ratio: 50/50
code = code.replace(/flex: 2,/, 'flex: 1,');
code = code.replace(/flex: 3,/, 'flex: 1,');

// 2. Change _buildBanner: title on left, desc on right (same row)
const oldBanner = `Widget _buildBanner({required IconData icon, required String title, required String desc, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 11, color: color.withOpacity(0.85), height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }`;

const newBanner = `Widget _buildBanner({required IconData icon, required String title, required String desc, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          if (desc.isNotEmpty) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(desc, style: TextStyle(fontSize: 11, color: color.withOpacity(0.85), height: 1.3)),
            ),
          ],
        ],
      ),
    );
  }`;

if (code.includes(oldBanner)) {
  code = code.replace(oldBanner, newBanner);
  console.log('Banner replaced');
} else {
  console.log('WARNING: could not find old banner pattern');
}

fs.writeFileSync('lib/main.dart', code);
console.log('Done');
