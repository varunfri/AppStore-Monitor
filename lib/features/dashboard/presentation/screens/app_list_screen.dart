import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/config_screen.dart';
import '../providers/dashboard_provider.dart';
import 'app_detail_screen.dart';

class AppListScreen extends StatefulWidget {
  const AppListScreen({super.key});

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadApps();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Apps'),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              child: const Icon(CupertinoIcons.settings, size: 22),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const ConfigScreen(),
                  ),
                );
              },
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              child: const Icon(CupertinoIcons.square_arrow_right, size: 22),
              onPressed: () {
                _showDisconnectDialog(context, authProvider);
              },
            ),
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () => dashboardProvider.loadApps(),
          ),
          SliverSafeArea(
            top: false,
            sliver: _buildSliverBody(context, dashboardProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverBody(BuildContext context, DashboardProvider provider) {
    if (provider.isLoadingApps) {
      return const SliverFillRemaining(
        child: Center(child: CupertinoActivityIndicator(radius: 14)),
      );
    }

    if (provider.appsError != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  color: CupertinoColors.systemRed,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to Load Apps',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                provider.appsError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CupertinoColors.secondaryLabel,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                borderRadius: BorderRadius.circular(8),
                onPressed: () => provider.loadApps(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.apps.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.cloud,
                color: CupertinoColors.systemGrey,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'No Apps Found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'There are no applications associated with this Apple Developer Account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        CupertinoListSection.insetGrouped(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: provider.apps.map((app) {
            final storeVersions = provider.getAppStoreVersions(app.id) ?? [];
            return CupertinoListTile.notched(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => AppDetailScreen(app: app),
                  ),
                );
              },
              leading: app.iconUrl != null
                  ? Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(app.iconUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            CupertinoColors.systemBlue,
                            CupertinoColors.systemPurple,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.device_phone_portrait,
                        color: CupertinoColors.white,
                        size: 22,
                      ),
                    ),
              title: Text(
                app.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${app.bundleId} • SKU: ${app.sku}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  if (storeVersions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${storeVersions.first.versionString} (${storeVersions.first.statusText})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getVersionStateColor(
                          storeVersions.first.appStoreState,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              trailing: const CupertinoListTileChevron(),
            );
          }).toList(),
        ),
      ]),
    );
  }

  void _showDisconnectDialog(BuildContext context, AuthProvider authProvider) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Disconnect Account?'),
        content: const Text(
          'This will securely delete all App Store Connect credentials stored on this device. You will need to re-configure them to access the dashboard.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              authProvider.clearCredentials();
            },
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  Color _getVersionStateColor(String state) {
    switch (state.toUpperCase()) {
      case 'READY_FOR_SALE':
        return CupertinoColors.activeGreen;
      case 'IN_REVIEW':
        return CupertinoColors.activeOrange;
      case 'WAITING_FOR_REVIEW':
      case 'READY_FOR_REVIEW':
        return CupertinoColors.activeBlue;
      case 'REJECTED':
      case 'METADATA_REJECTED':
      case 'DEVELOPER_REJECTED':
        return CupertinoColors.destructiveRed;
      default:
        return CupertinoColors.secondaryLabel;
    }
  }
}
