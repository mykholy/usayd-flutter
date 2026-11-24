import 'package:flutter/material.dart';

/// Authentic color tokens for Usayd Academy (أكاديمية أُسَيْد)
/// Source: `tokens.color.v0.4.json` & `BRAND.md`
///
/// Tenets:
/// - ~60% parchment surface, 30% night brand, 10% lamp gold
/// - Lamp gold `#E8B04B` is never used as text on light parchment (brass `#8A5F12` is used for accessible contrast)
/// - Forbidden: purple/blue gradients, neon colors
class UsaydColorScheme extends ThemeExtension<UsaydColorScheme> {
  final Color bgPage;
  final Color bgRaised;
  final Color bgSubtle;
  final Color bgSunken;
  final Color bgBrand;
  final Color bgBrandSoft;
  final Color bgAccentSoft;

  final Color tx;
  final Color tx2;
  final Color tx3;
  final Color txBrand;
  final Color txAccent;
  final Color txOnBrand;
  final Color txOnBrand2;

  final Color line;
  final Color lineStrong;

  final Color act;
  final Color actHover;
  final Color onAct;

  final Color lamp;
  final Color onLamp;
  final Color brass;
  final Color focus;
  final Color canopy;
  final Color book;

  final Color ok;
  final Color okBg;
  final Color err;
  final Color errBg;
  final Color warn;
  final Color warnBg;
  final Color info;
  final Color infoBg;
  final Color clay;
  final Color clayBg;
  final Color ai;
  final Color aiBg;
  final Color lock;
  final Color lockBg;

  const UsaydColorScheme({
    required this.bgPage,
    required this.bgRaised,
    required this.bgSubtle,
    required this.bgSunken,
    required this.bgBrand,
    required this.bgBrandSoft,
    required this.bgAccentSoft,
    required this.tx,
    required this.tx2,
    required this.tx3,
    required this.txBrand,
    required this.txAccent,
    required this.txOnBrand,
    required this.txOnBrand2,
    required this.line,
    required this.lineStrong,
    required this.act,
    required this.actHover,
    required this.onAct,
    required this.lamp,
    required this.onLamp,
    required this.brass,
    required this.focus,
    required this.canopy,
    required this.book,
    required this.ok,
    required this.okBg,
    required this.err,
    required this.errBg,
    required this.warn,
    required this.warnBg,
    required this.info,
    required this.infoBg,
    required this.clay,
    required this.clayBg,
    required this.ai,
    required this.aiBg,
    required this.lock,
    required this.lockBg,
  });

  /// Light theme parchment-dominant palette (tokens.color.v0.4.json)
  static const UsaydColorScheme light = UsaydColorScheme(
    bgPage: Color(0xFFFBF7EE),
    bgRaised: Color(0xFFFFFDF8),
    bgSubtle: Color(0xFFF4ECDC),
    bgSunken: Color(0xFFECE2CC),
    bgBrand: Color(0xFF0F2529),
    bgBrandSoft: Color(0xFFE3ECEA),
    bgAccentSoft: Color(0xFFFBEFD5),
    tx: Color(0xFF1A1814),
    tx2: Color(0xFF57524A),
    tx3: Color(0xFF655F53),
    txBrand: Color(0xFF0F2529),
    txAccent: Color(0xFF835A10),
    txOnBrand: Color(0xFFF3EBDA),
    txOnBrand2: Color(0xFFBDB6A8),
    line: Color(0xFFE6DCC7),
    lineStrong: Color(0xFF8A8170),
    act: Color(0xFF0F2529),
    actHover: Color(0xFF1B4148),
    onAct: Color(0xFFF7F1E3),
    lamp: Color(0xFFE8B04B),
    onLamp: Color(0xFF1A1814),
    brass: Color(0xFF8A5F12),
    focus: Color(0xFF8A5F12),
    canopy: Color(0xFF8A5F12),
    book: Color(0xFF0F2529),
    ok: Color(0xFF2A6448),
    okBg: Color(0xFFE1EFE6),
    err: Color(0xFFA33725),
    errBg: Color(0xFFF9E4DE),
    warn: Color(0xFF835A10),
    warnBg: Color(0xFFFBEFD5),
    info: Color(0xFF285876),
    infoBg: Color(0xFFE2EDF3),
    clay: Color(0xFF93442A),
    clayBg: Color(0xFFF6E5DC),
    ai: Color(0xFF2A5A5F),
    aiBg: Color(0xFFE0EDEB),
    lock: Color(0xFF57524A),
    lockBg: Color(0xFFECE2CC),
  );

  /// Dark theme night-dominant palette (tokens.color.v0.4.json)
  static const UsaydColorScheme dark = UsaydColorScheme(
    bgPage: Color(0xFF0A1B1E),
    bgRaised: Color(0xFF11282C),
    bgSubtle: Color(0xFF173237),
    bgSunken: Color(0xFF07151A),
    bgBrand: Color(0xFF06141A),
    bgBrandSoft: Color(0xFF173439),
    bgAccentSoft: Color(0xFF2A2415),
    tx: Color(0xFFF4EDDF),
    tx2: Color(0xFFBFB8A9),
    tx3: Color(0xFFA39D91),
    txBrand: Color(0xFFF4EDDF),
    txAccent: Color(0xFFF0C25F),
    txOnBrand: Color(0xFFF4EDDF),
    txOnBrand2: Color(0xFFBFB8A9),
    line: Color(0xFF203B40),
    lineStrong: Color(0xFF5E7C80),
    act: Color(0xFFE8B04B),
    actHover: Color(0xFFF2C463),
    onAct: Color(0xFF14120E),
    lamp: Color(0xFFE8B04B),
    onLamp: Color(0xFF14120E),
    brass: Color(0xFFF0C25F),
    focus: Color(0xFFF0C25F),
    canopy: Color(0xFFE8B04B),
    book: Color(0xFFF4EDDF),
    ok: Color(0xFF7DCBA3),
    okBg: Color(0xFF12322A),
    err: Color(0xFFF29C87),
    errBg: Color(0xFF3A1F1B),
    warn: Color(0xFFEDC26C),
    warnBg: Color(0xFF2E2615),
    info: Color(0xFF92C3DF),
    infoBg: Color(0xFF12303F),
    clay: Color(0xFFEDA98B),
    clayBg: Color(0xFF382219),
    ai: Color(0xFF8ED4CB),
    aiBg: Color(0xFF113537),
    lock: Color(0xFFBFB8A9),
    lockBg: Color(0xFF173237),
  );

  @override
  UsaydColorScheme copyWith({
    Color? bgPage,
    Color? bgRaised,
    Color? bgSubtle,
    Color? bgSunken,
    Color? bgBrand,
    Color? bgBrandSoft,
    Color? bgAccentSoft,
    Color? tx,
    Color? tx2,
    Color? tx3,
    Color? txBrand,
    Color? txAccent,
    Color? txOnBrand,
    Color? txOnBrand2,
    Color? line,
    Color? lineStrong,
    Color? act,
    Color? actHover,
    Color? onAct,
    Color? lamp,
    Color? onLamp,
    Color? brass,
    Color? focus,
    Color? canopy,
    Color? book,
    Color? ok,
    Color? okBg,
    Color? err,
    Color? errBg,
    Color? warn,
    Color? warnBg,
    Color? info,
    Color? infoBg,
    Color? clay,
    Color? clayBg,
    Color? ai,
    Color? aiBg,
    Color? lock,
    Color? lockBg,
  }) {
    return UsaydColorScheme(
      bgPage: bgPage ?? this.bgPage,
      bgRaised: bgRaised ?? this.bgRaised,
      bgSubtle: bgSubtle ?? this.bgSubtle,
      bgSunken: bgSunken ?? this.bgSunken,
      bgBrand: bgBrand ?? this.bgBrand,
      bgBrandSoft: bgBrandSoft ?? this.bgBrandSoft,
      bgAccentSoft: bgAccentSoft ?? this.bgAccentSoft,
      tx: tx ?? this.tx,
      tx2: tx2 ?? this.tx2,
      tx3: tx3 ?? this.tx3,
      txBrand: txBrand ?? this.txBrand,
      txAccent: txAccent ?? this.txAccent,
      txOnBrand: txOnBrand ?? this.txOnBrand,
      txOnBrand2: txOnBrand2 ?? this.txOnBrand2,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
      act: act ?? this.act,
      actHover: actHover ?? this.actHover,
      onAct: onAct ?? this.onAct,
      lamp: lamp ?? this.lamp,
      onLamp: onLamp ?? this.onLamp,
      brass: brass ?? this.brass,
      focus: focus ?? this.focus,
      canopy: canopy ?? this.canopy,
      book: book ?? this.book,
      ok: ok ?? this.ok,
      okBg: okBg ?? this.okBg,
      err: err ?? this.err,
      errBg: errBg ?? this.errBg,
      warn: warn ?? this.warn,
      warnBg: warnBg ?? this.warnBg,
      info: info ?? this.info,
      infoBg: infoBg ?? this.infoBg,
      clay: clay ?? this.clay,
      clayBg: clayBg ?? this.clayBg,
      ai: ai ?? this.ai,
      aiBg: aiBg ?? this.aiBg,
      lock: lock ?? this.lock,
      lockBg: lockBg ?? this.lockBg,
    );
  }

  @override
  UsaydColorScheme lerp(ThemeExtension<UsaydColorScheme>? other, double t) {
    if (other is! UsaydColorScheme) return this;
    return UsaydColorScheme(
      bgPage: Color.lerp(bgPage, other.bgPage, t)!,
      bgRaised: Color.lerp(bgRaised, other.bgRaised, t)!,
      bgSubtle: Color.lerp(bgSubtle, other.bgSubtle, t)!,
      bgSunken: Color.lerp(bgSunken, other.bgSunken, t)!,
      bgBrand: Color.lerp(bgBrand, other.bgBrand, t)!,
      bgBrandSoft: Color.lerp(bgBrandSoft, other.bgBrandSoft, t)!,
      bgAccentSoft: Color.lerp(bgAccentSoft, other.bgAccentSoft, t)!,
      tx: Color.lerp(tx, other.tx, t)!,
      tx2: Color.lerp(tx2, other.tx2, t)!,
      tx3: Color.lerp(tx3, other.tx3, t)!,
      txBrand: Color.lerp(txBrand, other.txBrand, t)!,
      txAccent: Color.lerp(txAccent, other.txAccent, t)!,
      txOnBrand: Color.lerp(txOnBrand, other.txOnBrand, t)!,
      txOnBrand2: Color.lerp(txOnBrand2, other.txOnBrand2, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineStrong: Color.lerp(lineStrong, other.lineStrong, t)!,
      act: Color.lerp(act, other.act, t)!,
      actHover: Color.lerp(actHover, other.actHover, t)!,
      onAct: Color.lerp(onAct, other.onAct, t)!,
      lamp: Color.lerp(lamp, other.lamp, t)!,
      onLamp: Color.lerp(onLamp, other.onLamp, t)!,
      brass: Color.lerp(brass, other.brass, t)!,
      focus: Color.lerp(focus, other.focus, t)!,
      canopy: Color.lerp(canopy, other.canopy, t)!,
      book: Color.lerp(book, other.book, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      okBg: Color.lerp(okBg, other.okBg, t)!,
      err: Color.lerp(err, other.err, t)!,
      errBg: Color.lerp(errBg, other.errBg, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      warnBg: Color.lerp(warnBg, other.warnBg, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      clay: Color.lerp(clay, other.clay, t)!,
      clayBg: Color.lerp(clayBg, other.clayBg, t)!,
      ai: Color.lerp(ai, other.ai, t)!,
      aiBg: Color.lerp(aiBg, other.aiBg, t)!,
      lock: Color.lerp(lock, other.lock, t)!,
      lockBg: Color.lerp(lockBg, other.lockBg, t)!,
    );
  }
}
