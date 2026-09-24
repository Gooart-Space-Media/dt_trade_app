// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '双轨风控大师 Pro';

  @override
  String get navHome => '首页';

  @override
  String get navRisk => '组合防呆';

  @override
  String get navDual => '双轨手数';

  @override
  String get navSniper => '吞没狙击';

  @override
  String get navTrend => '复利走势';

  @override
  String get msgOpeningXM => '正在前往 XM 官方认证开户通道...';

  @override
  String get titleXMBanner => 'XM 官方认证开户通道 (专属活动)';

  @override
  String get descXMBanner => '点击立即注册，尊享极低点差与入金赠金';

  @override
  String get titleMantra => '吞没战法实战三句真诀 (必须焊死在脑海)：';

  @override
  String get mantra1Title => '① 做多确认看实体吞没 —— ';

  @override
  String get mantra1Desc => '形态真假看 Body，后一根实体必须彻底吃掉前一根；';

  @override
  String get mantra2Title => '② 止损躲在全区最低影线底 —— ';

  @override
  String get mantra2Desc => '取整片形态区域 (母烛 + 前置烛) 最低的下影线 (Lowest Wick) - 10p；';

  @override
  String get mantra3Title => '③ 50% 取自全区极高与极低的中点 —— ';

  @override
  String get mantra3Desc => '(全区最高 High + 全区最低 Low) ÷ 2，绝不仅看单根母烛！';

  @override
  String get titleBlueprint => '吞没结构与黄金口袋解剖蓝图';

  @override
  String get tagMultiK => '多重 K 线形态区';

  @override
  String get descBlueprint => '黄金口袋 50% 模式：全区极值画网，回踩入场将止损精准压缩';

  @override
  String get blueprintHigh => '全区最高价 High';

  @override
  String get blueprintLow => '全区最低价 Low';

  @override
  String get radarStatus1 => '🌅 晨间设单窗口';

  @override
  String get radarDesc1 => 'D1 日线收盘，7:00-8:00 挂单后关闭软件 (Set & Forget)';

  @override
  String radarCount1(String diff) {
    return '距窗口关闭 $diff分';
  }

  @override
  String get radarStatus2 => '☕ 亚盘静默观察期';

  @override
  String get radarDesc2 => '让市场来找我。亚盘波动小，绝不因 FOMO 手动追单';

  @override
  String radarCount2(String h, String m) {
    return '距 15:00 伦敦盘 ${h}h${m}m';
  }

  @override
  String get radarStatus3 => '🇬🇧 伦敦盘爆发中';

  @override
  String get radarDesc3 => '欧洲资金进场，日线挂单迎来首波突破与测试';

  @override
  String radarCount3(String h, String m) {
    return '距 20:30 主战场 ${h}h${m}m';
  }

  @override
  String get radarStatus4 => '🔥 伦纽重叠主战场';

  @override
  String get radarDesc4 => '全天最大波动窗口！20:30-24:00 留意 Trade 1 止盈与推保本';

  @override
  String radarCount4(String h, String m) {
    return '距重叠期结束 ${h}h${m}m';
  }

  @override
  String get radarStatus5 => '🌙 纽约尾盘与休市';

  @override
  String get radarDesc5 => '市场趋缓，保持良好作息，迎接明日晨间开盘';

  @override
  String radarCount5(String h, String m) {
    return '距明日 07:00 晨盘 ${h}h${m}m';
  }
}
