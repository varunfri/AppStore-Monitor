import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../core/error/error_logger.dart';

class ErrorLoggerOverlay extends StatefulWidget {
  final Widget child;

  const ErrorLoggerOverlay({super.key, required this.child});

  @override
  State<ErrorLoggerOverlay> createState() => _ErrorLoggerOverlayState();
}

class _ErrorLoggerOverlayState extends State<ErrorLoggerOverlay> {
  bool _isConsoleVisible = false;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Stack(
      children: [
        // Main App UI
        widget.child,

        // Floating Debug Button
        Consumer<ErrorLogger>(
          builder: (context, logger, _) {
            if (logger.logs.isEmpty) return const SizedBox.shrink();

            final authErrorsCount = logger.logs
                .where((l) => l.isAuthError)
                .length;

            return Positioned(
              right: 16,
              bottom: 40,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: authErrorsCount > 0
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemOrange,
                borderRadius: BorderRadius.circular(20),
                onPressed: () {
                  setState(() {
                    _isConsoleVisible = true;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.ant_fill,
                      color: CupertinoColors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      authErrorsCount > 0
                          ? '$authErrorsCount Auth Alerts'
                          : '${logger.logs.length} Network Issues',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Custom Stack-based Console Overlay Sheet
        if (_isConsoleVisible)
          Positioned.fill(
            child: Stack(
              children: [
                // Dimmed tapping barrier to close
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isConsoleVisible = false;
                    });
                  },
                  child: Container(
                    color: CupertinoColors.black.withOpacity(0.5),
                  ),
                ),
                // Sliding Sheet content
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.85,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1C1E)
                            : CupertinoColors.secondarySystemBackground,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.black.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Sheet Drag Handle Indicator
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            width: 36,
                            height: 5,
                            decoration: BoxDecoration(
                              color: CupertinoColors.separator,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                          // Header title bar
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.device_laptop,
                                      color: CupertinoColors.activeGreen,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Console Logger',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Consumer<ErrorLogger>(
                                      builder: (context, logger, _) =>
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            minSize: 0,
                                            onPressed: () {
                                              logger.clearLogs();
                                              setState(() {
                                                _isConsoleVisible = false;
                                              });
                                            },
                                            child: const Text(
                                              'Clear',
                                              style: TextStyle(
                                                color:
                                                    CupertinoColors.systemRed,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                    ),
                                    const SizedBox(width: 16),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      minSize: 0,
                                      child: Icon(
                                        CupertinoIcons.xmark_circle_fill,
                                        color: CupertinoColors.systemGrey,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isConsoleVisible = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 0.5,
                            color: CupertinoColors.separator,
                          ),

                          // Logs display area
                          Expanded(
                            child: Consumer<ErrorLogger>(
                              builder: (context, logger, _) {
                                if (logger.logs.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'No errors or logs recorded.',
                                      style: TextStyle(
                                        color: CupertinoColors.secondaryLabel,
                                        fontFamily: 'monospace',
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: logger.logs.length,
                                  itemBuilder: (context, index) {
                                    // Show latest log at top
                                    final log = logger
                                        .logs[logger.logs.length - 1 - index];
                                    return _ConsoleLogCard(log: log);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ConsoleLogCard extends StatefulWidget {
  final NetworkLog log;

  const _ConsoleLogCard({required this.log});

  @override
  State<_ConsoleLogCard> createState() => _ConsoleLogCardState();
}

class _ConsoleLogCardState extends State<_ConsoleLogCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasAuthError = widget.log.isAuthError;
    final accentColor = hasAuthError
        ? CupertinoColors.systemRed
        : CupertinoColors.systemOrange;
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2C2C2E)
            : CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Summary Row (Clickable)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.log.statusCode?.toString() ?? 'ERR',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${widget.log.method} ${Uri.parse(widget.log.url).path}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    color: CupertinoColors.secondaryLabel,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            Container(height: 0.5, color: CupertinoColors.separator),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timestamp
                  Text(
                    'Time: ${widget.log.timestamp.hour}:${widget.log.timestamp.minute.toString().padLeft(2, '0')}:${widget.log.timestamp.second.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Message Description
                  const Text(
                    'Message:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.log.message,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: CupertinoColors.systemRed,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Actionable Troubleshooting Tips
                  if (hasAuthError) ...[
                    const Text(
                      '💡 Actionable Troubleshooting Tips:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: CupertinoColors.activeGreen,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: CupertinoColors.activeGreen.withOpacity(0.2),
                        ),
                      ),
                      child: const Text(
                        '1. Verify Issuer ID and Key ID matching on App Store Connect portal.\n'
                        '2. Ensure Private Key contains correct -----BEGIN PRIVATE KEY----- headers.\n'
                        '3. Double-check device clock time. Since JWT signatures require Epoch timestamp, a mismatched device time causes immediate Apple rejection.',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // JWT Debug
                  if (widget.log.jwtUsed != null) ...[
                    const Text(
                      'JWT Bearer Token Used:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.log.jwtUsed!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: CupertinoColors.secondaryLabel,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minSize: 0,
                            onPressed: () {
                              _showDecodedJwtDialog(
                                context,
                                widget.log.jwtUsed!,
                              );
                            },
                            child: const Text(
                              'Decode JWT Local Payload',
                              style: TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Full Response Body (if exists)
                  if (widget.log.responseBody != null) ...[
                    const Text(
                      'Raw Server Response:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: CupertinoColors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          widget.log.responseBody!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDecodedJwtDialog(BuildContext context, String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) throw Exception('Invalid JWT format');

      String decodeBase64(String input) {
        var base64Str = input.replaceAll('-', '+').replaceAll('_', '/');
        while (base64Str.length % 4 != 0) {
          base64Str += '=';
        }
        final bytes = Uri.parse(
          'data:text/plain;base64,$base64Str',
        ).data!.contentAsBytes();
        return String.fromCharCodes(bytes);
      }

      final header = decodeBase64(parts[0]);
      final payload = decodeBase64(parts[1]);

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text(
            'Decoded JWT Claims',
            style: TextStyle(fontFamily: 'monospace'),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Header:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.activeGreen,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  color: CupertinoColors.black.withOpacity(0.3),
                  child: Text(
                    header,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Payload:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.activeGreen,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  color: CupertinoColors.black.withOpacity(0.3),
                  child: Text(
                    payload,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Decoding Failed'),
          content: Text(e.toString()),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }
}
