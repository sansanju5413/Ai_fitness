import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/auth_repository.dart';
import '../repositories/profile_repository.dart';
import '../models/user_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final profileAsync = ref.watch(profileStreamProvider);
    
    final displayName = user?.displayName ?? "Fitness enthusiast";
    final email = user?.email ?? "user@example.com";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/profile-setup'),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // User Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(displayName, style: Theme.of(context).textTheme.headlineSmall),
                    Text(email, style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Profile Details
              profileAsync.when(
                data: (profile) {
                  if (profile == null) {
                    return Column(
                      children: [
                        Card(
                          color: AppColors.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text('Complete your profile to get personalized recommendations', 
                                  style: TextStyle(color: AppColors.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.push('/profile-setup'),
                                  child: const Text('Setup Profile'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  
                  return Column(
                    children: [
                      _ProfileDetailCard(
                        title: 'Body Metrics',
                        children: [
                          _DetailRow(label: 'Height', value: '${profile.bodyMetrics.height.toStringAsFixed(0)} cm'),
                          _DetailRow(label: 'Weight', value: '${profile.bodyMetrics.weight.toStringAsFixed(1)} kg'),
                          _DetailRow(label: 'Target Weight', value: '${profile.bodyMetrics.targetWeight.toStringAsFixed(1)} kg'),
                          _DetailRow(label: 'Body Type', value: profile.bodyMetrics.bodyType),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ProfileDetailCard(
                        title: 'Fitness Profile',
                        children: [
                          _DetailRow(label: 'Goal', value: profile.fitnessProfile.primaryGoal),
                          _DetailRow(label: 'Level', value: profile.fitnessProfile.fitnessLevel),
                          _DetailRow(label: 'Activity', value: profile.fitnessProfile.activityLevel),
                          _DetailRow(label: 'Equipment', value: profile.fitnessProfile.availableEquipment.isEmpty 
                            ? 'Bodyweight only' 
                            : profile.fitnessProfile.availableEquipment.join(', ')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ProfileDetailCard(
                        title: 'Nutrition',
                        children: [
                          _DetailRow(label: 'Dietary Preference', value: profile.nutritionProfile.dietaryPreference),
                          _DetailRow(label: 'Meals per Day', value: '${profile.nutritionProfile.mealsPerDay}'),
                          _DetailRow(label: 'Water Goal', value: '${profile.nutritionProfile.waterIntakeGoal}L'),
                          if (profile.nutritionProfile.allergies.isNotEmpty)
                            _DetailRow(label: 'Allergies', value: profile.nutritionProfile.allergies.join(', ')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ProfileDetailCard(
                        title: 'Health & Lifestyle',
                        children: [
                          _DetailRow(label: 'Sleep Hours', value: '${profile.healthLifestyle.sleepHours}h/day'),
                          _DetailRow(label: 'Stress Level', value: '${profile.healthLifestyle.stressLevel}/10'),
                          if (profile.healthLifestyle.injuries.isNotEmpty && profile.healthLifestyle.injuries != 'None')
                            _DetailRow(label: 'Injuries', value: profile.healthLifestyle.injuries),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) {
                  // Show error message instead of hiding
                  return Card(
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.accent, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Unable to load profile',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${error.toString()}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref.invalidate(profileStreamProvider);
                            },
                            child: const Text('Retry'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => context.push('/profile-setup'),
                            child: const Text('Setup Profile'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Menu
              _ProfileMenuItem(
                icon: Icons.bar_chart,
                title: 'Progress Analytics',
                subtitle: 'Track your stats over time',
                onTap: () => context.push('/progress'),
              ),
              _ProfileMenuItem(
                icon: Icons.settings,
                title: 'Settings',
                subtitle: 'Notifications, Theme, Account',
                onTap: () => context.push('/settings'),
              ),
               _ProfileMenuItem(
                icon: Icons.info_outline,
                title: 'Help & Support',
                 onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact support@aifit.com')));
                 },
              ),
               const SizedBox(height: 24),
               
               // Logout
               SizedBox(
                 width: double.infinity,
                 child: OutlinedButton(
                   onPressed: () async {
                     await ref.read(authRepositoryProvider).signOut();
                     if (context.mounted) {
                       context.go('/login');
                     }
                   },
                   style: OutlinedButton.styleFrom(
                     foregroundColor: AppColors.accent,
                     side: const BorderSide(color: AppColors.accent),
                     padding: const EdgeInsets.symmetric(vertical: 16),
                   ),
                   child: const Text("Logout"),
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileDetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  
  const _ProfileDetailCard({required this.title, required this.children});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            )),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _DetailRow({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

final profileStreamProvider = StreamProvider<UserProfile?>((ref) {
  try {
    return ref.read(profileRepositoryProvider).watchProfile();
  } catch (e) {
    // Return empty stream on error
    return Stream.value(null);
  }
});

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
