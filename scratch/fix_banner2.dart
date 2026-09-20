import 'dart:io';

void main() {
  File file = File('lib/main.dart');
  String content = file.readAsStringSync();

  String oldBannerDef = '''
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
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color)),
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
'''.trim();

  String newBannerDef = '''
  Widget _buildBanner(
      {required IconData icon,
      required String title,
      required String desc,
      required Color color,
      required bool isDesktop}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: isDesktop ? 0.0 : 2.0),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isDesktop
                ? Row(
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: color)),
                      if (desc.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(desc,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: color.withOpacity(0.85),
                                  height: 1.3)),
                        ),
                      ],
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: color)),
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
'''.trim();

  String oldBannerCall = '''
            _buildBanner(
              icon: Icons.insights,
              title: '蒙特卡洛 12 个月复利与走势演练',
              desc: '用客观概率打破赌徒侥幸心理。模拟连续12个月后资金曲线，直观感受风控红线的威力和回撤规律。',
              color: const Color(0xFFE11D48),
            ),
'''.trim();

  String newBannerCall = '''
            _buildBanner(
              icon: Icons.insights,
              title: '蒙特卡洛 12 个月复利与走势演练',
              desc: '用客观概率打破赌徒侥幸心理。模拟连续12个月后资金曲线，直观感受风控红线的威力和回撤规律。',
              color: const Color(0xFFE11D48),
              isDesktop: isDesktop,
            ),
'''.trim();

  content = content.replaceFirst(oldBannerDef, newBannerDef);
  content = content.replaceFirst(oldBannerCall, newBannerCall);
  
  file.writeAsStringSync(content);
  print('Done replacing!');
}
