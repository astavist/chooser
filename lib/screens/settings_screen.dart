import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text(
                'Reset Tutorial',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Show the tutorial screen again',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.blue),
                onPressed: () {
                  context.read<SettingsProvider>().setHasSeenTutorial(false);
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(color: Colors.white24),
            const SizedBox(height: 24),
            const Text(
              'About',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chooser v1.0.0\n\n'
              'A simple app to help you make decisions.\n'
              'Add your choices and let the app pick one for you!',
              style: TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 