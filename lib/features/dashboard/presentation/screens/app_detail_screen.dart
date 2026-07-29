import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../data/models/app_model.dart';
import '../../data/models/build_model.dart';
import '../../data/models/prerelease_model.dart';
import '../../data/models/customer_review_model.dart';
import '../providers/dashboard_provider.dart';

class AppDetailScreen extends StatefulWidget {
  final AppModel app;

  const AppDetailScreen({super.key, required this.app});

  @override
  State<AppDetailScreen> createState() => _AppDetailScreenState();
}

enum BuildSortOption { date, version }

class _AppDetailScreenState extends State<AppDetailScreen> {
  BuildSortOption _buildSortOption = BuildSortOption.date;
  int _selectedSegment = 0;

  int _compareVersions(String v1, String v2) {
    final regExp = RegExp(r'[^\d.]');
    final cleanV1 = v1.replaceAll(regExp, '');
    final cleanV2 = v2.replaceAll(regExp, '');

    final parts1 = cleanV1.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final parts2 = cleanV2.split('.').map((p) => int.tryParse(p) ?? 0).toList();

    final maxLen = parts1.length > parts2.length
        ? parts1.length
        : parts2.length;
    for (var i = 0; i < maxLen; i++) {
      final val1 = i < parts1.length ? parts1[i] : 0;
      final val2 = i < parts2.length ? parts2[i] : 0;
      if (val1 != val2) {
        return val1.compareTo(val2);
      }
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).loadAppDetails(widget.app.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final isLoading = provider.isLoadingDetails(widget.app.id);
    final error = provider.getDetailsError(widget.app.id);
    final builds = provider.getBuilds(widget.app.id) ?? [];
    final preReleases = provider.getPreReleases(widget.app.id) ?? [];
    final reviews = provider.getReviews(widget.app.id) ?? [];
    final storeVersions = provider.getAppStoreVersions(widget.app.id) ?? [];
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(widget.app.name)),
      child: SafeArea(
        child: Column(
          children: [
            // App Header Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark
                  ? const Color(0xFF1C1C1E)
                  : CupertinoColors.secondarySystemGroupedBackground,
              child: Row(
                children: [
                  widget.app.iconUrl != null
                      ? Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(widget.app.iconUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                CupertinoColors.systemBlue,
                                CupertinoColors.systemPurple,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            CupertinoIcons.square_stack_3d_up,
                            color: CupertinoColors.white,
                            size: 26,
                          ),
                        ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.app.bundleId,
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'SKU: ${widget.app.sku}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey2,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (storeVersions.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getVersionStateColor(
                                    storeVersions.first.appStoreState,
                                  ).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _getVersionStateColor(
                                      storeVersions.first.appStoreState,
                                    ).withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  'Version ${storeVersions.first.versionString}: ${storeVersions.first.statusText}',
                                  style: TextStyle(
                                    color: _getVersionStateColor(
                                      storeVersions.first.appStoreState,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Selector using CupertinoSlidingSegmentedControl
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              width: double.infinity,
              color: isDark
                  ? CupertinoColors.black
                  : CupertinoColors.systemBackground,
              child: Center(
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _selectedSegment,
                  onValueChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSegment = value;
                      });
                    }
                  },
                  children: const {
                    0: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Text(
                        'TestFlight',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    1: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Text(
                        'Builds',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    2: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  },
                ),
              ),
            ),

            Container(height: 0.5, color: CupertinoColors.separator),

            Expanded(
              child: _buildDetailsBody(
                context,
                isLoading,
                error,
                builds,
                preReleases,
                reviews,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsBody(
    BuildContext context,
    bool isLoading,
    String? error,
    List<BuildModel> builds,
    List<PreReleaseModel> preReleases,
    List<CustomerReviewModel> reviews,
  ) {
    if (isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    if (error != null) {
      return Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.cloud,
                color: CupertinoColors.destructiveRed,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to Load Details',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CupertinoColors.secondaryLabel,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                borderRadius: BorderRadius.circular(8),
                onPressed: () => Provider.of<DashboardProvider>(
                  context,
                  listen: false,
                ).loadAppDetails(widget.app.id),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    switch (_selectedSegment) {
      case 0:
        return _buildPreReleasesList(preReleases, builds);
      case 1:
        return _buildBuildsList(builds);
      case 2:
        return _buildReviewsList(reviews);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPreReleasesList(
    List<PreReleaseModel> preReleases,
    List<BuildModel> builds,
  ) {
    if (preReleases.isEmpty) {
      return _buildEmptyState(
        'No Prerelease Versions',
        'Pre-release versions will appear here once uploaded.',
        CupertinoIcons.rocket,
      );
    }
    final sortedPreReleaseBuilds = List<PreReleaseModel>.from(preReleases);
    sortedPreReleaseBuilds.sort((a, b) {
      return _compareVersions(b.version, a.version); // Highest version first
    });

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        CupertinoListSection.insetGrouped(
          children: sortedPreReleaseBuilds.map((version) {
            // Find latest build for this pre-release version
            final matchingBuilds = builds
                .where((b) => b.appVersion == version.version)
                .toList();
            if (matchingBuilds.isNotEmpty) {
              matchingBuilds.sort(
                (a, b) => _compareVersions(b.version, a.version),
              ); // Highest build first
            }
            final latestBuild = matchingBuilds.isNotEmpty
                ? matchingBuilds.first
                : null;
            final displayVersion = latestBuild != null
                ? '${version.version}+${latestBuild.version}'
                : version.version;

            return CupertinoListTile.notched(
              leading: const Icon(
                CupertinoIcons.rocket,
                color: CupertinoColors.activeBlue,
              ),
              title: Text(
                'Version $displayVersion',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Platform: ${version.platform}'),
              additionalInfo: const Text(
                'Active',
                style: TextStyle(
                  color: CupertinoColors.activeGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBuildsList(List<BuildModel> builds) {
    if (builds.isEmpty) {
      return _buildEmptyState(
        'No Builds Found',
        'Builds uploaded via Xcode or Transporter will appear here.',
        CupertinoIcons.time,
      );
    }

    final sortedBuilds = List<BuildModel>.from(builds);
    if (_buildSortOption == BuildSortOption.date) {
      sortedBuilds.sort((a, b) {
        final dateA = a.uploadedDate ?? DateTime(0);
        final dateB = b.uploadedDate ?? DateTime(0);
        return dateB.compareTo(dateA); // Newest first
      });
    } else {
      sortedBuilds.sort((a, b) {
        return _compareVersions(b.version, a.version); // Highest version first
      });
    }

    return Column(
      children: [
        // Cupertino style Sort selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sort Builds:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemGrey2,
                ),
              ),
              CupertinoSlidingSegmentedControl<BuildSortOption>(
                groupValue: _buildSortOption,
                onValueChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _buildSortOption = value;
                    });
                  }
                },
                children: const {
                  BuildSortOption.date: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      'Upload Date',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  BuildSortOption.version: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      'Version',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                },
              ),
            ],
          ),
        ),
        Container(height: 0.5, color: CupertinoColors.separator),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              CupertinoListSection.insetGrouped(
                children: sortedBuilds.map((build) {
                  final formattedDate = build.uploadedDate != null
                      ? '${build.uploadedDate!.year}-${build.uploadedDate!.month.toString().padLeft(2, '0')}-${build.uploadedDate!.day.toString().padLeft(2, '0')} ${build.uploadedDate!.hour.toString().padLeft(2, '0')}:${build.uploadedDate!.minute.toString().padLeft(2, '0')}'
                      : 'Unknown Upload Date';

                  Color statusColor = CupertinoColors.secondaryLabel;
                  IconData statusIcon = CupertinoIcons.question_circle;

                  if (build.expired) {
                    statusColor = CupertinoColors.destructiveRed;
                    statusIcon = CupertinoIcons.clear_circled;
                  } else {
                    switch (build.processingState.toUpperCase()) {
                      case 'PROCESSING':
                        statusColor = CupertinoColors.activeOrange;
                        statusIcon = CupertinoIcons.hourglass;
                        break;
                      case 'VALID':
                        statusColor = CupertinoColors.activeGreen;
                        statusIcon = CupertinoIcons.check_mark_circled;
                        break;
                      case 'INVALID':
                        statusColor = CupertinoColors.destructiveRed;
                        statusIcon = CupertinoIcons.exclamationmark_circle;
                        break;
                    }
                  }

                  return CupertinoListTile.notched(
                    title: Text(
                      build.appVersion != null
                          ? '${build.appVersion}+${build.version}'
                          : 'Build ${build.version}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      build.appVersion != null
                          ? 'Build ${build.version} • $formattedDate'
                          : formattedDate,
                    ),
                    additionalInfo: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          build.statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList(List<CustomerReviewModel> reviews) {
    if (reviews.isEmpty) {
      return _buildEmptyState(
        'No Reviews',
        'Customer reviews left on the App Store will appear here.',
        CupertinoIcons.star,
      );
    }

    final avgRating =
        reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        // Summary Bar
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E)
                : CupertinoColors.secondarySystemGroupedBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.activeOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'out of 5.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${reviews.length} Review${reviews.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      final starVal = index + 1;
                      return Icon(
                        starVal <= avgRating.round()
                            ? CupertinoIcons.star_fill
                            : CupertinoIcons.star,
                        color: CupertinoColors.activeOrange,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Reviews list
        ...reviews.map((review) {
          final dateStr = review.createdDate != null
              ? '${review.createdDate!.year}-${review.createdDate!.month.toString().padLeft(2, '0')}-${review.createdDate!.day.toString().padLeft(2, '0')}'
              : 'Unknown Date';

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1C1C1E)
                  : CupertinoColors.secondarySystemGroupedBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.reviewerNickname,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2C2E)
                            : CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        review.territory,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(5, (starIdx) {
                    return Icon(
                      starIdx < review.rating
                          ? CupertinoIcons.star_fill
                          : CupertinoIcons.star,
                      color: CupertinoColors.activeOrange,
                      size: 14,
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Text(
                  review.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  review.body,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? CupertinoColors.lightBackgroundGray
                        : CupertinoColors.darkBackgroundGray,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: CupertinoColors.systemGrey.withOpacity(0.5),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
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
