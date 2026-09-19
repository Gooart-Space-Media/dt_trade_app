import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTranslations {
  static final ValueNotifier<String> currentLang = ValueNotifier<String>('zh');

  static final Map<String, Map<String, String>> _dict = {
    'zh': {},
    'en': {
      '组合防呆': 'Overlap Checker',
      '双轨手数': 'Lot Calculator',
      '吞没狙击': 'Engulfing Sniper',
      '复利走势': 'Compounding',
      '双轨风控大师 Pro · 吞没战法指挥部': 'DT Risk Master Pro',
      '多单并行防呆与自审': 'Long Positions Checker',
      '空单并行防呆与自审': 'Short Positions Checker',
      '交易 1 (首选主线)': 'Trade 1 (Main)',
      '交易 2 (独立隔离)': 'Trade 2 (Isolated)',
      '交易 3 (独立隔离)': 'Trade 3 (Isolated)',
      '多': 'Long',
      '空': 'Short',
      '账户本金 (USD)': 'Account Balance (USD)',
      '汇率 (MYR)': 'Exchange Rate (MYR)',
      '形态止损空间 (Pips)': 'SL Distance (Pips)',
      '形态止损点数 (0.1\$ 为 1 Pip)': 'SL Points (0.1\$ = 1 Pip)',
      '变速箱风控红线 (Risk %)': 'Risk Limit (%)',
      '常规突破': 'Breakout',
      '黄金口袋': 'Golden Pocket',
      '极值突破': 'Extreme Breakout',
      '做多 (BUY)': 'Buy (Long)',
      '做空 (SELL)': 'Sell (Short)',
      '全区最高价 High (整片形态最高上影线顶点)': 'Highest High (Pattern Area)',
      '全区最低价 Low (整片形态最低下影线底端 · 做多止损基准)': 'Lowest Low (Pattern Area)',
    },
    'ms': {
      '组合防呆': 'Semakan Pertindihan',
      '双轨手数': 'Kalkulator Lot',
      '吞没狙击': 'Sniper Engulfing',
      '复利走势': 'Kompaun',
      '双轨风控大师 Pro · 吞没战法指挥部': 'DT Risk Master Pro',
      '多单并行防呆与自审': 'Semakan Posisi Long',
      '空单并行防呆与自审': 'Semakan Posisi Short',
      '交易 1 (首选主线)': 'Trade 1 (Utama)',
      '交易 2 (独立隔离)': 'Trade 2 (Asingan)',
      '交易 3 (独立隔离)': 'Trade 3 (Asingan)',
      '多': 'Long',
      '空': 'Short',
      '账户本金 (USD)': 'Baki Akaun (USD)',
      '汇率 (MYR)': 'Kadar Pertukaran (MYR)',
      '形态止损空间 (Pips)': 'Jarak SL (Pips)',
      '形态止损点数 (0.1\$ 为 1 Pip)': 'Mata SL (0.1\$ = 1 Pip)',
      '变速箱风控红线 (Risk %)': 'Had Risiko (%)',
      '常规突破': 'Breakout',
      '黄金口袋': 'Golden Pocket',
      '极值突破': 'Breakout Ekstrim',
      '做多 (BUY)': 'Beli (Long)',
      '做空 (SELL)': 'Jual (Short)',
      '全区最高价 High (整片形态最高上影线顶点)': 'High Tertinggi (Kawasan Corak)',
      '全区最低价 Low (整片形态最低下影线底端 · 做多止损基准)': 'Low Terendah (Kawasan Corak)',
    }
  };

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    currentLang.value = prefs.getString('app_lang') ?? 'zh';
  }

  static Future<void> setLang(String lang) async {
    currentLang.value = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', lang);
  }

  static String tr(String key) {
    if (currentLang.value == 'zh') return key;
    return _dict[currentLang.value]?[key] ?? key;
  }
}

String tr(String key) => AppTranslations.tr(key);
