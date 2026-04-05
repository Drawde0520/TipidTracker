import 'dart:math';
import 'package:flutter/material.dart';

class TipidChallengeService {
  static final List<String> _challenges = [
    'Challenge: Huwag bumili ng milk tea today! (Save ₱100)',
    'Challenge: Mag-baon ng lunch sa trabaho. (Save ₱150)',
    'Challenge: Mag-lakad kung malapit lang ang pupuntahan. (Save ₱20)',
    'Challenge: Check your subscription! I-cancel ang hindi nagagamit.',
    'Challenge: No meat today? Try vegetable cooking. (Save ₱50)',
    'Challenge: Ipon 10 pesos every time you use social media.',
    'Challenge: Mag-lista ng grocery bago pumunta sa palengke.',
  ];

  static String getChallenge() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _challenges[dayOfYear % _challenges.length];
  }
}
