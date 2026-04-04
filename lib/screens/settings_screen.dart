import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/providers/ai_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _language = 'English';
  String _aiModel = 'None (Fallback Mode)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Info
          _buildAppInfoCard(),
          
          const SizedBox(height: 24),
          
          // Appearance
          _buildSectionTitle('Appearance'),
          _buildSettingsCard([
            _buildSwitchTile(
              'Dark Mode',
              'Enable dark theme',
              Icons.dark_mode,
              _darkMode,
              (value) => setState(() => _darkMode = value),
            ),
          ]),
          
          const SizedBox(height: 16),
          
          // AI Settings
          _buildSectionTitle('AI Assistant'),
          _buildSettingsCard([
            _buildInfoTile(
              'AI Model',
              _aiModel,
              Icons.smart_toy,
              () => _showAIModelDialog(),
            ),
            _buildInfoTile(
              'Model Status',
              context.watch<AIProvider>().isInitialized ? 'Active' : 'Offline',
              Icons.info,
              null,
            ),
          ]),
          
          const SizedBox(height: 16),
          
          // Notifications
          _buildSectionTitle('Notifications'),
          _buildSettingsCard([
            _buildSwitchTile(
              'Push Notifications',
              'Receive alerts for high-risk patients',
              Icons.notifications,
              _notifications,
              (value) => setState(() => _notifications = value),
            ),
          ]),
          
          const SizedBox(height: 16),
          
          // Language
          _buildSectionTitle('Language'),
          _buildSettingsCard([
            _buildInfoTile(
              'Display Language',
              _language,
              Icons.language,
              () => _showLanguageDialog(),
            ),
          ]),
          
          const SizedBox(height: 16),
          
          // Data & Privacy
          _buildSectionTitle('Data & Privacy'),
          _buildSettingsCard([
            _buildInfoTile(
              'Export Data',
              'Download all patient data',
              Icons.download,
              () => _exportData(),
            ),
            _buildInfoTile(
              'Clear Cache',
              'Free up storage space',
              Icons.cleaning_services,
              () => _clearCache(),
            ),
          ]),
          
          const SizedBox(height: 16),
          
          // About
          _buildSectionTitle('About'),
          _buildSettingsCard([
            _buildInfoTile(
              'Version',
              '1.0.0',
              Icons.info,
              null,
            ),
            _buildInfoTile(
              'License',
              'MIT License',
              Icons.gavel,
              () => _showLicenseDialog(),
            ),
          ]),
          
          const SizedBox(height: 32),
          
          // Disclaimer
          _buildDisclaimerCard(),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.medical_services,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'NeuroScale Pro',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'AI Psychiatry Clinical System',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(value),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildDisclaimerCard() {
    return Card(
      color: AppTheme.warningColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning, color: AppTheme.warningColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clinical Disclaimer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warningColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'This app is a clinical support tool only. It does not replace professional psychiatric judgment. Always verify AI outputs and use alerts as guidance, not diagnosis.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAIModelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Model Selection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select an AI model for clinical text generation:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text('TinyLlama (Recommended)'),
              subtitle: const Text('1.1B parameters, fast inference'),
              onTap: () {
                setState(() => _aiModel = 'TinyLlama 1.1B');
                Navigator.pop(context);
                _initializeAI('tinyllama.gguf');
              },
            ),
            ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text('Phi-2'),
              subtitle: const Text('2.7B parameters, better quality'),
              onTap: () {
                setState(() => _aiModel = 'Phi-2');
                Navigator.pop(context);
                _initializeAI('phi2.gguf');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_off),
              title: const Text('Offline Mode'),
              subtitle: const Text('Use basic fallback responses'),
              onTap: () {
                setState(() => _aiModel = 'None (Fallback Mode)');
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'English',
            'Tamil',
            'Hindi',
            'Spanish',
            'French',
          ].map((lang) {
            return RadioListTile<String>(
              value: lang,
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
              title: Text(lang),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLicenseDialog() {
    showLicensePage(
      context: context,
      applicationName: 'NeuroScale Pro',
      applicationVersion: '1.0.0',
      applicationLegalese: 'MIT License - Copyright 2024',
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting data...')),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared')),
    );
  }

  void _initializeAI(String modelPath) {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    aiProvider.initialize(modelPath: modelPath);
  }
}