import 'dart:math';
import 'package:flutter/material.dart';

class LocalizedText {
  static String greeting(TimeOfDay time) {
    final hour = time.hour;

    if (hour < 12) {
      return _getRandomMorningGreeting();
    } else if (hour < 17) {
      return _getRandomAfternoonGreeting();
    } else {
      return _getRandomEveningGreeting();
    }
  }

  static String _getRandomMorningGreeting() {
    final options = [
      "शुभ सकाळ! (Good Morning)",
      "राम कृष्ण हरी! दिवसाची सुरुवात चांगली करा.",
      "Good Morning! चहा झाला का?", // Did you have tea?
      "Namaskar! Today is a great day to serve."
    ];
    return options[Random().nextInt(options.length)];
  }

  static String _getRandomAfternoonGreeting() {
    final options = [
      "शुभ दुपार (Good Afternoon)",
      "नमस्कार (Good Afternoon)",
    ];
    return options[Random().nextInt(options.length)];
  }

  static String _getRandomEveningGreeting() {
    final options = [
      "शुभ संध्याकाळ! (Good Evening)",
      "Almost done! घरी जाण्याची वेळ होत आली आहे.", // Time to go home soon
      "Great work today! विश्रांती घ्या." // Take rest
    ];
    return options[Random().nextInt(options.length)];
  }

  static String encouragement() {
    final messages = [
      "छान काम! (Great work!)",
      "Keep going! तुम्ही चांगले करत आहात",
      "Almost done! आणखी थोडेच",
      "Shabaash! (Well done!)",
      "Do not stress, take it easy."
    ];
    return messages[Random().nextInt(messages.length)];
  }

  static String getRefreshSuccessMessage() {
    final messages = [
      "All tasks synced! (सर्व माहिती अपडेट केली)",
      "Connected to Control Room. You are up to date.",
      "Sync complete! Ready for action.",
      "Data refresed. Chala, pudhe jauya! (Let's move forward)"
    ];
    return messages[Random().nextInt(messages.length)];
  }
}


