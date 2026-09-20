import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  List<String> lines = file.readAsLinesSync();
  
  int start = -1;
  int end = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Widget _buildBanner(')) {
      start = i;
    }
    if (start != -1 && lines[i].contains(');') && i > start + 30) {
      end = i;
      break;
    }
  }
  
  if (start != -1 && end != -1) {
    List<String> newBanner = '''
  Widget _buildBanner(
      {required IconData icon,
      required String title,
      required String desc,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(desc,
                      style: TextStyle(
                          fontSize: 11,
                          color: color.withOpacity(0.85),
                          height: 1.3)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
'''.trim().split('\\n');

    lines.replaceRange(start, end + 2, newBanner);
    file.writeAsStringSync(lines.join('\\n'));
    print('Fixed _buildBanner!');
  } else {
    print('Could not find _buildBanner');
  }
}
