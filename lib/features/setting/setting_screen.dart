import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../premium/premium_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _tapSound = false;
  bool _pushNotifications = false;

  // ── helpers ──────────────────────────────────────────────────
  void _shareApp() {
    SharePlus.instance.share(
      ShareParams(
        text:
            'Check out Flirty Messages & Pickup Lines app! 💌\nhttps://play.google.com/store',
      ),
    );
  }

  void _openPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy coming soon!')),
    );
  }

  Future<void> _openLanguages() async {
    // Placeholder — hook up locale/language picker when ready
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language selection coming soon!')),
    );
  }

  // ── build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // ── Premium banner ────────────────────────────────────
          _PremiumBanner(
            onGetPremium: () => showPremiumDialog(context),
          ),

          const SizedBox(height: 24),

          // ── Settings tiles ────────────────────────────────────
          _SettingsCard(
            children: [
              _ToggleTile(
                icon: Icons.volume_up_outlined,
                label: 'Tap Sound',
                value: _tapSound,
                onChanged: (v) => setState(() => _tapSound = v),
              ),
              const _Divider(),
              _ToggleTile(
                icon: Icons.notifications_none_outlined,
                label: 'Push Notifications',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _SettingsCard(
            children: [
              _ArrowTile(
                icon: Icons.language_outlined,
                label: 'Languages',
                onTap: _openLanguages,
              ),
              const _Divider(),
              _ArrowTile(
                icon: Icons.share_outlined,
                label: 'Share App',
                onTap: _shareApp,
              ),
              const _Divider(),
              _ArrowTile(
                icon: Icons.shield_outlined,
                label: 'Privacy Policy',
                onTap: _openPrivacyPolicy,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Premium Banner
// ════════════════════════════════════════════════════════════════
class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({required this.onGetPremium});

  final VoidCallback onGetPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B21E8), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B21E8).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          // Crown emoji / icon
          const Text('👑', style: TextStyle(fontSize: 52)),

          const SizedBox(width: 14),

          // Text + button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flirty Messages & Pickup Lines',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Flirty lines & sweet messages to impress instantly.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onGetPremium,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Get Premium',
                      style: TextStyle(
                        color: Color(0xFF6B21E8),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Helpers
// ════════════════════════════════════════════════════════════════
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7C3AED),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}

class _ArrowTile extends StatelessWidget {
  const _ArrowTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 54, endIndent: 16);
  }
}
