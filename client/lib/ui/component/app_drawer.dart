import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.isTalkSelected,
    required this.isJobMarketSelected,
    required this.onSelectTalk,
    required this.onSelectJobMarket,
    required this.onSelectSettings,
  });

  final bool isTalkSelected;
  final bool isJobMarketSelected;
  final VoidCallback onSelectTalk;
  final VoidCallback onSelectJobMarket;
  final VoidCallback onSelectSettings;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(context),
            _buildTalkTile(context),
            _buildJobMarketTile(context),
            const Divider(),
            _buildSettingsTile(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return DrawerHeader(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          'メニュー',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildTalkTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.chat),
      title: const Text('トーク'),
      selected: isTalkSelected,
      onTap: () {
        Navigator.of(context).pop();
        if (!isTalkSelected) {
          onSelectTalk();
        }
      },
    );
  }

  Widget _buildJobMarketTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.work),
      title: const Text('転職市場'),
      selected: isJobMarketSelected,
      onTap: () {
        Navigator.of(context).pop();
        if (!isJobMarketSelected) {
          onSelectJobMarket();
        }
      },
    );
  }

  Widget _buildSettingsTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: const Text('設定'),
      onTap: () {
        Navigator.of(context).pop();
        onSelectSettings();
      },
    );
  }
}
