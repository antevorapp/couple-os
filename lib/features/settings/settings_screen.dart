import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';

final partnerNameProvider = StateProvider<String>((ref) => '');

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _partnerNameController = TextEditingController();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _partnerNameController.text = prefs.getString('partner_name') ?? '';
    });
  }

  Future<void> _savePartnerName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('partner_name', _partnerNameController.text.trim());
    ref.read(partnerNameProvider.notifier).state = _partnerNameController.text.trim();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaydedildi'), backgroundColor: AppTheme.primary),
      );
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/auth');
  }

  @override
  void dispose() {
    _partnerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            'Profil',
            [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: AppTheme.primary),
                ),
                title: Text(user?.email ?? 'Kullanıcı'),
                subtitle: Text(
                  user?.id.substring(0, 16) ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),
          _buildSection(
            'Partner',
            [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _partnerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Partnerinizin adı',
                          prefixIcon:
                              Icon(Icons.favorite_outline, color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.check, color: AppTheme.primary),
                      onPressed: _savePartnerName,
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          _buildSection(
            'Tercihler',
            [
              SwitchListTile(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeThumbColor: AppTheme.primary,
                title: const Text('Bildirimler'),
                subtitle: Text(
                  'Mesaj ve skor bildirimlerini al',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                secondary: const Icon(Icons.notifications_outlined,
                    color: AppTheme.textSecondary),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Çıkış Yap'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
              foregroundColor: Colors.redAccent,
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Couple OS v1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}
