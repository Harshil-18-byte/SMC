class CulturalContext {
  static bool isPublicHoliday() {
    final today = DateTime.now();

    final solapurHolidays = [
      DateTime(today.year, 11, 1), // Diwali (approx)
      DateTime(today.year, 8, 15), // Independence Day
      DateTime(today.year, 10, 2), // Gandhi Jayanti
      DateTime(today.year, 3, 8), // Holi (approx)
      // Add Solapur-specific festivals
    ];

    return solapurHolidays.any((holiday) =>
        holiday.year == today.year &&
        holiday.month == today.month &&
        holiday.day == today.day);
  }

  static bool isSiddheshwarYatra() {
    final today = DateTime.now();
    // Gadda Yatra is typically mid-January (Jan 12-16)
    return today.month == 1 && today.day >= 12 && today.day <= 16;
  }

  static bool isGaneshFestival() {
    final today = DateTime.now();
    // Approx dates for late Aug / Sept
    return today.month == 9 || (today.month == 8 && today.day > 20);
  }

  static bool isAshadiEkadashi() {
    final today = DateTime.now();
    // Approx dates for June/July - Wari season
    return today.month == 6 || today.month == 7;
  }

  static String? getContextualBanner() {
    final today = DateTime.now();

    // 1. Specific Solapur Festivals (Highest Priority)
    if (isSiddheshwarYatra()) {
      return "🎡 Gadda Yatra Special: Expect heavier traffic near Siddheshwar Temple area today.";
    }

    if (isGaneshFestival()) {
      return "🥁 Ganpati Bappa Morya! Crowds expected at public mandals. Plan visits accordingly.";
    }

    if (isAshadiEkadashi()) {
      return "🚩 Wari Season: High footfall expected on Palkhi routes. Emergency services are on alert.";
    }

    // 2. Public Holidays
    if (isPublicHoliday()) {
      return "🎉 Holiday Mode: Emergency services are available 24/7. Enjoy your day!";
    }

    // 3. Seasonal & Weather Context (Solapur Specific Climate)
    if (today.month >= 3 && today.month <= 5) {
      // Solapur Summer is intense (40°C+)
      final hour = today.hour;
      if (hour > 11 && hour < 16) {
        return "☀️ High Heat Alert: It's peak sun hours. Stay hydrated and take breaks in shade.";
      }
      return "☀️ Summer Season: Carry your water bottle. Watch for heatstroke symptoms in seniors.";
    }

    if (today.month >= 6 && today.month <= 9) {
      return "🌧️ Monsoon Watch: Check for stagnant water spots (Dengue/Malaria prevention).";
    }

    if (today.month >= 11 || today.month <= 1) {
      return "🧣 Winter Morning: Cold wave expected early morning. Advise seniors to stay warm.";
    }

    return null;
  }
}


