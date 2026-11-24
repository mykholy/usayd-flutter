/// Interface modes defined by Usayd Adaptive UI specification (AGE_ADAPTIVE_UI.md)
enum InterfaceMode {
  kids,
  pro,
  simple;

  /// Recommend the default interface mode based on user age band.
  static InterfaceMode recommendForAge(int age) {
    if (age >= 6 && age <= 12) {
      return InterfaceMode.kids;
    }
    if (age >= 60) {
      return InterfaceMode.simple;
    }
    return InterfaceMode.pro;
  }

  String get displayNameArabic {
    switch (this) {
      case InterfaceMode.kids:
        return 'نمط البراعم (الأطفال)';
      case InterfaceMode.pro:
        return 'النمط المتقدم';
      case InterfaceMode.simple:
        return 'النمط الميسر (كبار السن)';
    }
  }

  String get displayNameEnglish {
    switch (this) {
      case InterfaceMode.kids:
        return 'Kids Mode';
      case InterfaceMode.pro:
        return 'Professional Mode';
      case InterfaceMode.simple:
        return 'Simple Mode';
    }
  }

  String get recommendedAgeLabel {
    switch (this) {
      case InterfaceMode.kids:
        return 'الأطفال والناشئة (6–12 سنة)';
      case InterfaceMode.pro:
        return 'البالغون والحُفّاظ (13–59 سنة)';
      case InterfaceMode.simple:
        return 'كبار السن (60+ سنة)';
    }
  }
}
