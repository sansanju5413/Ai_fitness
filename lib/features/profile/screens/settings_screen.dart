import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: Colors.transparent),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const _SectionHeader(title: 'PREFERENCES'),
            SwitchListTile(
              title: const Text('Push Notifications', style: TextStyle(color: AppColors.textPrimary)),
              value: true,
              onChanged: (val) {},
              activeColor: AppColors.primary,
              tileColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Dark Mode', style: TextStyle(color: AppColors.textPrimary)),
              value: true,
              onChanged: (val) {}, // Always dark for now based on theme
              activeColor: AppColors.primary,
              tileColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              subtitle: const Text("Theme is currently locked to Dark", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
            
            const SizedBox(height: 32),
            const _SectionHeader(title: 'ACCOUNT'),
            ListTile(
              title: const Text('View Profile', style: TextStyle(color: AppColors.textPrimary)),
              tileColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.person, color: AppColors.primary),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
              onTap: () => context.push('/profile'),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Change Password', style: TextStyle(color: AppColors.textPrimary)),
              tileColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.lock, color: AppColors.primary),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
              onTap: () {
                // Navigate to password change screen or show dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Change Password', style: TextStyle(color: AppColors.textPrimary)),
                    content: const Text(
                      'To change your password, please use the "Forgot Password" option on the login screen, or contact support for assistance.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Privacy Policy', style: TextStyle(color: AppColors.textPrimary)),
              tileColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.privacy_tip, color: AppColors.primary),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Privacy Policy', style: TextStyle(color: AppColors.textPrimary)),
                    content: SingleChildScrollView(
                      child: Text(
                        'AI Fitness App Privacy Policy\n\n'
                        'We respect your privacy and are committed to protecting your personal data. '
                        'Your fitness data, including workouts, nutrition logs, and progress metrics, '
                        'are stored securely and used only to provide personalized fitness recommendations.\n\n'
                        'We do not share your personal information with third parties without your consent.\n\n'
                        'For questions, contact: support@aifit.com',
                        style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 4),
      child: Text(title, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
