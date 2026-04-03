import 'package:flutter/material.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:smc/features/gamification/widgets/gamification_hub.dart';

class FieldWorkerAchievementsScreen extends StatelessWidget {
  const FieldWorkerAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SMCBackButton(),
        title: const Text('My Impact & Achievements'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(), // Add spacing or keep clean
        ),
      ),
      drawer: const UniversalDrawer(),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 16),
          child: GamificationHub(),
        ),
      ),
    );
  }
}
