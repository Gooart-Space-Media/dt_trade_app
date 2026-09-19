import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const EngulfingMasterApp());
}

class EngulfingMasterApp extends StatefulWidget {
  const EngulfingMasterApp({super.key});

  @override
  State<EngulfingMasterApp> createState() => _EngulfingMasterAppState();
}

class _EngulfingMasterAppState extends State<EngulfingMasterApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('app_is_dark') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme() async {
    final isDark = _themeMode == ThemeMode.dark;
    final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
    setState(() {
      _themeMode = nextMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_is_dark', nextMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '双轨风控大师 Pro · 吞没战法指挥部',
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.12)), child: child!),      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          elevation: 0.5,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: MainScreen(toggleTheme: _toggleTheme, isDark: _themeMode == ThemeMode.dark),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const MainScreen({super.key, required this.toggleTheme, required this.isDark});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  Timer? _clockTimer;
  DateTime _myTime = DateTime.now().toUtc().add(const Duration(hours: 8));

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      setState(() {
        _myTime = DateTime.now().toUtc().add(const Duration(hours: 8));
      });
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  // 大马时间 (GMT+8) 盘口时段雷达计算与精准倒计时
  Map<String, dynamic> _getSessionInfo() {
    final h = _myTime.hour;
    final m = _myTime.minute;
    final totalMinutes = h * 60 + m;

    String countdown = '';
    String status = '';
    String desc = '';
    Color color = const Color(0xFF64748B);
    bool active = false;

    if (h == 7) {
      status = '🌅 晨间设单窗口';
      desc = 'D1 日线收盘，7:00-8:00 挂单后关闭软件 (Set & Forget)';
      color = const Color(0xFFD97706);
      active = true;
      int diff = 8 * 60 - totalMinutes;
      countdown = '距窗口关闭 ${diff}分';
    } else if (h >= 8 && h < 15) {
      status = '☕ 亚盘静默观察期';
      desc = '让市场来找我。亚盘波动小，绝不因 FOMO 手动追单';
      color = const Color(0xFF64748B);
      active = false;
      int diff = 15 * 60 - totalMinutes;
      int dh = diff ~/ 60;
      int dm = diff % 60;
      countdown = '距 15:00 伦敦盘 ${dh}h${dm.toString().padLeft(2, '0')}m';
    } else if (h >= 15 && (h < 20 || (h == 20 && m < 30))) {
      status = '🇬🇧 伦敦盘爆发中';
      desc = '欧洲资金进场，日线挂单迎来首波突破与测试';
      color = const Color(0xFF2563EB);
      active = true;
      int diff = (20 * 60 + 30) - totalMinutes;
      int dh = diff ~/ 60;
      int dm = diff % 60;
      countdown = '距 20:30 主战场 ${dh}h${dm.toString().padLeft(2, '0')}m';
    } else if ((h == 20 && m >= 30) || (h >= 21 && h < 24)) {
      status = '🔥 伦纽重叠主战场';
      desc = '全天最大波动窗口！20:30-24:00 留意 Trade 1 止盈与推保本';
      color = const Color(0xFFDC2626);
      active = true;
      int diff = 24 * 60 - totalMinutes;
      int dh = diff ~/ 60;
      int dm = diff % 60;
      countdown = '🔥 距尾盘 ${dh}h${dm.toString().padLeft(2, '0')}m';
    } else {
      status = '🌙 纽约尾盘与休市';
      desc = '市场趋缓，保持良好作息，迎接明日晨间开盘';
      color = const Color(0xFF475569);
      active = false;
      int diff = (7 * 60 - totalMinutes);
      if (diff < 0) diff += 24 * 60;
      int dh = diff ~/ 60;
      int dm = diff % 60;
      countdown = '距明日 07:00 晨盘 ${dh}h${dm.toString().padLeft(2, '0')}m';
    }

    return {
      'status': status,
      'desc': desc,
      'color': color,
      'active': active,
      'countdown': countdown,
    };
  }

  final List<Widget> _pages = const [
    OverlapCheckerPage(),
    LotSizeCalcPage(),
    TpCalculatorPage(),
    SurvivalSimulatorPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final session = _getSessionInfo();
    final timeStr = "${_myTime.hour.toString().padLeft(2, '0')}:${_myTime.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF4F46E5)]),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('DT', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 8),
            const Text('双轨风控大师 Pro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            tooltip: '切换明暗模式',
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部：大马时间盘口时段雷达条（附动态倒计时）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: (session['color'] as Color).withOpacity(0.08),
              border: Border(bottom: BorderSide(color: (session['color'] as Color).withOpacity(0.2))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: session['color'] as Color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('MY $timeStr', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(session['status'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: session['color'] as Color)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: (session['color'] as Color).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: (session['color'] as Color).withOpacity(0.25)),
                            ),
                            child: Text(
                              session['countdown'] as String,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: session['color'] as Color),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(session['desc'] as String, style: TextStyle(fontSize: 10, color: (session['color'] as Color).withOpacity(0.85)), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = idx);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded),
            label: '组合防呆',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded),
            label: '双轨手数',
          ),
          NavigationDestination(
            icon: Icon(Icons.gps_fixed_outlined),
            selectedIcon: Icon(Icons.gps_fixed_rounded),
            label: '吞没狙击',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: '复利走势',
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 通用：一键复制小工具
// -------------------------------------------------------------
void copyToClipboard(BuildContext context, String text, String label) {
  Clipboard.setData(ClipboardData(text: text));
  HapticFeedback.mediumImpact();
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF0F172A),
      duration: const Duration(seconds: 2),
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text('已复制 $label: $text (直接粘贴至 MT4/MT5)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );
}

// -------------------------------------------------------------
// 🎯 16 大监控货币对与观察品种规范模型 (基于 Notion 核心体系)
// 核心品种 (7个) + 次要品种 (9个) + 独立观察品种 (现货黄金)
// -------------------------------------------------------------
class WatchlistPair {
  final String symbol;
  final String chineseName;
  final String category; // 'core', 'minor', 'observed'
  final String categoryLabel; // '⭐ 核心', '🔹 次要', '🥇 观察'
  final bool isJpy;
  final bool isGold;
  final String defaultHigh;
  final String defaultLow;
  final String feature;
  final String liquidity;
  final String session;

  const WatchlistPair({
    required this.symbol,
    required this.chineseName,
    required this.category,
    required this.categoryLabel,
    this.isJpy = false,
    this.isGold = false,
    required this.defaultHigh,
    required this.defaultLow,
    required this.feature,
    required this.liquidity,
    required this.session,
  });

  bool get isCore => category == 'core';
  bool get isMinor => category == 'minor';
}

const List<WatchlistPair> kWatchlistPairs = [
  // ⭐ 7 大核心货币对 (Core Pairs) - 全球成交量最大，点差极低，滑点极小，形态最可靠
  WatchlistPair(
    symbol: 'EURUSD',
    chineseName: '欧美',
    category: 'core',
    categoryLabel: '⭐ 核心',
    defaultHigh: '1.08800',
    defaultLow: '1.08000',
    feature: '全球成交第一 · 点差极低 · 脾气最温和',
    liquidity: '极高',
    session: '伦敦盘 / 伦纽重叠',
  ),
  WatchlistPair(
    symbol: 'USDJPY',
    chineseName: '美日',
    category: 'core',
    categoryLabel: '⭐ 核心',
    isJpy: true,
    defaultHigh: '155.800',
    defaultLow: '154.900',
    feature: '美日利差驱动 · 逻辑清晰 · 对新手友好',
    liquidity: '极高',
    session: '亚洲盘 / 纽约盘',
  ),
  WatchlistPair(
    symbol: 'AUDUSD',
    chineseName: '澳美',
    category: 'core',
    categoryLabel: '⭐ 核心',
    defaultHigh: '0.65800',
    defaultLow: '0.65100',
    feature: '亚太盘活跃 · 中国经济与商品晴雨表',
    liquidity: '高',
    session: '亚洲盘 / 伦纽重叠',
  ),
  WatchlistPair(
    symbol: 'GBPUSD',
    chineseName: '镑美',
    category: 'core',
    categoryLabel: '⭐ 核心',
    defaultHigh: '1.27500',
    defaultLow: '1.26600',
    feature: '俗称电缆 · 波动大 · 数据时易急拉急杀',
    liquidity: '极高',
    session: '伦敦盘 / 伦纽重叠',
  ),
  WatchlistPair(
    symbol: 'USDCAD',
    chineseName: '美加',
    category: 'core',
    categoryLabel: '⭐ 核心',
    defaultHigh: '1.38500',
    defaultLow: '1.37800',
    feature: '原油影子 · 趋势段落清晰 · 纽约盘活跃',
    liquidity: '高',
    session: '纽约盘 / 伦纽重叠',
  ),
  WatchlistPair(
    symbol: 'EURJPY',
    chineseName: '欧日',
    category: 'core',
    categoryLabel: '⭐ 核心',
    isJpy: true,
    defaultHigh: '164.200',
    defaultLow: '163.300',
    feature: '交叉盘流动性之王 · 趋势干净利落',
    liquidity: '高',
    session: '伦敦盘 / 伦纽重叠',
  ),
  WatchlistPair(
    symbol: 'GBPJPY',
    chineseName: '镑日',
    category: 'core',
    categoryLabel: '⭐ 核心',
    isJpy: true,
    defaultHigh: '198.500',
    defaultLow: '197.200',
    feature: '俗称妖镑 · 波幅130+点 · 必须严格缩仓',
    liquidity: '高',
    session: '伦敦盘 / 伦纽重叠',
  ),

  // 🔹 9 大次要货币对 (Minor Pairs) - 补充高质量日线吞没信号
  WatchlistPair(
    symbol: 'EURGBP',
    chineseName: '欧镑',
    category: 'minor',
    categoryLabel: '🔹 次要',
    defaultHigh: '0.85500',
    defaultLow: '0.84900',
    feature: '区域交叉盘 · 波动平缓 · 点差较窄',
    liquidity: '中高',
    session: '伦敦盘',
  ),
  WatchlistPair(
    symbol: 'AUDNZD',
    chineseName: '澳纽',
    category: 'minor',
    categoryLabel: '🔹 次要',
    defaultHigh: '1.08200',
    defaultLow: '1.07600',
    feature: '澳纽兄弟对 · 走势同频 · 长期箱体震荡',
    liquidity: '中',
    session: '亚洲盘',
  ),
  WatchlistPair(
    symbol: 'NZDUSD',
    chineseName: '纽美',
    category: 'minor',
    categoryLabel: '🔹 次要',
    defaultHigh: '0.59800',
    defaultLow: '0.59200',
    feature: '商品直盘 · 全球乳制品与风险偏好驱动',
    liquidity: '中高',
    session: '亚洲盘 / 伦纽重叠',
  ),
  WatchlistPair(
    symbol: 'USDCHF',
    chineseName: '美瑞',
    category: 'minor',
    categoryLabel: '🔹 次要',
    defaultHigh: '0.88500',
    defaultLow: '0.87900',
    feature: '终极避险直盘 · 平时波动小 · 黑天鹅首选',
    liquidity: '高',
    session: '伦敦盘 / 伦纽重叠',
  ),
  WatchlistPair(
    symbol: 'AUDJPY',
    chineseName: '澳日',
    category: 'minor',
    categoryLabel: '🔹 次要',
    isJpy: true,
    defaultHigh: '98.600',
    defaultLow: '97.700',
    feature: '风险情绪晴雨表 · 经典高息套息交叉盘',
    liquidity: '中高',
    session: '亚洲盘 / 伦纽重叠',
  ),
  WatchlistPair(
    symbol: 'AUDCAD',
    chineseName: '澳加',
    category: 'minor',
    categoryLabel: '🔹 次要',
    defaultHigh: '0.91200',
    defaultLow: '0.90500',
    feature: '双商品货币交叉 · 铁矿石与原油博弈',
    liquidity: '中',
    session: '伦纽重叠',
  ),
  WatchlistPair(
    symbol: 'EURCAD',
    chineseName: '欧加',
    category: 'minor',
    categoryLabel: '🔹 次要',
    defaultHigh: '1.47800',
    defaultLow: '1.47000',
    feature: '欧元与原油交叉盘 · 伦纽重叠段活跃',
    liquidity: '中',
    session: '伦纽重叠',
  ),
  WatchlistPair(
    symbol: 'EURAUD',
    chineseName: '欧澳',
    category: 'minor',
    categoryLabel: '🔹 次要',
    defaultHigh: '1.65200',
    defaultLow: '1.64300',
    feature: '欧洲与澳洲经济强弱对比 · 趋势波幅大',
    liquidity: '中',
    session: '伦敦盘 / 伦纽重叠',
  ),
  WatchlistPair(
    symbol: 'CADJPY',
    chineseName: '加日',
    category: 'minor',
    categoryLabel: '🔹 次要',
    isJpy: true,
    defaultHigh: '112.500',
    defaultLow: '111.600',
    feature: '原油拉动加元 · 日元息差驱动 · 波动佳',
    liquidity: '中',
    session: '纽约盘 / 亚洲盘',
  ),

  // 🥇 独立观察品种 (Observed)
  WatchlistPair(
    symbol: 'XAUUSD',
    chineseName: '现货黄金',
    category: 'observed',
    categoryLabel: '🥇 观察',
    isGold: true,
    defaultHigh: '2650.00',
    defaultLow: '2635.00',
    feature: '美黄金 · 波动极大 · 建议大资金或微型仓',
    liquidity: '极高',
    session: '全时段 / 纽约主场',
  ),
];

WatchlistPair getWatchlistPair(String symbol) {
  return kWatchlistPairs.firstWhere(
    (p) => p.symbol == symbol,
    orElse: () => kWatchlistPairs.first,
  );
}

void showWatchlistAtlasDialog(BuildContext context, {ValueChanged<WatchlistPair>? onSelect}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      final coreList = kWatchlistPairs.where((p) => p.isCore).toList();
      final minorList = kWatchlistPairs.where((p) => p.isMinor).toList();
      final goldList = kWatchlistPairs.where((p) => p.category == 'observed').toList();

      return Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.radar_rounded, color: Color(0xFF2563EB), size: 22),
                    SizedBox(width: 8),
                    Text('🎯 16 大监控货币对全景图鉴', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '根据 Notion 交易体系规范：严选 7 大核心 + 9 大次要品种，杜绝乱做毒药货币对！点击任意品种可直接载入。',
              style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
            ),
            const Divider(height: 18),
            Expanded(
              child: ListView(
                children: [
                  // ⭐ 7 大核心货币对
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Text('⭐ 7 大核心货币对 (Core Pairs)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFB45309))),
                        Spacer(),
                        Text('新手 90% 时间待在此处', style: TextStyle(fontSize: 10.5, color: Color(0xFF92400E), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...coreList.map((p) => _buildPairDetailTile(ctx, p, onSelect)),
                  const SizedBox(height: 16),

                  // 🔹 9 大次要货币对
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      children: [
                        Text('🔹 9 大次要货币对 (Minor Pairs)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1D4ED8))),
                        Spacer(),
                        Text('趋势极强交叉盘 · 补充信号', style: TextStyle(fontSize: 10.5, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...minorList.map((p) => _buildPairDetailTile(ctx, p, onSelect)),
                  const SizedBox(height: 16),

                  // 🥇 独立观察品种
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Text('🥇 独立观察大宗商品', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E))),
                        Spacer(),
                        Text('高波动 · 仅限微型/大资金', style: TextStyle(fontSize: 10.5, color: Color(0xFF78350F), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...goldList.map((p) => _buildPairDetailTile(ctx, p, onSelect)),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildPairDetailTile(BuildContext context, WatchlistPair p, ValueChanged<WatchlistPair>? onSelect) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.15)),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onSelect != null
          ? () {
              Navigator.pop(context);
              onSelect(p);
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: p.isCore
                    ? const Color(0xFFFEF3C7)
                    : (p.isGold ? const Color(0xFFFDE68A) : const Color(0xFFEFF6FF)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                p.categoryLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: p.isCore
                      ? const Color(0xFFB45309)
                      : (p.isGold ? const Color(0xFF92400E) : const Color(0xFF1D4ED8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(p.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 6),
                      Text('(${p.chineseName})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text(p.session, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(p.feature, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                ],
              ),
            ),
            if (onSelect != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
            ],
          ],
        ),
      ),
    ),
  );
}

// -------------------------------------------------------------
// 1. 组合防呆构建器（新增：晨间 10 秒美元/日元单向敞口自审 & 毒药黑名单）
// -------------------------------------------------------------
class OverlapCheckerPage extends StatefulWidget {
  const OverlapCheckerPage({super.key});

  @override
  State<OverlapCheckerPage> createState() => _OverlapCheckerPageState();
}

class _OverlapCheckerPageState extends State<OverlapCheckerPage> {
  final List<String> corePairs = kWatchlistPairs.where((p) => p.isCore).map((p) => p.symbol).toList();
  final List<String> minorPairs = kWatchlistPairs.where((p) => p.isMinor).map((p) => p.symbol).toList();
  final List<String> observedPairs = kWatchlistPairs.where((p) => p.category == 'observed').map((p) => p.symbol).toList();

  String? s1;
  String? s2;
  String? s3;

  String dir1 = '多';
  String dir2 = '多';
  String dir3 = '多';
  List<bool> checklist = [false, false, false, false];


  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      s1 = prefs.getString('ol_s1');
      s2 = prefs.getString('ol_s2');
      s3 = prefs.getString('ol_s3');
      dir1 = prefs.getString('ol_d1') ?? '多';
      dir2 = prefs.getString('ol_d2') ?? '多';
      dir3 = prefs.getString('ol_d3') ?? '多';
      for(int i=0; i<4; i++) { checklist[i] = prefs.getString('ol_chk_${i}') == 'true'; }
    });
  }

  Future<void> _saveState(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }


  bool isConflict(String pair, List<String?> selectedOthers) {
    String base = pair.substring(0, 3);
    String quote = pair.substring(3, 6);
    for (var other in selectedOthers) {
      if (other != null && other.isNotEmpty) {
        if (other.contains(base) || other.contains(quote)) return true;
      }
    }
    return false;
  }

  // 晨间 10 秒单向敞口自审算法 (检测同质化做空/做多 USD 或 JPY)
  Map<String, dynamic> _auditCorrelation() {
    final trades = [
      if (s1 != null) {'pair': s1!, 'dir': dir1},
      if (s2 != null) {'pair': s2!, 'dir': dir2},
      if (s3 != null) {'pair': s3!, 'dir': dir3},
    ];

    if (trades.length < 2) {
      return {'hasRisk': false, 'msg': '选择 2~3 个品种后，系统将自动自审同向汇率共振风险。'};
    }

    int usdShortCount = 0;
    int usdLongCount = 0;

    for (var t in trades) {
      final p = t['pair'] as String;
      final isBuy = t['dir'] == '多';

      if (p == 'EURUSD' || p == 'GBPUSD' || p == 'AUDUSD' || p == 'NZDUSD' || p == 'XAUUSD') {
        if (isBuy) usdShortCount++; else usdLongCount++;
      } else if (p == 'USDJPY' || p == 'USDCAD' || p == 'USDCHF') {
        if (isBuy) usdLongCount++; else usdShortCount++;
      }
    }

    if (usdShortCount >= 3) {
      return {
        'hasRisk': true,
        'msg': '⚠️ 危险重叠！当前 3 笔交易全部在单向【做空美元 (Short USD)】！属于同质化单向敞口，若非农/CPI数据强劲，将遭遇 6% 连环爆仓回撤！建议拆解或换交叉盘。'
      };
    } else if (usdLongCount >= 3) {
      return {
        'hasRisk': true,
        'msg': '⚠️ 危险重叠！当前 3 笔交易全部在单向【做多美元 (Long USD)】！一旦美元反转将全部止损，建议降低同质化敞口。'
      };
    }

    return {
      'hasRisk': false,
      'msg': '✅ 晨间 10 秒自审通过：3 笔交易不存在单向同质化敞口，结构独立，可安全同时建仓（总日风险控制在 6% 内）！'
    };
  }

  void _showAvoidListDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🚫 坚决规避的毒药品种 (The Avoid List)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 10),
              const Text('以下四类品种在实战中看似有机会，实则暗藏点差与政策陷阱，强烈建议拉黑跳过：', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const Divider(height: 20),
              Expanded(
                child: ListView(
                  children: const [
                    _AvoidCard(title: '1. 联系汇率挂钩类 (画直线)', pairs: 'EURDKK, USDHKD, EURHKD, USDDKK, GBPDKK', reason: '受央行强行挂钩制度约束，K线基本为水平直线，日波动甚至小于点差，毫无交易价值。'),
                    _AvoidCard(title: '2. 高息吃人断崖类 (点差过宽)', pairs: 'USDTRY, EURTRY, USDZAR, EURZAR, USDMXN', reason: '新兴市场货币恶性贬值，看似单边躺赚，但隔夜利息极其昂贵且极易发生政策跳空，利润全被磨光。'),
                    _AvoidCard(title: '3. 极低流动性类 (严重滑点)', pairs: 'GBPSEK, GBPNOK, CHFSGD, NZDSGD, GBPSGD', reason: '挂单成交极不活跃，止损往往无法在预设点位成交，遭遇极端滑点击穿账户。'),
                    _AvoidCard(title: '4. 恶劣交叉盘规避', pairs: 'GBPNZD', reason: '虽然日均波幅极大，但点差同样极其昂贵，盈利空间往往刚好抵消高额交易成本。'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    final allPairs = [...corePairs, ...minorPairs, ...observedPairs];
    bool isComplete = (s1 != null && s2 != null && s3 != null);
    final audit = _auditCorrelation();

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : 750),
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🛡️ 多单并行防呆与自审', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Row(
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 6)),
                  onPressed: () => showWatchlistAtlasDialog(context),
                  icon: const Icon(Icons.menu_book_rounded, size: 15, color: Color(0xFF2563EB)),
                  label: const Text('16品种图鉴', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 6)),
                  onPressed: _showAvoidListDialog,
                  icon: const Icon(Icons.warning_amber_rounded, size: 15, color: Colors.red),
                  label: const Text('毒药黑名单', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.stars_rounded, size: 16, color: Color(0xFFD97706)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  '规范选项：⭐ 7大核心货币对 (极低点差) + 🔹 9大次要交叉盘',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              InkWell(
                onTap: () => showWatchlistAtlasDialog(context),
                child: const Text('详解 >', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDropdownRow('交易 1 (首选主线)', s1, dir1, allPairs, [], (p) { setState(() { s1 = p; s2 = null; s3 = null; }); _saveState('ol_s1', p); _saveState('ol_s2', null); _saveState('ol_s3', null); }, (d) { setState(() => dir1 = d); _saveState('ol_d1', d); })),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdownRow('交易 2 (独立隔离)', s2, dir2, allPairs, [s1], (p) { setState(() { s2 = p; s3 = null; }); _saveState('ol_s2', p); _saveState('ol_s3', null); }, (d) { setState(() => dir2 = d); _saveState('ol_d2', d); })),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdownRow('交易 3 (独立隔离)', s3, dir3, allPairs, [s1, s2], (p) { setState(() => s3 = p); _saveState('ol_s3', p); }, (d) { setState(() => dir3 = d); _saveState('ol_d3', d); })),
            ],
          )
        else
          Column(
            children: [
              _buildDropdownRow('交易 1 (首选主线)', s1, dir1, allPairs, [], (p) { setState(() { s1 = p; s2 = null; s3 = null; }); _saveState('ol_s1', p); _saveState('ol_s2', null); _saveState('ol_s3', null); }, (d) { setState(() => dir1 = d); _saveState('ol_d1', d); }),
              const SizedBox(height: 10),
              _buildDropdownRow('交易 2 (独立隔离)', s2, dir2, allPairs, [s1], (p) { setState(() { s2 = p; s3 = null; }); _saveState('ol_s2', p); _saveState('ol_s3', null); }, (d) { setState(() => dir2 = d); _saveState('ol_d2', d); }),
              const SizedBox(height: 10),
              _buildDropdownRow('交易 3 (独立隔离)', s3, dir3, allPairs, [s1, s2], (p) { setState(() => s3 = p); _saveState('ol_s3', p); }, (d) { setState(() => dir3 = d); _saveState('ol_d3', d); }),
            ],
          ),
        const SizedBox(height: 16),

        // 晨间 10 秒单向敞口自审雷达卡片
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (audit['hasRisk'] as bool) ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: (audit['hasRisk'] as bool) ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon((audit['hasRisk'] as bool) ? Icons.warning_rounded : Icons.radar_rounded, size: 18, color: (audit['hasRisk'] as bool) ? Colors.red : const Color(0xFF15803D)),
                  const SizedBox(width: 6),
                  Text((audit['hasRisk'] as bool) ? '晨间自审预警：同质化过度曝险' : '晨间 10 秒风控自审雷达', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: (audit['hasRisk'] as bool) ? Colors.red : const Color(0xFF15803D))),
                ],
              ),
              const SizedBox(height: 4),
              Text(audit['msg'] as String, style: TextStyle(fontSize: 11, height: 1.4, color: (audit['hasRisk'] as bool) ? const Color(0xFF991B1B) : const Color(0xFF166534))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.fact_check_rounded, size: 18, color: Color(0xFF475569)),
            const SizedBox(width: 8),
            const Text('飞行员起飞前：最后 10 秒防呆自检', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const Spacer(),
            if (checklist.every((e) => e))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF22C55E), borderRadius: BorderRadius.circular(20)),
                child: const Text('准许执行 (CLEAR TO ENGAGE)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              )
          ],
        ),
        const SizedBox(height: 12),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildChecklistItem(0),
                    _buildChecklistItem(1),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _buildChecklistItem(2),
                    _buildChecklistItem(3),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildChecklistItem(0),
              _buildChecklistItem(1),
              _buildChecklistItem(2),
              _buildChecklistItem(3),
            ],
          ),
      ],
    )));
  }


  Widget _buildChecklistItem(int index) {
    final titles = [
      '日内无重大数据发布 (如非农、CPI等核弹级数据)',
      '情绪绝对平稳，未受上笔交易 (大赚/大亏) 的 FOMO 影响',
      '严格遵循 DT 双轨制，已预设 Trade 1 的保本与止盈',
      '单笔总风险严格控制在 2% 内，绝不抱有重仓扛单侥幸'
    ];
    bool isChecked = checklist[index];
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => checklist[index] = !checklist[index]); _saveState('ol_chk_${index}', checklist[index] ? 'true' : 'false');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isChecked ? const Color(0xFFF0FDF4) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isChecked ? const Color(0xFF4ADE80) : Theme.of(context).dividerColor.withOpacity(0.2)),
          boxShadow: isChecked ? [BoxShadow(color: const Color(0xFF4ADE80).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF22C55E) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isChecked ? const Color(0xFF22C55E) : Colors.grey.shade400, width: 2),
              ),
              child: isChecked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titles[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                  color: isChecked ? const Color(0xFF166534) : const Color(0xFF475569),
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDropdownRow(String label, String? current, String dir, List<String> list, List<String?> others, ValueChanged<String?> onPairChanged, ValueChanged<String> onDirChanged) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('选择品种 (标注核心/次要)'),
                    value: current,
                    selectedItemBuilder: (ctx) {
                      return list.map((pairSymbol) {
                        final pair = getWatchlistPair(pairSymbol);
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: pair.isCore
                                      ? const Color(0xFFFEF3C7)
                                      : (pair.isGold ? const Color(0xFFFDE68A) : const Color(0xFFEFF6FF)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  pair.categoryLabel,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: pair.isCore
                                        ? const Color(0xFFB45309)
                                        : (pair.isGold ? const Color(0xFF92400E) : const Color(0xFF1D4ED8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(pair.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(width: 3),
                              Text('(${pair.chineseName})', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    items: list.map((pairSymbol) {
                      final pair = getWatchlistPair(pairSymbol);
                      bool conflict = isConflict(pairSymbol, others);
                      return DropdownMenuItem<String>(
                        value: conflict ? null : pairSymbol,
                        enabled: !conflict,
                        child: Row(
                          children: [
                            if (conflict) ...[
                              Text('🚫 $pairSymbol (关联货币冲突)', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: pair.isCore
                                      ? const Color(0xFFFEF3C7)
                                      : (pair.isGold ? const Color(0xFFFDE68A) : const Color(0xFFEFF6FF)),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: pair.isCore
                                        ? const Color(0xFFF59E0B)
                                        : (pair.isGold ? const Color(0xFFD97706) : const Color(0xFF60A5FA)),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  pair.categoryLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: pair.isCore
                                        ? const Color(0xFFB45309)
                                        : (pair.isGold ? const Color(0xFF92400E) : const Color(0xFF1D4ED8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(pair.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 4),
                              Text('(${pair.chineseName})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: onPairChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ToggleButtons(
              isSelected: [dir == '多', dir == '空'],
              borderRadius: BorderRadius.circular(8),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 28),
              selectedColor: Colors.white,
              fillColor: dir == '多' ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              onPressed: (index) {
                HapticFeedback.lightImpact();
                onDirChanged(index == 0 ? '多' : '空');
              },
              children: const [
                Text('多', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('空', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvoidCard extends StatelessWidget {
  final String title;
  final String pairs;
  final String reason;

  const _AvoidCard({required this.title, required this.pairs, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFECACA))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFB91C1C))),
          const SizedBox(height: 4),
          Text(pairs, style: const TextStyle(fontWeight: FontWeight.w900, fontFamily: 'monospace', fontSize: 12, color: Color(0xFF7F1D1D))),
          const SizedBox(height: 4),
          Text(reason, style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B), height: 1.3)),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. 双轨制手数计算器（新增：Fight IQ 物理级蜡烛长短健康诊断 & 500-3200标准速查表）
// -------------------------------------------------------------
class LotSizeCalcPage extends StatefulWidget {
  const LotSizeCalcPage({super.key});

  @override
  State<LotSizeCalcPage> createState() => _LotSizeCalcPageState();
}

class _LotSizeCalcPageState extends State<LotSizeCalcPage> {
  final TextEditingController _balCtrl = TextEditingController(text: '1000');
  final TextEditingController _rateCtrl = TextEditingController(text: '4.50');
  final TextEditingController _slCtrl = TextEditingController(text: '50');

  double balance = 1000;
  double rate = 4.50;
  int riskPct = 2;
  double slPips = 50;
  bool isGoldMode = false;
  bool isMicroMode = false;
  String activePair = "EURUSD";
  bool isFetchingRate = false;

  @override
  void initState() {
    super.initState();
    _loadSavedParams();
  }

  Future<void> _loadSavedParams() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getDouble('calc_balance') ?? 1000;
      rate = prefs.getDouble('calc_rate') ?? 4.50;
      riskPct = prefs.getInt('calc_risk') ?? 2;
      slPips = prefs.getDouble('calc_sl') ?? 50;
      isGoldMode = prefs.getBool('calc_is_gold') ?? false;
      isMicroMode = prefs.getBool('calc_is_micro') ?? false;
      activePair = prefs.getString('calc_active_pair') ?? 'EURUSD';

      _balCtrl.text = balance.toStringAsFixed(0);
      _rateCtrl.text = rate.toStringAsFixed(2);
      _slCtrl.text = slPips.toStringAsFixed(0);
    });
  }

  Future<void> _saveParam(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is double) await prefs.setDouble(key, value);
    if (value is int) await prefs.setInt(key, value);
    if (value is bool) await prefs.setBool(key, value);
      if (value is String) await prefs.setString(key, value);
  }

  Future<void> _fetchLiveExchangeRate() async {
    setState(() => isFetchingRate = true);
    HapticFeedback.lightImpact();
    try {
      final response = await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD')).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rates'] != null && data['rates']['MYR'] != null) {
          final liveRate = (data['rates']['MYR'] as num).toDouble();
          setState(() {
            rate = liveRate;
            _rateCtrl.text = rate.toStringAsFixed(2);
          });
          _saveParam('calc_rate', rate);
        }
      }
    } catch (_) {} finally {
      if (mounted) setState(() => isFetchingRate = false);
    }
  }

  // Fight IQ 物理级蜡烛长短健康诊断
  Map<String, dynamic> _getFightIqDiagnosis(double pips) {
    if (isGoldMode) {
      if (pips < 150) {
        return {
          'status': '🟡 黄金噪音小蜡烛 (< 150 Pips / < \$15)',
          'desc': '机构未发力，多为震荡横盘噪音，极易假突破，不建议做突破挂单。',
          'color': const Color(0xFFD97706),
        };
      } else if (pips <= 250) {
        return {
          'status': '🟢 黄金标准舒适区 (150 ~ 250 Pips / \$15~\$25)',
          'desc': '完美标准日线吞没！动能充沛，突破法与 50% 回撤法均可完美执行！',
          'color': const Color(0xFF16A34A),
        };
      } else if (pips <= 350) {
        return {
          'status': '🔵 黄金偏大蜡烛 (250 ~ 350 Pips / \$25~\$35)',
          'desc': '突破止损偏大，严禁追突破挂单！必须用 Fib 50% 回踩折半入场！',
          'color': const Color(0xFF2563EB),
        };
      } else {
        return {
          'status': '🛑 黄金极端力竭蜡烛 (> 350 Pips / > \$35)',
          'desc': '情绪过热暴冲！次日极易深度反抽或扫损，系统强烈建议直接放弃！',
          'color': const Color(0xFFDC2626),
        };
      }
    }
    if (pips < 50) {
      return {
        'status': '🟡 比较短的蜡烛 (< 50 Pips)',
        'desc': '日内波动偏小。此时 50% 回调位太近易被噪音扫损，建议仅采用【突破法挂单】。',
        'color': const Color(0xFFD97706),
      };
    } else if (pips <= 80) {
      return {
        'status': '🟢 标准外汇波动 (50 ~ 80 Pips)',
        'desc': '完美舒适区！波动充足且方向明确，突破法与 50% 回调法均可完美执行！',
        'color': const Color(0xFF16A34A),
      };
    } else if (pips <= 100) {
      return {
        'status': '🔵 偏大蜡烛 (80 ~ 100 Pips)',
        'desc': '突破止损偏大。强烈建议使用【50% 回调法】，将入场风险折半压缩至 40~50 Pips！',
        'color': const Color(0xFF2563EB),
      };
    } else {
      return {
        'status': '🛑 极端力竭蜡烛 (> 100 Pips)',
        'desc': '情绪力竭暴冲！盈亏比极差，系统强烈建议直接放弃交易，坚决不介入！',
        'color': const Color(0xFFDC2626),
      };
    }
  }

  void _showStandardLotsTable() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final tableData = [
          {'bal': 500, 'rm': 2250, 'risk': 10, 's50': '0.02 手 (0.01+0.01)', 's80': '🚫 不可用 (超标)'},
          {'bal': 800, 'rm': 3600, 'risk': 16, 's50': '0.02 手 (0.01+0.01)', 's80': '0.02 手 (0.01+0.01)'},
          {'bal': 1000, 'rm': 4500, 'risk': 20, 's50': '0.04 手 (0.02+0.02)', 's80': '0.02 手 (0.01+0.01)'},
          {'bal': 1500, 'rm': 6750, 'risk': 30, 's50': '0.06 手 (0.03+0.03)', 's80': '0.02 手 (0.01+0.01)'},
          {'bal': 1600, 'rm': 7200, 'risk': 32, 's50': '0.06 手 (0.03+0.03)', 's80': '0.04 手 (0.02+0.02)'},
          {'bal': 2000, 'rm': 9000, 'risk': 40, 's50': '0.08 手 (0.04+0.04)', 's80': '0.04 手 (0.02+0.02)'},
          {'bal': 2400, 'rm': 10800, 'risk': 48, 's50': '0.08 手 (0.04+0.04)', 's80': '0.06 手 (0.03+0.03)'},
          {'bal': 3000, 'rm': 13500, 'risk': 60, 's50': '0.12 手 (0.06+0.06)', 's80': '0.06 手 (0.03+0.03)'},
          {'bal': 3200, 'rm': 14400, 'risk': 64, 's50': '0.12 手 (0.06+0.06)', 's80': '0.08 手 (0.04+0.04)'},
        ];

        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🧮 500 - 3,200 美元双轨最大手数对照表', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('点击任意行可直接快速载入该资金配置 (总手数恒为偶数，保证 2 x 1% 完美平分)：', style: TextStyle(fontSize: 11, color: Colors.grey)),
              const Divider(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: tableData.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (c, idx) {
                    final row = tableData[idx];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          balance = (row['bal'] as int).toDouble();
                          _balCtrl.text = balance.toStringAsFixed(0);
                        });
                        _saveParam('calc_balance', balance);
                        Navigator.pop(ctx);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('\$${row['bal']} (RM ${row['rm']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('2% 红线: \$${row['risk']}', style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('50pips: ${row['s50']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                Text('80pips: ${row['s80']}', style: TextStyle(fontSize: 11, color: (row['s80'] as String).contains('不可用') ? Colors.red : Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override

  Widget _buildTierButton(String title, String subtitle, String pairs, {double? width}) {
    bool active = activePair == title;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          activePair = title;
          isGoldMode = pairs.contains('XAUUSD');
          _saveParam('calc_active_pair', title);
          _saveParam('calc_is_gold', isGoldMode);
        });
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFEF3C7) : Colors.transparent,
          border: Border.all(color: active ? const Color(0xFFF59E0B) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: active ? const Color(0xFFD97706) : Colors.blueGrey)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 9, color: active ? const Color(0xFFD97706).withOpacity(0.8) : Colors.grey)),
            const SizedBox(height: 8),
            Text(pairs.replaceAll('\n', ' '), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active ? const Color(0xFFD97706) : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    double riskAmt = balance * (riskPct / 100);
    double riskAmtRM = riskAmt * rate;
    double rawLots = (slPips > 0) ? riskAmt / (slPips * (isMicroMode ? 0.1 : 10)) : 0;
    int rawMicro = (rawLots * 100).floor();
    if (rawMicro % 2 != 0) rawMicro -= 1;
    double finalLots = rawMicro / 100;
    bool isInsufficient = isMicroMode ? (finalLots < 0.02 * 100) : (finalLots < 0.02);

    final fightIq = _getFightIqDiagnosis(slPips);
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    final leftChildren = <Widget>[
        // Account Mode (XM Standard vs Micro)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => isMicroMode = false);
                    _saveParam('calc_is_micro', false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !isMicroMode ? const Color(0xFF2563EB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('🏢 XM 标准/Ultra Low (1手=100k)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: !isMicroMode ? Colors.white : Colors.grey)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => isMicroMode = true);
                    _saveParam('calc_is_micro', true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isMicroMode ? const Color(0xFF059669) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('🔬 XM Micro 微型 (1手=1k)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isMicroMode ? Colors.white : Colors.grey)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text('点值梯队联动 (自动载入 ATR 止损基准): ', style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text('当前: ' + activePair, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTierButton('🥇 第一梯队', '绝对恒定 (\$0.10)', 'EURUSD, GBPUSD, AUDUSD, NZDUSD', width: null)),
                    Expanded(child: _buildTierButton('🛡️ 第二梯队', '超级防御 (~\$0.06)', 'USDJPY, EURJPY, GBPJPY, AUDJPY, CADJPY, AUDNZD', width: null)),
                    Expanded(child: _buildTierButton('📉 第三梯队', '安全打折 (~\$0.07)', 'USDCAD, AUDCAD, EURCAD', width: null)),
                    Expanded(child: _buildTierButton('⚠️ 第四梯队', '点值溢价 (警惕微超)', 'USDCHF, EURGBP', width: null)),
                    Expanded(child: _buildTierButton('👑 独立品种', '美黄金 (0.1\$ = 1Pip)', 'XAUUSD', width: null)),
                  ],
                )
              : Wrap(
                  children: [
                    _buildTierButton('🥇 第一梯队', '绝对恒定 (\$0.10)', 'EURUSD, GBPUSD, AUDUSD, NZDUSD', width: 250),
                    _buildTierButton('🛡️ 第二梯队', '超级防御 (~\$0.06)', 'USDJPY, EURJPY, GBPJPY, AUDJPY, CADJPY, AUDNZD', width: 250),
                    _buildTierButton('📉 第三梯队', '安全打折 (~\$0.07)', 'USDCAD, AUDCAD, EURCAD', width: 250),
                    _buildTierButton('⚠️ 第四梯队', '点值溢价 (警惕微超)', 'USDCHF, EURGBP', width: 250),
                    _buildTierButton('👑 独立品种', '美黄金 (0.1\$ = 1Pip)', 'XAUUSD', width: 250),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(isGoldMode ? '黄金点值: 0.1\$ 波动 = 1 Pip' : '外汇点值: 0.01手 ≈ \$0.10/Pip', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            InkWell(
              onTap: _showStandardLotsTable,
              child: const Text('📊 打开手数对照表', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInput('账户本金 (USD)', _balCtrl, (v) {
                    setState(() => balance = double.tryParse(v) ?? 0);
                    _saveParam('calc_balance', balance);
                  }),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Text('≈ RM ${(balance * rate).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('汇率 (MYR)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      GestureDetector(
                        onTap: isFetchingRate ? null : _fetchLiveExchangeRate,
                        child: Text(isFetchingRate ? '刷新中..' : '🔄 实时', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _rateCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (v) {
                      setState(() => rate = double.tryParse(v) ?? 4.5);
                      _saveParam('calc_rate', rate);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: _buildInput(isGoldMode ? '形态止损 (0.1\$ = 1 Pip)' : '形态止损空间 (Pips)', _slCtrl, (v) {
                setState(() => slPips = double.tryParse(v) ?? 0);
                _saveParam('calc_sl', slPips);
              }),
            ),
          ],
        ),

        // 动态变速箱风控档位
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('变速箱风控红线 (Risk %)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text(balance <= 2000 ? '🔥 激进翻倍档 (\$500~\$2k)' : '🛡️ 稳健巡航档 (>\$2k)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: balance <= 2000 ? const Color(0xFFD97706) : const Color(0xFF2563EB))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [2, 3, 4].map((r) {
            bool selected = riskPct == r;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => riskPct = r);
                    _saveParam('calc_risk', r);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? (isGoldMode ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF)) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? (isGoldMode ? const Color(0xFFD97706) : const Color(0xFF3B82F6)) : Theme.of(context).dividerColor.withOpacity(0.4)),
                    ),
                    child: Center(
                      child: Text('$r% ${r == 2 ? "(巡航)" : r == 3 ? "(激进)" : "(极限)"}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: selected ? (isGoldMode ? const Color(0xFF92400E) : const Color(0xFF1E40AF)) : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),

        ];

    final rightChildren = <Widget>[
        // XM 账户规格与选型指南 (点击弹出)
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: const [
                    Icon(Icons.account_balance, size: 18, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Expanded(child: Text('XM 账户规格与选型指南', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('源自《XM 券商大马区硬核评测指南》：选对账户类型是小资金交易员生存的第一道风控防线！', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF), height: 1.4)),
                      ),
                      const SizedBox(height: 14),
                      const Text('1. Standard 标准账户 (适合资金 >= \$500)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                      const SizedBox(height: 6),
                      const Text('• 1 手 = 100,000 合约，点值 ≈ \$10/pip，最小交易 0.01 手 (\$0.10/pip)。\n• 双轨分仓底线：必须开出 0.02 手 (0.01 + 0.01)。若本金仅 \$100，开 0.02 手止损 50p 风险高达 \$10 (10%)，直接违反 2% 铁律！', style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.5)),
                      const SizedBox(height: 14),
                      const Text('2. Micro 微型账户 (适合资金 \$50 ~ \$300 · 强烈推荐)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                      const SizedBox(height: 6),
                      const Text('• 1 手 = 1,000 合约 (标准手的 1/100)，点值 ≈ \$0.10/pip，最小交易 0.01 micro手。\n• 破局解法：\$100 本金 2% 风险仅 \$2。在微型账户中可精准开出 0.40 Micro手，完美拆成 0.20 + 0.20 手执行 2x1% 双轨！', style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.5)),
                      const SizedBox(height: 14),
                      const Text('3. 杠杆 (1:888 / 1:1000) 认知真相', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                      const SizedBox(height: 6),
                      const Text('• 杠杆只决定保证金占用，不决定交易盈亏！盈亏只由【手数】与【止损点数】决定。\n• 坚守本终端计算的严格双轨手数，高杠杆不仅不会爆仓，反能大幅降低保证金被占用的压力。', style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.5)),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('知晓铁律', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
            ),
            child: Row(
              children: const [
                Icon(Icons.account_balance, size: 14, color: Color(0xFF2563EB)),
                SizedBox(width: 6),
                Expanded(child: Text('XM 账户规格与选型指南', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),


        // Fight IQ 物理级蜡烛诊断横幅
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (fightIq['color'] as Color).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (fightIq['color'] as Color).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fightIq['status'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fightIq['color'] as Color)),
              const SizedBox(height: 2),
              Text(fightIq['desc'] as String, style: TextStyle(fontSize: 11, color: (fightIq['color'] as Color).withOpacity(0.85), height: 1.3)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 结果卡片
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('本次亏损上限 (风险金额)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 6),
                              FittedBox(fit: BoxFit.scaleDown, child: Text('\$''${riskAmt.toStringAsFixed(2)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900))),
                              Text('≈ RM ${riskAmtRM.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 80, color: Theme.of(context).dividerColor.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 10)),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('执行双轨总手数 (恒为偶数)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 6),
                              if (isInsufficient) ...[
                                const Text('🚫 资金不足以挂双单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                                const SizedBox(height: 4),
                                Text('理论需: ${rawLots.toStringAsFixed(3)} 手\n(强烈建议转 Micro 微型)', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.red)),
                              ] else ...[
                                FittedBox(fit: BoxFit.scaleDown, child: Text('${finalLots.toStringAsFixed(2)} 手', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: isGoldMode ? const Color(0xFFD97706) : const Color(0xFF2563EB)))),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                  ),
                                  child: Text('实操双单：A单 ${(finalLots / 2).toStringAsFixed(2)}手 ➕ B单 ${(finalLots / 2).toStringAsFixed(2)}手', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Text('本次亏损上限 (风险金额)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('\$''${riskAmt.toStringAsFixed(2)}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                        Text('≈ RM ${riskAmtRM.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                        const Divider(height: 30),
                        const Text('执行双轨总手数 (恒为偶数)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 4),
                        if (isInsufficient) ...[
                          const Text('🚫 资金不足以挂双单', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                          const SizedBox(height: 4),
                          Text('理论需: ${rawLots.toStringAsFixed(3)} 手 (强烈建议转 Micro 微型账户执行)', style: const TextStyle(fontSize: 12, color: Colors.red)),
                        ] else ...[
                          Text('${finalLots.toStringAsFixed(2)} 手', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: isGoldMode ? const Color(0xFFD97706) : const Color(0xFF2563EB))),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: Text('实操双单：A单 ${(finalLots / 2).toStringAsFixed(2)} 手 ➕ B单 ${(finalLots / 2).toStringAsFixed(2)} 手', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ],
                    ),
                  ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 500-3200 标准速查表卡片 (来自 Notion 核心战法)
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: false,
              leading: const Icon(Icons.table_chart_rounded, color: Color(0xFF2563EB), size: 20),
              title: const Text('📖 资金阶梯标准速查表 (50 Pips 止损基准)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const Text('基准条件：止损 50 Pips，单笔风险 2%，双轨 1%+1% 分仓', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                Table(
                  border: TableBorder.all(color: Theme.of(context).dividerColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(1.1),
                    2: FlexColumnWidth(1.6),
                    3: FlexColumnWidth(1.6),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : const Color(0xFFF1F5F9)),
                      children: const [
                        Padding(padding: EdgeInsets.all(6), child: Text('本金', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Padding(padding: EdgeInsets.all(6), child: Text('2%风险', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Padding(padding: EdgeInsets.all(6), child: Text('标准双单', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Padding(padding: EdgeInsets.all(6), child: Text('微型双单(Micro)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      ],
                    ),
                    _buildTableRow('\$500', '\$10', '0.01 + 0.01', '0.10 + 0.10 (优)'),
                    _buildTableRow('\$1,000', '\$20', '0.02 + 0.02', '0.20 + 0.20'),
                    _buildTableRow('\$1,500', '\$30', '0.03 + 0.03', '0.30 + 0.30'),
                    _buildTableRow('\$2,000', '\$40', '0.04 + 0.04', '0.40 + 0.40'),
                    _buildTableRow('\$3,200', '\$64', '0.06 + 0.06', '0.64 + 0.64'),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('💡 提示：\$500 资金在标准账户下无法拆出 0.005 手，因此强烈建议 \$500 资金开设 Micro 微型账户以执行标准 1%+1% 分仓。', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ),

    ];

    if (isDesktop) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: leftChildren,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: rightChildren,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return ListView(
        padding: const EdgeInsets.all(10),
        children: [...leftChildren, ...rightChildren],
      );
    }
  }

  TableRow _buildTableRow(String col1, String col2, String col3, String col4) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(6), child: Text(col1, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
        Padding(padding: const EdgeInsets.all(6), child: Text(col2, style: const TextStyle(fontSize: 10, color: Colors.red), textAlign: TextAlign.center)),
        Padding(padding: const EdgeInsets.all(6), child: Text(col3, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)), textAlign: TextAlign.center)),
        Padding(padding: const EdgeInsets.all(6), child: Text(col4, style: const TextStyle(fontSize: 10, color: Color(0xFF059669)), textAlign: TextAlign.center)),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// 3. 自动止盈报价生成器（重磅新增：黄金口袋 Fib 50%~61.8% 狙击入场模式）
// -------------------------------------------------------------


  class TpCalculatorPage extends StatefulWidget {
  const TpCalculatorPage({super.key});

  @override
  State<TpCalculatorPage> createState() => _TpCalculatorPageState();
}

class _TpCalculatorPageState extends State<TpCalculatorPage> {
  final TextEditingController _highCtrl = TextEditingController(text: '1.08800');
  final TextEditingController _lowCtrl = TextEditingController(text: '1.08000');

  double? highPrice = 1.08800;
  double? lowPrice = 1.08000;
  bool isLong = true;
  int entryMode = 1;
  bool isDualTrack = true; // true=双轨1%+1%, false=单轨2%
  String selectedTimeframe = 'H4';
  bool isGold = false;
  String selectedPair = 'EURUSD';
  String _categoryFilter = 'all'; // 'all', 'core', 'minor', 'observed'

  List<WatchlistPair> get displayedPairs {
    if (_categoryFilter == 'core') {
      return kWatchlistPairs.where((p) => p.isCore).toList();
    } else if (_categoryFilter == 'minor') {
      return kWatchlistPairs.where((p) => p.isMinor).toList();
    } else if (_categoryFilter == 'observed') {
      return kWatchlistPairs.where((p) => p.category == 'observed').toList();
    }
    return kWatchlistPairs;
  }

  void _selectWatchlistPair(WatchlistPair pair) {
    HapticFeedback.lightImpact();
    setState(() {
      selectedPair = pair.symbol;
      isGold = pair.isGold;
      highPrice = double.tryParse(pair.defaultHigh);
      lowPrice = double.tryParse(pair.defaultLow);
      _highCtrl.text = pair.defaultHigh;
      _lowCtrl.text = pair.defaultLow;
    });
    _saveState('tp_pair', pair.symbol);
    _saveState('tp_high', pair.defaultHigh);
    _saveState('tp_low', pair.defaultLow);
  }

  // T.S.C.F. 四维共振评估 (Notion 绝杀核心法则)
  bool _tscfTrend = true; // T (Trend 趋势)：日线大趋势明确 (HH/HL 或 LL/LH)
  bool _tscfStructure = true; // S (Structure 结构)：踩在折线图日线关键水平S/R海绵蹦床
  bool _tscfCandle = true; // C (Candlestick 形态)：D1收盘确认饱满吞没/Pin Bar拒收
  bool _tscfFib = true; // F (Fibonacci 黄金口袋)：深幅回撤踩入 50% ~ 61.8% 绝杀口袋

  int get _tscfScore => (_tscfTrend ? 1 : 0) + (_tscfStructure ? 1 : 0) + (_tscfCandle ? 1 : 0) + (_tscfFib ? 1 : 0);

  Map<String, dynamic> get _tscfRating {
    final score = _tscfScore;
    if (score == 4) {
      return {
        'stars': '★★★★',
        'title': '绝杀天王山 (4星共振)',
        'color': const Color(0xFF059669),
        'bg': const Color(0xFFF0FDF4),
        'desc': '💎 四重共振全亮！机构同频绝杀位，胜率极高，放行 2% 双轨满额执行！',
      };
    } else if (score == 3) {
      return {
        'stars': '★★★☆',
        'title': '高胜率波段 (3星共振)',
        'color': const Color(0xFF2563EB),
        'bg': const Color(0xFFEFF6FF),
        'desc': '🛡️ 三重共振达标：标准高质量形态，严格执行 1:1 推保本！',
      };
    } else {
      return {
        'stars': '★★☆☆',
        'title': '悬空信号 / 噪音陷阱',
        'color': const Color(0xFFDC2626),
        'bg': const Color(0xFFFEF2F2),
        'desc': '🛑 高危预警：悬在半空中的未共振信号！大概率假突破或接飞刀，系统强烈建议放弃！',
      };
    }
  }

  double userBalance = 1000;
  int userRisk = 2;

  // 5 项开单铁律自检清单
  bool _checkClosed = false; // 1. 蜡烛已完整收盘
  bool _checkFightIq = false; // 2. 实体动能健康 (50~100 Pips)
  bool _checkBuffer = false; // 3. 双缓冲保护就位 (+10pips / +9pips)
  bool _checkTwinLot = false; // 4. 双轨 1%+1% 分仓 (总风险 2%)
  bool _checkMindset = false; // 5. 坚决 Set & Forget (到 1:1 必保本)

  bool get _allChecked => _checkClosed && _checkFightIq && _checkBuffer && _checkTwinLot && _checkMindset;

  void _toggleAllChecks() {
    HapticFeedback.mediumImpact();
    setState(() {
      bool target = !_allChecked;
      _checkClosed = target;
      _checkFightIq = target;
      _checkBuffer = target;
      _checkTwinLot = target;
      _checkMindset = target;
    });
  }

  List<Map<String, dynamic>> _savedPlans = [];


  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedPair = prefs.getString('tp_pair') ?? 'EURUSD';
      isLong = prefs.getBool('tp_is_long') ?? true;
      entryMode = prefs.getInt('tp_mode') ?? 1;
      selectedTimeframe = prefs.getString('tp_timeframe') ?? 'H4';
      isDualTrack = prefs.getBool('tp_dual_track') ?? true;
      _highCtrl.text = prefs.getString('tp_high') ?? '1.08800';
      _lowCtrl.text = prefs.getString('tp_low') ?? '1.08000';
      highPrice = double.tryParse(_highCtrl.text);
      lowPrice = double.tryParse(_lowCtrl.text);
    });
  }

  Future<void> _saveState(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) await prefs.setString(key, value);
    if (value is bool) await prefs.setBool(key, value);
    if (value is int) await prefs.setInt(key, value);
    if (value is double) await prefs.setDouble(key, value);
  }
  @override
  void initState() {
    super.initState();
    _loadState();
    _loadBalanceAndRisk();
    _loadSavedPlans();
  }

  Future<void> _loadBalanceAndRisk() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        userBalance = prefs.getDouble('calc_balance') ?? 1000;
        userRisk = prefs.getInt('calc_risk') ?? 2;
      });
    }
  }

  Future<void> _loadSavedPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('saved_trade_plans');
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List list = json.decode(jsonStr);
        if (mounted) {
          setState(() {
            _savedPlans = list.map((e) => Map<String, dynamic>.from(e)).toList();
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _savePlansToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_trade_plans', json.encode(_savedPlans));
  }

  void _addCurrentPlan({
    required int decimals,
    required double currentRiskPips,
    required double riskAmountUsd,
    required double tradeLot,
    required double fib50,
    required double fibSl,
    required double fib50Risk,
    required double breakoutEntry,
    required double breakoutSl,
    required double breakoutRisk,
    required double be40,
    required double beBody,
  }) {
    HapticFeedback.mediumImpact();
    final entry = (entryMode == 1) ? fib50.toStringAsFixed(decimals) : breakoutEntry.toStringAsFixed(decimals);
    final sl = (entryMode == 1) ? fibSl.toStringAsFixed(decimals) : breakoutSl.toStringAsFixed(decimals);
    final tp1 = (entryMode == 1)
        ? (isLong ? fib50 + fib50Risk : fib50 - fib50Risk).toStringAsFixed(decimals)
        : (isLong ? breakoutEntry + breakoutRisk : breakoutEntry - breakoutRisk).toStringAsFixed(decimals);
    final tp2 = (entryMode == 1)
        ? (isLong ? fib50 + fib50Risk * 2 : fib50 - fib50Risk * 2).toStringAsFixed(decimals)
        : (isLong ? breakoutEntry + breakoutRisk * 2 : breakoutEntry - breakoutRisk * 2).toStringAsFixed(decimals);

    final now = DateTime.now();
    final timeStr = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final pairInfo = getWatchlistPair(selectedPair);
    final newPlan = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'pair': selectedPair,
      'pairChinese': pairInfo.chineseName,
      'category': pairInfo.category,
      'categoryLabel': pairInfo.categoryLabel,
      'dir': isLong ? 'BUY' : 'SELL',
      'mode': (entryMode == 1) ? '黄金口袋 50%' : (entryMode == 0 ? '常规突破' : '极值突破'),
      'entry': entry,
      'sl': sl,
      'tp1': tp1,
      'tp2': tp2,
      'be40': be40.toStringAsFixed(decimals),
      'beBody': beBody.toStringAsFixed(decimals),
      'tscfScore': _tscfScore,
      'tscfStars': _tscfRating['stars'],
      'tscfTitle': _tscfRating['title'],
      'pips': currentRiskPips.toStringAsFixed(1),
      'lot': tradeLot.toStringAsFixed(2),
      'isDual': isDualTrack,
      'riskUsd': riskAmountUsd.toStringAsFixed(2),
      'time': timeStr,
      'status': '⏳ 挂单中',
      'verified': _allChecked,
    };

    setState(() {
      _savedPlans.insert(0, newPlan);
    });
    _savePlansToStorage();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF059669),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('已存入今日战术计划簿 ($selectedPair ${isLong ? "BUY" : "SELL"})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _updatePlanStatus(int index, String newStatus) {
    HapticFeedback.lightImpact();
    setState(() {
      _savedPlans[index]['status'] = newStatus;
    });
    _savePlansToStorage();
  }

  void _deletePlan(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _savedPlans.removeAt(index);
    });
    _savePlansToStorage();
  }

  void _clearAllPlans() {
    HapticFeedback.mediumImpact();
    setState(() {
      _savedPlans.clear();
    });
    _savePlansToStorage();
  }

  void _exportJournalToNotionReport() {
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final total = _savedPlans.length;
    final tpCount = _savedPlans.where((e) => e['status'] == '💰 全部止盈').length;
    final beCount = _savedPlans.where((e) => e['status'] == '🎯 1:1已推保本' || e['status'] == '🛡️ 保本离场').length;
    final slCount = _savedPlans.where((e) => e['status'] == '❌ 已止损').length;
    final pendingCount = _savedPlans.where((e) => e['status'] == '⏳ 挂单中').length;
    final closed = tpCount + beCount + slCount;
    final winRate = closed > 0 ? (((tpCount + beCount) / closed) * 100).toStringAsFixed(0) : '-';

    final buffer = StringBuffer();
    buffer.writeln('# 📅 DT · 吞没战法实战挂单与复盘日报 ($dateStr)');
    buffer.writeln();
    buffer.writeln('## 📊 今日实战统计');
    buffer.writeln('- **总挂单数**：$total 笔 | **待触发挂单**：$pendingCount 笔');
    buffer.writeln('- **全部止盈 (Full TP)**：$tpCount 笔 | **1:1推保本/保本离场**：$beCount 笔 | **执行止损**：$slCount 笔');
    buffer.writeln('- **已结算胜率**：$winRate%');
    buffer.writeln();
    buffer.writeln('## 📝 今日详细挂单流水');
    buffer.writeln('| 序号 | 品种代码 | 品种分级 | 方向 | 入场价 | 止损价 (点数) | 1:1保本TP | 40p保本位 | 双轨手数 | 实战状态 |');
    buffer.writeln('| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |');

    for (int i = 0; i < _savedPlans.length; i++) {
      final p = _savedPlans[i];
      final pair = p['pair'] ?? '';
      final pairChinese = p['pairChinese'] ?? '';
      final cat = p['categoryLabel'] ?? '';
      final dir = p['dir'] ?? '';
      final entry = p['entry'] ?? '';
      final sl = p['sl'] ?? '';
      final pips = p['pips'] ?? '';
      final tp1 = p['tp1'] ?? '';
      final be40Val = p['be40'] ?? '-';
      final lot = p['lot'] ?? '';
      final st = p['status'] ?? '';
      buffer.writeln('| ${i + 1} | $pair ($pairChinese) | $cat | $dir | $entry | $sl (${pips}p) | $tp1 | $be40Val | $lot + $lot 手 | $st |');
    }

    buffer.writeln();
    buffer.writeln('## 🧠 交易员心法复盘 (Timon Weller 铁律)');
    buffer.writeln('- [x] 绝不在未收盘前抢跑，坚持日线收盘 (Daily Close) 确认');
    buffer.writeln('- [x] 严格执行 2x1% 双轨分仓，单次总风险严控在 2% 资金红线内');
    buffer.writeln('- [x] 触及 1:1 立即落袋为安并推保本，Trade 2 奔跑单死拿直到大级别反向吞没');
    buffer.writeln('- [x] 坚决执行 Set & Forget，每日 10 分钟看盘，不因盘中波动乱操作');

    copyToClipboard(context, buffer.toString().trim(), 'Notion 复盘日报');
  }

  Widget _buildStatCol(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 1),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTscfChip(String title, String tooltip, bool selected, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(title, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      selected: selected,
      tooltip: tooltip,
      selectedColor: const Color(0xFF2563EB).withOpacity(0.18),
      checkmarkColor: const Color(0xFF2563EB),
      onSelected: (v) {
        HapticFeedback.lightImpact();
        onChanged(v);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int decimals = isGold ? 2 : ((highPrice ?? 0) > 10 ? 3 : 5);
    double pipMultiplier = isGold ? 10 : ((highPrice ?? 0) > 10 ? 100 : 10000);

    bool hasData = (highPrice != null && lowPrice != null && highPrice! > lowPrice!);
    double range = 0;

    // 10 pips 假突破缓冲 & 9 pips 止损缓冲
    double pEntry = selectedTimeframe == 'D1' ? 10.0 : 3.0;
    if (entryMode == 2) pEntry = 0;
    double bufferEntry = pEntry / pipMultiplier;
    double pSl = selectedTimeframe == 'D1' ? 9.0 : 3.0;
    double bufferSl = pSl / pipMultiplier;

    double breakoutEntry = 0;
    double breakoutSl = 0;
    double breakoutRisk = 0;
    double fib50 = 0;
    double fib618 = 0;
    double fibSl = 0;
    double fib50Risk = 0;
    double fib618Risk = 0;
    double be40 = 0;
    double beBody = 0;

    double currentRiskPips = 0;
    double riskAmountUsd = 0;
    double tradeLot = 0.01;

    if (hasData) {
      range = highPrice! - lowPrice!;
      // 突破模式计算
      breakoutEntry = isLong ? highPrice! + bufferEntry : lowPrice! - bufferEntry;
      breakoutSl = isLong ? lowPrice! - bufferSl : highPrice! + bufferSl;
      breakoutRisk = (breakoutEntry - breakoutSl).abs();

      // 黄金口袋 Fib 50% & 61.8% 狙击入场位计算
      fib50 = isLong ? highPrice! - range * 0.50 : lowPrice! + range * 0.50;
      fib618 = isLong ? highPrice! - range * 0.618 : lowPrice! + range * 0.618;
      fibSl = isLong ? lowPrice! - bufferSl : highPrice! + bufferSl;
      fib50Risk = (fib50 - fibSl).abs();
      fib618Risk = (fib618 - fibSl).abs();

      currentRiskPips = (entryMode == 1) ? (fib50Risk * pipMultiplier) : (breakoutRisk * pipMultiplier);
      riskAmountUsd = userBalance * (userRisk / 100.0);
      double rawTotalLots = currentRiskPips > 0 ? (riskAmountUsd / (currentRiskPips * 10.0)) : 0.0;
      tradeLot = isDualTrack ? (rawTotalLots / 2.0) : rawTotalLots;
      if (tradeLot < 0.01 && tradeLot > 0) tradeLot = 0.01;

      // 双重推保本点位 (Notion Part 3: 40 pips 规则 & 实体等长规则)
      double entryForBe = (entryMode == 1) ? fib50 : breakoutEntry;
      be40 = isLong ? entryForBe + (40 / pipMultiplier) : entryForBe - (40 / pipMultiplier);
      beBody = isLong ? entryForBe + range : entryForBe - range;
    }

    final currentPairInfo = getWatchlistPair(selectedPair);

    final leftChildren = <Widget>[
        // 模式切换：突破挂单 vs 黄金口袋 Fib vs 极值突破
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() { entryMode = 1; _saveState('tp_mode', 1); }); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: entryMode == 1 ? const Color(0xFFD97706) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('🎯 黄金口袋', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: entryMode == 1 ? Colors.white : Colors.grey))),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() { entryMode = 0; _saveState('tp_mode', 0); }); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: entryMode == 0 ? const Color(0xFF2563EB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('🚀 常规突破', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: entryMode == 0 ? Colors.white : Colors.grey))),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() { entryMode = 2; _saveState('tp_mode', 2); }); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: entryMode == 2 ? const Color(0xFF9333EA) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('⚡ 极值突破', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: entryMode == 2 ? Colors.white : Colors.grey))),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Timeframe Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('执行级别 (Timeframe):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ToggleButtons(
              constraints: const BoxConstraints(minHeight: 40, minWidth: 50),
              borderRadius: BorderRadius.circular(8),
              isSelected: ['D1', 'H4', 'H1', 'M15'].map((t) => t == selectedTimeframe).toList(),
              onPressed: (idx) {
                HapticFeedback.selectionClick();
                setState(() { selectedTimeframe = ['D1', 'H4', 'H1', 'M15'][idx]; _saveState('tp_timeframe', selectedTimeframe); });
              },
              children: const [
                Text('D1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text('H4', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text('H1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text('M15', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ToggleButtons(
              isSelected: [isLong, !isLong],
              borderRadius: BorderRadius.circular(8),
              constraints: const BoxConstraints(minWidth: 65, minHeight: 32),
              selectedColor: Colors.white,
              fillColor: isLong ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              onPressed: (idx) => setState(() => isLong = idx == 0),
              children: const [
                Text('做多 (BUY)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('做空 (SELL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => showWatchlistAtlasDialog(context, onSelect: (p) => _selectWatchlistPair(p)),
              icon: const Icon(Icons.menu_book_rounded, size: 14, color: Color(0xFF2563EB)),
              label: const Text('16品种图鉴', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            ),
          ],
        ),

        const SizedBox(height: 10),
        // 当前选中品种高阶信息标牌
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: currentPairInfo.isCore
                ? const Color(0xFFFEF3C7).withOpacity(0.45)
                : (currentPairInfo.isGold ? const Color(0xFFFFFBEB) : const Color(0xFFEFF6FF).withOpacity(0.55)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: currentPairInfo.isCore
                  ? const Color(0xFFF59E0B).withOpacity(0.4)
                  : (currentPairInfo.isGold ? const Color(0xFFD97706).withOpacity(0.4) : const Color(0xFF60A5FA).withOpacity(0.4)),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: currentPairInfo.isCore
                      ? const Color(0xFFF59E0B)
                      : (currentPairInfo.isGold ? const Color(0xFFD97706) : const Color(0xFF2563EB)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  currentPairInfo.categoryLabel,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${currentPairInfo.symbol} (${currentPairInfo.chineseName})',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          currentPairInfo.isJpy ? '· 3位报价' : (currentPairInfo.isGold ? '· 2位报价' : '· 5位报价'),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentPairInfo.session,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentPairInfo.feature,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),
        // 核心与次要分类过滤标签
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryFilterChip('all', '全部 (17)'),
              const SizedBox(width: 6),
              _buildCategoryFilterChip('core', '⭐ 核心 (7)'),
              const SizedBox(width: 6),
              _buildCategoryFilterChip('minor', '🔹 次要 (9)'),
              const SizedBox(width: 6),
              _buildCategoryFilterChip('observed', '🥇 黄金 (1)'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 品种自动折行展示 (Wrap)
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: displayedPairs.map((p) => _buildPairChipV2(p)).toList(),
        ),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _highCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '最高点 (Candle High)',
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) { setState(() => highPrice = double.tryParse(v)); _saveState('tp_high', v); },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _lowCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '最低点 (Candle Low)',
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) { setState(() => lowPrice = double.tryParse(v)); _saveState('tp_low', v); },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

    ];

    final rightChildren = <Widget>[
        if (hasData) ...[
          if (entryMode == 1) ...[
            // 黄金口袋 Fib 5618 狙击结果
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFFDE68A)),
              ),
              color: const Color(0xFFFFFDF5),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🎯 黄金口袋 (Fib 50%~61.8% 绝杀狙击位)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                          child: Text('形态总长: ${(range * pipMultiplier).toStringAsFixed(1)} Pips', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildPriceCard(context, 'Fib 50% 狙击入场', fib50.toStringAsFixed(decimals), '止损仅 ${(fib50Risk * pipMultiplier).toStringAsFixed(1)} Pips (折半)', const Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        _buildPriceCard(context, 'Fib 61.8% 绝杀入场', fib618.toStringAsFixed(decimals), '止损仅 ${(fib618Risk * pipMultiplier).toStringAsFixed(1)} Pips', const Color(0xFFB45309)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildPriceCard(context, '硬性止损位 (极值外9pips)', fibSl.toStringAsFixed(decimals), '无论在哪个回踩入场，统一此止损', const Color(0xFFDC2626)),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text('💎 稳健与奔跑双目标点位 (以 50% 入场测算):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriceCard(context, 'Trade 1 (1:1 落袋)', (isLong ? fib50 + fib50Risk : fib50 - fib50Risk).toStringAsFixed(decimals), '到此立刻平仓，推保本', const Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        _buildPriceCard(context, 'Trade 2 (1:2 波段)', (isLong ? fib50 + fib50Risk * 2 : fib50 - fib50Risk * 2).toStringAsFixed(decimals), '长线奔跑目标 1', const Color(0xFF059669)),
                        const SizedBox(width: 8),
                        _buildPriceCard(context, 'Trade 2 (1:3 暴利)', (isLong ? fib50 + fib50Risk * 3 : fib50 - fib50Risk * 3).toStringAsFixed(decimals), '日线趋势波段', const Color(0xFF15803D)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // 常规突破入场结果
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2))),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🚀 突破挂单入场 (含10pips假突破缓冲)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                        Text('止损空间: ${(breakoutRisk * pipMultiplier).toStringAsFixed(1)} Pips', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildPriceCard(context, '挂单入场价 (Buy/Sell Stop)', breakoutEntry.toStringAsFixed(decimals), '极值外+10 Pips缓冲防假破', const Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        _buildPriceCard(context, '止损价格 (SL)', breakoutSl.toStringAsFixed(decimals), '极值外+9 Pips缓冲', const Color(0xFFDC2626)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        _buildPriceCard(context, 'Trade 1 (1:1 落袋)', (isLong ? breakoutEntry + breakoutRisk : breakoutEntry - breakoutRisk).toStringAsFixed(decimals), '落袋后立即推保本', const Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        _buildPriceCard(context, 'Trade 2 (1:2 跑单)', (isLong ? breakoutEntry + breakoutRisk * 2 : breakoutEntry - breakoutRisk * 2).toStringAsFixed(decimals), '第二结构阻力', const Color(0xFF059669)),
                        const SizedBox(width: 8),
                        _buildPriceCard(context, 'Trade 2 (1:3 奔跑)', (isLong ? breakoutEntry + breakoutRisk * 3 : breakoutEntry - breakoutRisk * 3).toStringAsFixed(decimals), '大趋势锁定', const Color(0xFF15803D)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Center(child: Text('💡 点击任意绿色/蓝色价格卡片，直接复制价格到剪贴板', style: TextStyle(fontSize: 11, color: Colors.grey))),

          const SizedBox(height: 12),
          // 联动双轨推荐手数卡片
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: (entryMode == 1) ? const Color(0xFFFDE68A) : const Color(0xFFBFDBFE)),
            ),
            color: (entryMode == 1) ? const Color(0xFFFFFDF5) : const Color(0xFFF8FAFC),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '💰 ${isDualTrack ? "双轨" : "单轨"}联动推荐手数 (本金 \$${userBalance.toStringAsFixed(0)} · 风控 $userRisk%)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: (entryMode == 1) ? const Color(0xFFB45309) : const Color(0xFF1E40AF)),
                      ),
                      Text('单笔止损: ${currentRiskPips.toStringAsFixed(1)} Pips', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (isDualTrack) ...[
                        Column(
                          children: [
                            const Text('Trade 1 (1:1保本仓)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text('${tradeLot.toStringAsFixed(2)} 手', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
                          ],
                        ),
                        const Text('➕', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Column(
                          children: [
                            const Text('Trade 2 (波段奔跑仓)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text('${tradeLot.toStringAsFixed(2)} 手', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                          ],
                        ),
                      ] else ...[
                        Column(
                          children: [
                            const Text('单轨全仓 (2% 风险)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text('${tradeLot.toStringAsFixed(2)} 手', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
                          ],
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                        child: Text('总风险 \$${riskAmountUsd.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 🛡️ 双重推保本精准测算器 (Notion Part 3 战法心法)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.4)),
            ),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF064E3B).withOpacity(0.18)
                : const Color(0xFFF0FDF4),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 18, color: Color(0xFF059669)),
                          SizedBox(width: 6),
                          Text(
                            '🛡️ 双重推保本精准测算器 (Notion Part 3)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('锁定 0 风险', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '行情到达以下任一触发位后，立即将 Trade 2 止损推至开仓价（保本），开启完全无风险奔跑模式：',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildPriceCard(
                        context,
                        '规则 A：+40 Pips 推保本位',
                        be40.toStringAsFixed(decimals),
                        '触碰即推保本至开仓价',
                        const Color(0xFF059669),
                      ),
                      const SizedBox(width: 8),
                      _buildPriceCard(
                        context,
                        '规则 B：实体等长推保本位',
                        beBody.toStringAsFixed(decimals),
                        '走完 ${(range * pipMultiplier).toStringAsFixed(1)}p 即推保本',
                        const Color(0xFF0D9488),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.directions_run_rounded, size: 14, color: Color(0xFF059669)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '🏃 Runner 离场绝学：Trade 2 绝不手动提前平仓，死拿直到大级别 (D1) 出现反向吞没！',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ⚔️ T.S.C.F. 四维共振评级雷达 (Timon Weller 核心胜率诊断)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: (_tscfRating['color'] as Color).withOpacity(0.4)),
            ),
            color: Theme.of(context).brightness == Brightness.dark
                ? (_tscfRating['color'] as Color).withOpacity(0.15)
                : (_tscfRating['bg'] as Color),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.radar_rounded, size: 18, color: Color(0xFF2563EB)),
                          SizedBox(width: 6),
                          Text(
                            '⚔️ T.S.C.F. 四维共振评级雷达',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (_tscfRating['color'] as Color).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: (_tscfRating['color'] as Color).withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _tscfRating['stars'] as String,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: _tscfRating['color'] as Color),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _tscfRating['title'] as String,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _tscfRating['color'] as Color),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _tscfRating['desc'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildTscfChip(
                        '📈 Trend 顺势',
                        'D1 顺应主趋势，绝不逆势摸顶摸底',
                        _tscfTrend,
                        (v) => setState(() => _tscfTrend = v),
                      ),
                      _buildTscfChip(
                        '🧱 Structure 关键结构',
                        '位于线图支撑/阻力海绵弹射带',
                        _tscfStructure,
                        (v) => setState(() => _tscfStructure = v),
                      ),
                      _buildTscfChip(
                        '🕯️ Candlestick 确认形态',
                        '日线已完整收盘，实体饱满吞没/PinBar',
                        _tscfCandle,
                        (v) => setState(() => _tscfCandle = v),
                      ),
                      _buildTscfChip(
                        '🎯 Fib 黄金口袋',
                        '回踩 50%~61.8% 黄金回撤位',
                        _tscfFib,
                        (v) => setState(() => _tscfFib = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 🛡️ 吞没战法 · 开单前 5 项铁律自检 (Pre-Flight Checklist)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: _allChecked ? const Color(0xFF10B981) : Colors.amber.withOpacity(0.5)),
            ),
            color: _allChecked
                ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF064E3B).withOpacity(0.25) : const Color(0xFFF0FDF4))
                : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF78350F).withOpacity(0.2) : const Color(0xFFFFFBEB)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(_allChecked ? Icons.verified_rounded : Icons.security_rounded, size: 18, color: _allChecked ? const Color(0xFF059669) : const Color(0xFFD97706)),
                          const SizedBox(width: 6),
                          Text(
                            '🛡️ 开单前 5 项风控铁律自检',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _allChecked ? const Color(0xFF059669) : const Color(0xFFB45309)),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                        onPressed: _toggleAllChecks,
                        icon: Icon(_allChecked ? Icons.restart_alt_rounded : Icons.done_all_rounded, size: 15),
                        label: Text(_allChecked ? '重置' : '全选合格', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildCheckItem('🕯️ 1. 收盘确认：D1/H4 实体已明确收线，绝不在未收盘前抢跑', _checkClosed, (v) => setState(() => _checkClosed = v ?? false)),
                  _buildCheckItem(isGold ? '📏 2. 动能健康：极值在 150~250 Pips (\$15~\$25) 黄金区间' : '📏 2. 动能健康：极值在 50~100 Pips 黄金区间，非噪音非衰竭', _checkFightIq, (v) => setState(() => _checkFightIq = v ?? false)),
                  _buildCheckItem(isGold ? '🛡️ 3. 双缓冲保护：入场+10p假破缓冲，止损+20p (\$2) 黄金结构缓冲' : '🛡️ 3. 双缓冲保护：入场+10pips假破缓冲，止损+9pips结构缓冲', _checkBuffer, (v) => setState(() => _checkBuffer = v ?? false)),
                  _buildCheckItem('⚖️ 4. 双轨分仓：严格 1%+1% 挂单，单笔总风险锁定在 2% 资金红线内', _checkTwinLot, (v) => setState(() => _checkTwinLot = v ?? false)),
                  _buildCheckItem('🧠 5. Set & Forget：挂单后绝不手动追单，到 1:1 必须保本平半仓', _checkMindset, (v) => setState(() => _checkMindset = v ?? false)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _allChecked ? const Color(0xFF10B981).withOpacity(0.12) : Colors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _allChecked ? '✅ 铁律自审全部通过！心如止水，执行挂单！' : '⚠️ 战法铁律：请逐项自审确认，坚决杜绝冲动交易。',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _allChecked ? const Color(0xFF047857) : const Color(0xFFB45309)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 双操作按钮：一键复制指令 + 存入战术计划
          Row(
            children: [
              Expanded(
                flex: 7,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: (entryMode == 1) ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _copyFullTradePlan(
                    decimals: decimals,
                    currentRiskPips: currentRiskPips,
                    riskAmountUsd: riskAmountUsd,
                    tradeLot: tradeLot,
                    fib50: fib50,
                    fibSl: fibSl,
                    fib50Risk: fib50Risk,
                    breakoutEntry: breakoutEntry,
                    breakoutSl: breakoutSl,
                    breakoutRisk: breakoutRisk,
                    be40: be40,
                    beBody: beBody,
                  ),
                  icon: const Icon(Icons.copy_all_rounded, size: 17),
                  label: const Text('📋 一键复制指令', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(color: (entryMode == 1) ? const Color(0xFFD97706) : const Color(0xFF2563EB), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _addCurrentPlan(
                    decimals: decimals,
                    currentRiskPips: currentRiskPips,
                    riskAmountUsd: riskAmountUsd,
                    tradeLot: tradeLot,
                    fib50: fib50,
                    fibSl: fibSl,
                    fib50Risk: fib50Risk,
                    breakoutEntry: breakoutEntry,
                    breakoutSl: breakoutSl,
                    breakoutRisk: breakoutRisk,
                    be40: be40,
                    beBody: beBody,
                  ),
                  icon: const Icon(Icons.bookmark_add_rounded, size: 17),
                  label: const Text('📌 存入今日计划', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.touch_app_rounded, size: 40, color: Color(0xFFD97706)),
                  const SizedBox(height: 10),
                  const Text('等待输入蜡烛极值', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    highPrice != null && lowPrice != null && highPrice! <= lowPrice!
                        ? '⚠️ 最高点必须大于最低点，请检查输入数值'
                        : '请输入吞没蜡烛形态的最高价与最低价，系统将自动测算黄金口袋狙击点位或突破挂单报价。',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 18),
        // 📌 今日实战挂单战术簿
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 18, color: Color(0xFF2563EB)),
                        const SizedBox(width: 6),
                        Text('📌 今日挂单战术簿 (${_savedPlans.length} 笔)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (_savedPlans.isNotEmpty)
                      Row(
                        children: [
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            onPressed: _exportJournalToNotionReport,
                            icon: const Icon(Icons.description_outlined, size: 14),
                            label: const Text('📋 导出Notion日报', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 6)),
                            onPressed: _clearAllPlans,
                            child: const Text('清空', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
                        ],
                      ),
                  ],
                ),
                if (_savedPlans.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B).withOpacity(0.6)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCol('总挂单', '${_savedPlans.length}', const Color(0xFF2563EB)),
                        _buildStatCol('挂单中', '${_savedPlans.where((e) => e['status'] == '⏳ 挂单中').length}', const Color(0xFFD97706)),
                        _buildStatCol('1:1保本', '${_savedPlans.where((e) => e['status'] == '🎯 1:1已推保本' || e['status'] == '🛡️ 保本离场').length}', const Color(0xFF059669)),
                        _buildStatCol('全止盈', '${_savedPlans.where((e) => e['status'] == '💰 全部止盈').length}', const Color(0xFF16A34A)),
                        _buildStatCol('止损', '${_savedPlans.where((e) => e['status'] == '❌ 已止损').length}', const Color(0xFFDC2626)),
                        _buildStatCol(
                          '胜率',
                          () {
                            final tp = _savedPlans.where((e) => e['status'] == '💰 全部止盈').length;
                            final be = _savedPlans.where((e) => e['status'] == '🎯 1:1已推保本' || e['status'] == '🛡️ 保本离场').length;
                            final sl = _savedPlans.where((e) => e['status'] == '❌ 已止损').length;
                            final closed = tp + be + sl;
                            return closed > 0 ? '${(((tp + be) / closed) * 100).toStringAsFixed(0)}%' : '-';
                          }(),
                          const Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                if (_savedPlans.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.assignment_outlined, size: 28, color: Colors.grey),
                        SizedBox(height: 6),
                        Text('暂无保存的挂单计划', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        SizedBox(height: 2),
                        Text('在上方测算出点位后，点击“📌 存入今日计划”即可随时追踪开单', style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ] else ...[
                  Column(
                    children: _savedPlans.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map<String, dynamic> item = entry.value;
                      return _buildSavedPlanItem(idx, item);
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        // 机械化推保护点计算器
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.security, size: 16, color: Color(0xFF059669)),
                    SizedBox(width: 6),
                    Text('机械化移动止损参考 (Trailing Stop)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('当价格跑赢 1:1 后，或者进入下一交易日，将止损移至前一日极值外加缓冲：', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('做多防守 (昨日最低 - 15pips):', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(
                      hasData ? (lowPrice! - (15 / pipMultiplier)).toStringAsFixed(decimals) : '--',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('做空防守 (昨日最高 + 15pips):', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(
                      hasData ? (highPrice! + (15 / pipMultiplier)).toStringAsFixed(decimals) : '--',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: leftChildren,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: rightChildren,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(10),
          children: [
            ...leftChildren,
            ...rightChildren,
          ],
        );
      },
    );
  }

  Widget _buildCheckItem(String title, bool val, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!val),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: val,
                activeColor: const Color(0xFF059669),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 11, fontWeight: val ? FontWeight.w600 : FontWeight.normal)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPlanItem(int idx, Map<String, dynamic> item) {
    final isLong = item['dir'] == 'BUY';
    final color = isLong ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final currentStatus = item['status'] as String? ?? '⏳ 挂单中';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: ((item['category'] ?? (item['pair'] == 'XAUUSD' ? 'observed' : 'core')) == 'core'
                          ? const Color(0xFFFEF3C7)
                          : ((item['category'] ?? '') == 'observed' ? const Color(0xFFFDE68A) : const Color(0xFFEFF6FF))),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['categoryLabel'] ?? (item['pair'] == 'XAUUSD' ? '🥇 观察' : '⭐ 核心'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ((item['category'] ?? (item['pair'] == 'XAUUSD' ? 'observed' : 'core')) == 'core'
                            ? const Color(0xFFB45309)
                            : ((item['category'] ?? '') == 'observed' ? const Color(0xFF92400E) : const Color(0xFF1D4ED8))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item['pair']}${item['pairChinese'] != null && (item['pairChinese'] as String).isNotEmpty ? " (${item['pairChinese']})" : ""} · ${item['dir']}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(item['mode'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  Text(item['time'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _deletePlan(idx),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('入场: ${item['entry']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              Text('止损: ${item['sl']} (${item['pips']}p)', style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontFamily: 'monospace')),
              Text('1:1保本: ${item['tp1']}', style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text((item['isDual'] ?? true) ? '双轨分仓: ${item['lot']} + ${item['lot']} 手' : '单轨全仓: ${item['lot']} 手', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              Text('总风控: \$${item['riskUsd']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          if (item['tscfStars'] != null || item['be40'] != null) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (item['tscfStars'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (item['tscfStars'] == '★★★★'
                              ? const Color(0xFF10B981)
                              : (item['tscfStars'] == '★★★☆' ? const Color(0xFF2563EB) : const Color(0xFFDC2626)))
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item['tscfStars']} ${item['tscfTitle'] ?? ""}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: item['tscfStars'] == '★★★★'
                            ? const Color(0xFF059669)
                            : (item['tscfStars'] == '★★★☆' ? const Color(0xFF2563EB) : const Color(0xFFDC2626)),
                      ),
                    ),
                  ),
                if (item['be40'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('40p保本: ${item['be40']}', style: const TextStyle(fontSize: 10, color: Color(0xFF059669), fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ),
                if (item['beBody'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('实体保本: ${item['beBody']}', style: const TextStyle(fontSize: 10, color: Color(0xFF0D9488), fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
          const Divider(height: 14),
          // 状态切换 Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['⏳ 挂单中', '🎯 1:1已推保本', '💰 全部止盈', '🛡️ 保本离场', '❌ 已止损'].map((st) {
                bool sel = currentStatus == st;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(st, style: TextStyle(fontSize: 9, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                    selected: sel,
                    onSelected: (_) => _updatePlanStatus(idx, st),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterChip(String cat, String label) {
    bool isSel = _categoryFilter == cat;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _categoryFilter = cat);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF2563EB).withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSel ? const Color(0xFF2563EB) : Theme.of(context).dividerColor.withOpacity(0.4)),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? const Color(0xFF1E40AF) : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
      ),
    );
  }

  Widget _buildPairChipV2(WatchlistPair p) {
    bool isSelected = selectedPair == p.symbol;
    return GestureDetector(
      onTap: () => _selectWatchlistPair(p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (p.isCore ? const Color(0xFFFEF3C7) : (p.isGold ? const Color(0xFFFDE68A) : const Color(0xFFDBEAFE)))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? (p.isCore ? const Color(0xFFF59E0B) : (p.isGold ? const Color(0xFFD97706) : const Color(0xFF3B82F6)))
                  : Theme.of(context).dividerColor.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            p.isCore
                ? const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706))
                : (p.isGold
                    ? const Icon(Icons.circle, size: 10, color: Color(0xFFB45309))
                    : const Icon(Icons.label_outline_rounded, size: 14, color: Color(0xFF2563EB))),
            const SizedBox(width: 4),
            Text(
              '${p.symbol} ${p.chineseName}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (p.isCore ? const Color(0xFF92400E) : (p.isGold ? const Color(0xFF78350F) : const Color(0xFF1E40AF)))
                    : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyFullTradePlan({
    required int decimals,
    required double currentRiskPips,
    required double riskAmountUsd,
    required double tradeLot,
    required double fib50,
    required double fibSl,
    required double fib50Risk,
    required double breakoutEntry,
    required double breakoutSl,
    required double breakoutRisk,
    required double be40,
    required double beBody,
  }) {
    HapticFeedback.mediumImpact();
    final pairInfo = getWatchlistPair(selectedPair);
    final orderType = (entryMode == 1)
        ? (isLong ? 'Buy Limit (回踩挂多)' : 'Sell Limit (反弹挂空)')
        : (isLong ? 'Buy Stop (突破追多)' : 'Sell Stop (跌破追空)');
    final entryPrice = (entryMode == 1) ? fib50.toStringAsFixed(decimals) : breakoutEntry.toStringAsFixed(decimals);
    final slPrice = (entryMode == 1) ? fibSl.toStringAsFixed(decimals) : breakoutSl.toStringAsFixed(decimals);
    final tp1Price = (entryMode == 1)
        ? (isLong ? fib50 + fib50Risk : fib50 - fib50Risk).toStringAsFixed(decimals)
        : (isLong ? breakoutEntry + breakoutRisk : breakoutEntry - breakoutRisk).toStringAsFixed(decimals);
    final tp2Price = (entryMode == 1)
        ? (isLong ? fib50 + fib50Risk * 2 : fib50 - fib50Risk * 2).toStringAsFixed(decimals)
        : (isLong ? breakoutEntry + breakoutRisk * 2 : breakoutEntry - breakoutRisk * 2).toStringAsFixed(decimals);
    final tp3Price = (entryMode == 1)
        ? (isLong ? fib50 + fib50Risk * 3 : fib50 - fib50Risk * 3).toStringAsFixed(decimals)
        : (isLong ? breakoutEntry + breakoutRisk * 3 : breakoutEntry - breakoutRisk * 3).toStringAsFixed(decimals);
    final be40Price = be40.toStringAsFixed(decimals);
    final beBodyPrice = beBody.toStringAsFixed(decimals);

    final checklistNote = _allChecked
        ? '【🛡️ 开单前 5 项风控铁律：已逐项自审 100% 合格】\n'
        : '【⚠️ 提示：开单前请务必完成 5 项风控铁律自审】\n';

    final tscfSummary = '【⚔️ T.S.C.F. 共振评级：${_tscfRating['stars']} ${_tscfRating['title']} (共振: $_tscfScore/4)】\n● 状态诊断：${_tscfRating['desc']}\n';

    final plan = '''
【DT · 吞没战法实战挂单指令】
● 交易品种：$selectedPair (${pairInfo.chineseName})
● 品种分级：${pairInfo.categoryLabel}（${pairInfo.isCore ? "7大核心高流动性品种 · 首选主线" : (pairInfo.isMinor ? "9大强趋势次要交叉盘 · 辅助筛选" : "独立高波动大宗商品")}）
● 品种特性：${pairInfo.feature}
● 交易方向：${isLong ? "做多 (BUY)" : "做空 (SELL)"}
● 挂单模式：${(entryMode == 1) ? "🎯 黄金口袋 (Fib 50% 回踩狙击)" : "🚀 极值突破挂单 (+10pips假破缓冲)"}
● 挂单类型：$orderType
● 挂单价格：$entryPrice
● 硬性止损：$slPrice (极值外9pips缓冲 · 止损 ${currentRiskPips.toStringAsFixed(1)} Pips)
----------------------------------------
● 双轨分仓执行 (本金 \$${userBalance.toStringAsFixed(0)} · 风控 $userRisk%)：
  ├─ Trade 1 (1:1 稳健落袋)：${tradeLot.toStringAsFixed(2)} 手 ➔ 目标价 $tp1Price
  │   (触发落袋后立即平仓，并推 Trade 2 止损至开仓价保本！)
  └─ Trade 2 (波段奔跑仓)：${tradeLot.toStringAsFixed(2)} 手 ➔ 目标价 $tp2Price (延伸: $tp3Price)
● 双重推保本点位 (Notion Part 3)：
  ├─ 规则 A (+40 Pips 规则)：触及 $be40Price ➔ 立即推止损至开仓价保本
  └─ 规则 B (实体等长规则)：触及 $beBodyPrice ➔ 立即推止损至开仓价保本
● 奔跑单离场法则：Trade 2 坚决持有，直至日线 (D1) 出现反向吞没才平仓！
● 单笔最大风控金额：\$${riskAmountUsd.toStringAsFixed(2)} (折合 RM ${(riskAmountUsd * 4.5).toStringAsFixed(2)})
----------------------------------------
$tscfSummary$checklistNote⚠️ 纪律红线：Set & Forget！挂单后绝不手动追单，到 1:1 必须严格推保本！
''';

    copyToClipboard(context, plan.trim(), '完整实战挂单指令');
  }

  Widget _buildPriceCard(BuildContext context, String title, String price, String sub, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => copyToClipboard(context, price, title),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.copy_rounded, size: 11, color: color),
                ],
              ),
              const SizedBox(height: 4),
              Text(price, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color, fontFamily: 'monospace')),
              const SizedBox(height: 2),
              Text(sub, style: TextStyle(fontSize: 9, color: color.withOpacity(0.8)), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 4. 生存与复利模拟器（资金走势图、蒙特卡洛 12 个月推演）
// -------------------------------------------------------------


  
class SurvivalSimulatorPage extends StatefulWidget {
  const SurvivalSimulatorPage({super.key});

  @override
  State<SurvivalSimulatorPage> createState() => _SurvivalSimulatorPageState();
}

class _SurvivalSimulatorPageState extends State<SurvivalSimulatorPage> {
  final TextEditingController _balCtrl = TextEditingController(text: '700');
  final TextEditingController _winCtrl = TextEditingController(text: '50');
  final TextEditingController _riskCtrl = TextEditingController(text: '2');

  double startBal = 700;
  double winRate = 50;
  double riskPct = 2;
  double rr = 2.0;

  Map<String, dynamic>? simResult;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      startBal = prefs.getDouble('sim_bal') ?? 700;
      winRate = prefs.getDouble('sim_win') ?? 50;
      riskPct = prefs.getDouble('sim_risk') ?? 2;
      rr = prefs.getDouble('sim_rr') ?? 2.0;

      _balCtrl.text = startBal.toStringAsFixed(0);
      _winCtrl.text = winRate.toStringAsFixed(0);
      _riskCtrl.text = riskPct.toStringAsFixed(0);
    });
    if (simResult == null) {
      runSimulation();
    }
  }

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

    setState(() {
      simResult = {
        'dtFinal': dtBalance,
        'stFinal': stBalance,
        'dtMaxStreak': dtMaxStreak,
        'stMaxStreak': stMaxStreak,
        'dtDrawdown': dtMaxDrawdown,
        'stDrawdown': stMaxDrawdown,
        'dtBlownUp': dtBlownUp,
        'stBlownUp': stBlownUp,
        'dtBlowRate': (blownUpDtCount / 1000.0) * 100,
        'stBlowRate': (blownUpStCount / 1000.0) * 100,
        'dtMonthly': dtMonthlyProfits,
        'dtEquity': dtEquityPoints,
        'stEquity': stEquityPoints,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    double riskAmount = startBal * (riskPct / 100);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 800;

        // ═══════════════════════════════════════
        // 1. Top Controls (Banner + Inputs + Button) — 100% width
        // ═══════════════════════════════════════
        final topControls = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBanner(
              icon: Icons.insights,
              title: '蒙特卡洛 12 个月复利与走势演练',
              desc: '用客观概率打破赌徒侥幸心理。模拟连续12个月后资金曲线，直观感受风控红线的威力和回撤规律。',
              color: const Color(0xFFE11D48),
            ),
            const SizedBox(height: 12),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _balCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        labelText: '初始本金 (USD)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (v) {
                        startBal = double.tryParse(v) ?? 700;
                        SharedPreferences.getInstance().then((p) => p.setDouble('sim_bal', startBal));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _winCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        labelText: '交易胜率 (%)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (v) {
                        winRate = double.tryParse(v) ?? 50;
                        SharedPreferences.getInstance().then((p) => p.setDouble('sim_win', winRate));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _riskCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        labelText: '单笔总风险 (%)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (v) {
                        riskPct = double.tryParse(v) ?? 2;
                        SharedPreferences.getInstance().then((p) => p.setDouble('sim_risk', riskPct));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      isExpanded: true,
                      value: rr,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        labelText: '基础盈亏比',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1.0, child: Text('1:1 (保守)')),
                        DropdownMenuItem(value: 1.5, child: Text('1:1.5 (稳健)')),
                        DropdownMenuItem(value: 2.0, child: Text('1:2 (标准)')),
                        DropdownMenuItem(value: 3.0, child: Text('1:3 (极佳)')),
                      ],
                      onChanged: (v) {
                        setState(() => rr = v ?? 2.0);
                        SharedPreferences.getInstance().then((p) => p.setDouble('sim_rr', rr));
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 40,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: const Color(0xFF475569),
                      ),
                      onPressed: runSimulation,
                      icon: const Icon(Icons.casino, size: 18),
                      label: const Text('运行实战推演', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _balCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), labelText: '本金(USD)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        onChanged: (v) { startBal = double.tryParse(v) ?? 700; SharedPreferences.getInstance().then((p) => p.setDouble('sim_bal', startBal)); },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _winCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), labelText: '胜率(%)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        onChanged: (v) { winRate = double.tryParse(v) ?? 50; SharedPreferences.getInstance().then((p) => p.setDouble('sim_win', winRate)); },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _riskCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), labelText: '风险(%)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        onChanged: (v) { riskPct = double.tryParse(v) ?? 2; SharedPreferences.getInstance().then((p) => p.setDouble('sim_risk', riskPct)); },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        isExpanded: true, value: rr,
                        decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), labelText: '盈亏比', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        items: const [ DropdownMenuItem(value: 1.0, child: Text('1:1')), DropdownMenuItem(value: 1.5, child: Text('1:1.5')), DropdownMenuItem(value: 2.0, child: Text('1:2')), DropdownMenuItem(value: 3.0, child: Text('1:3')) ],
                        onChanged: (v) { setState(() => rr = v ?? 2.0); SharedPreferences.getInstance().then((p) => p.setDouble('sim_rr', rr)); },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), backgroundColor: const Color(0xFF475569)),
                    onPressed: runSimulation, icon: const Icon(Icons.casino),
                    label: const Text('🎲 运行 12 个月实战走势推演', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
          ],
        );

        // ═══════════════════════════════════════
        // 2. Left Panel — Comparison Cards
        // ═══════════════════════════════════════
        Widget leftPanel = Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.compare_arrows, color: Colors.blueAccent, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('双轨分仓 vs 传统单轨 12个月实战对比', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: const Text('DT 终极抗风险', style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.blueAccent.withOpacity(0.08),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.blueAccent, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '演练生效参数：单笔总风控 ${riskPct.toStringAsFixed(0)}% (\$${riskAmount.toStringAsFixed(0)}) - DT双轨拆分为 2x${(riskPct/2).toStringAsFixed(1)}% (各\$${(riskAmount/2).toStringAsFixed(0)}) · 初始本金 \$${startBal.toStringAsFixed(0)} (≈ RM ${(startBal * 4.5).toStringAsFixed(0)})',
                        style: const TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildResultCard(
                        title: 'DT 双轨 (2x${(riskPct/2).toStringAsFixed(1)}% = ${riskPct.toStringAsFixed(0)}%)',
                        subtitle: '风控: \$${riskAmount.toStringAsFixed(0)} (A:\$${(riskAmount/2).toStringAsFixed(0)}+B:\$${(riskAmount/2).toStringAsFixed(0)})',
                        finalBal: simResult!['dtFinal'],
                        maxRisk: '\$${riskAmount.toStringAsFixed(0)} (${riskPct.toStringAsFixed(0)}%)',
                        drawdown: simResult!['dtDrawdown'],
                        blowRate: simResult!['dtBlowRate'],
                        maxStreak: simResult!['dtMaxStreak'],
                        color: const Color(0xFF10B981),
                        isBlownUp: simResult!['dtBlownUp'],
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildResultCard(
                        title: '传统单轨 (1x${riskPct.toStringAsFixed(0)}%)',
                        subtitle: '单笔死扛风控: \$${riskAmount.toStringAsFixed(0)} (无保本)',
                        finalBal: simResult!['stFinal'],
                        maxRisk: '\$${riskAmount.toStringAsFixed(0)} (${riskPct.toStringAsFixed(0)}%)',
                        drawdown: simResult!['stDrawdown'],
                        blowRate: simResult!['stBlowRate'],
                        maxStreak: simResult!['stMaxStreak'],
                        color: const Color(0xFF8B5CF6),
                        isBlownUp: simResult!['stBlownUp'],
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        // ═══════════════════════════════════════
        // 3. Right Panel — Chart + Tip + Grid
        // ═══════════════════════════════════════
        Widget rightPanel = Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.show_chart, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Expanded(child: Text('资金净值走势对比 (Dual Equity Curve)', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))),
                    _buildLegend(const Color(0xFF10B981), '双轨分仓'),
                    const SizedBox(width: 12),
                    _buildLegend(const Color(0xFF8B5CF6), '传统单轨'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Tip box
                    Expanded(
                      flex: 48,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡 概率论破局真相', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF312E81))),
                          const SizedBox(height: 6),
                          const Text(
                            '传统单轨交易最致命的心态痛点是浮盈 1.5R 却侧漏翻车扫损。而 DT 双轨战法通过 Trade 1 提前落袋保本 + Trade 2 零风险奔跑，将最大回撤显著压缩，从数学概率底层消灭爆仓！',
                            style: TextStyle(fontSize: 11, color: Color(0xFF312E81), height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    ),
                    const SizedBox(width: 12),
                    // Right: Chart
                    Expanded(
                      flex: 52,
                      child: Container(
                        height: 120,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomPaint(
                          painter: DualEquityCurvePainter(
                            dtPoints: simResult!['dtEquity'] as List<double>,
                            stPoints: simResult!['stEquity'] as List<double>,
                            dtBlownUp: simResult!['dtBlownUp'] as bool,
                            stBlownUp: simResult!['stBlownUp'] as bool,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: const [
                    Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                    SizedBox(width: 6),
                    Text('逐月利润拆解 (DT 双轨):', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: LayoutBuilder(
                  builder: (context, gridConstraints) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(12, (idx) {
                        final val = (simResult!['dtMonthly'] as List<double>)[idx];
                        Color bgColor, borderColor, textColor;
                        String textStr;
                        if (val == 0) {
                          bgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
                          borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
                          textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
                          textStr = '-';
                        } else if (val > 0) {
                          bgColor = isDark ? const Color(0xFF064E3B).withOpacity(0.3) : const Color(0xFFF0FDF4);
                          borderColor = isDark ? const Color(0xFF059669).withOpacity(0.4) : const Color(0xFFBBF7D0);
                          textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF15803D);
                          textStr = '+\$${val.toStringAsFixed(0)}';
                        } else {
                          bgColor = isDark ? const Color(0xFF7F1D1D).withOpacity(0.3) : const Color(0xFFFEF2F2);
                          borderColor = isDark ? const Color(0xFFDC2626).withOpacity(0.4) : const Color(0xFFFECACA);
                          textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
                          textStr = '-\$${val.abs().toStringAsFixed(0)}';
                        }
                        String rmStr = '';
                        if (val != 0) {
                          double rmVal = val.abs() * 4.5;
                          rmStr = '≈ RM ${rmVal.toStringAsFixed(0)}';
                        }
                        
                        return Container(
                          width: (gridConstraints.maxWidth - 24) / 4,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: borderColor)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('月', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                                Row(
                                  children: [
                                    Text(textStr, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: textColor)),
                                    if (rmStr.isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      Text(rmStr, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.6))),
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        );

        if (isDesktop) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                topControls,
                if (simResult != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: leftPanel),
                      const SizedBox(width: 16),
                      Expanded(child: rightPanel),
                    ],
                  ),
                ],
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                topControls,
                if (simResult != null) ...[
                  const SizedBox(height: 16),
                  leftPanel,
                  const SizedBox(height: 16),
                  rightPanel,
                ],
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String subtitle,
    required double finalBal,
    required String maxRisk,
    required double drawdown,
    required double blowRate,
    required int maxStreak,
    required Color color,
    required bool isBlownUp,
    required bool isDark,
  }) {
    Color valueColor = isBlownUp ? const Color(0xFFDC2626) : color;
    Color ddColor = drawdown > 30 ? const Color(0xFFDC2626) : (drawdown > 15 ? Colors.orange : const Color(0xFF10B981));
    Color brColor = blowRate > 0 ? const Color(0xFFDC2626) : const Color(0xFF10B981);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Expanded(child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color))),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('\$${finalBal.toStringAsFixed(0)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: valueColor)),
              const SizedBox(width: 8),
              Text('≈ RM ${(finalBal * 4.5).toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, thickness: 1)),
          Row(
            children: [
              Expanded(child: _statItem('单笔最大风控', maxRisk, isBlownUp ? const Color(0xFFDC2626) : color)),
              const SizedBox(width: 8),
              Expanded(child: _statItem('最大回撤', '${drawdown.toStringAsFixed(1)}%', ddColor)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _statItem('破产熔断率', '${blowRate.toStringAsFixed(1)}%', brColor)),
              const SizedBox(width: 8),
              Expanded(child: _statItem('最大连亏', '$maxStreak 次', Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey))),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _row(String label, String value, Color vColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: vColor)),
      ],
    );
  }

  Widget _buildBanner({required IconData icon, required String title, required String desc, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
  }
}

class DualEquityCurvePainter extends CustomPainter {
  final List<double> dtPoints;
  final List<double> stPoints;
  final bool dtBlownUp;
  final bool stBlownUp;

  DualEquityCurvePainter({
    required this.dtPoints,
    required this.stPoints,
    required this.dtBlownUp,
    required this.stBlownUp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dtPoints.isEmpty || stPoints.isEmpty) return;

    double maxVal = max(dtPoints.reduce(max), stPoints.reduce(max));
    double minVal = min(dtPoints.reduce(min), stPoints.reduce(min));
    if (maxVal == minVal) {
      maxVal += 100;
      minVal -= 100;
    }
    double range = maxVal - minVal;

    void drawLine(List<double> points, Color color, bool blownUp) {
      final paintLine = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      final paintFill = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.2), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;

      final path = Path();
      final fillPath = Path();

      for (int i = 0; i < points.length; i++) {
        double x = (i / (points.length - 1)) * size.width;
        double y = size.height - ((points[i] - minVal) / range) * (size.height - 20) - 10;

        if (i == 0) {
          path.moveTo(x, y);
          fillPath.moveTo(x, size.height);
          fillPath.lineTo(x, y);
        } else {
          path.lineTo(x, y);
          fillPath.lineTo(x, y);
        }
      }

      fillPath.lineTo(size.width, size.height);
      fillPath.close();

      canvas.drawPath(fillPath, paintFill);
      canvas.drawPath(path, paintLine);

      final dotPaint = Paint()..color = color;
      double endX = size.width;
      double endY = size.height - ((points.last - minVal) / range) * (size.height - 20) - 10;
      canvas.drawCircle(Offset(endX, endY), 4, dotPaint);
    }

    drawLine(stPoints, stBlownUp ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6), stBlownUp);
    drawLine(dtPoints, dtBlownUp ? const Color(0xFFEF4444) : const Color(0xFF10B981), dtBlownUp);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}