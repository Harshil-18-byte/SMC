import 'package:flutter/material.dart';

import 'package:smc/config/routes.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to SMC'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select Role',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Admin Dashboard or Login
                  Navigator.pushNamed(context, AppRoutes.adminDashboard);
                },
                child: const Text('Admin Dashboard'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Hospital Dashboard
                  Navigator.pushNamed(context, AppRoutes.hospitalDashboard);
                },
                child: const Text('Hospital Staff'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Field Worker Home
                  Navigator.pushNamed(context, AppRoutes.fieldWorkerHome);
                },
                child: const Text('Field Worker'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Citizen Home
                  Navigator.pushNamed(context, AppRoutes.citizenHome);
                },
                child: const Text('Citizen App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


