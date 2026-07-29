import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _issuerIdController = TextEditingController();
  final _keyIdController = TextEditingController();
  final _privateKeyController = TextEditingController();
  bool _obscurePrivateKey = true;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      if (provider.issuerId != null) {
        _issuerIdController.text = provider.issuerId!;
      }
      if (provider.keyId != null) {
        _keyIdController.text = provider.keyId!;
      }
      if (provider.privateKey != null) {
        _privateKeyController.text = provider.privateKey!;
      }
    });
  }

  @override
  void dispose() {
    _issuerIdController.dispose();
    _keyIdController.dispose();
    _privateKeyController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() {
      _validationError = null;
    });

    final issuerId = _issuerIdController.text.trim();
    final keyId = _keyIdController.text.trim();
    final privateKey = _privateKeyController.text.trim();

    if (issuerId.isEmpty || keyId.isEmpty || privateKey.isEmpty) {
      setState(() {
        _validationError = 'All configuration fields are required.';
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyAndSaveCredentials(
      issuerId: issuerId,
      keyId: keyId,
      privateKey: privateKey,
    );

    if (success && mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Credentials Saved'),
          content: const Text(
            'Your developer API credentials have been verified and saved securely to the system keychain.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                if (authProvider.isAuthenticated) {
                  // If we are already authenticated (i.e. editing existing credentials), pop screen
                  Navigator.of(context).maybePop();
                }
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    final labelStyle = TextStyle(
      color: isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey2,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Credentials'),
        trailing: authProvider.isAuthenticated
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Branding Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.shield,
                      size: 56,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'App Store Connect',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Local Credentials Configuration',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Inset Grouped Settings Box
                Center(
                  child: CupertinoListSection.insetGrouped(
                    header: Center(child: const Text('API CREDENTIALS')),
                    footer: Center(
                      child: const Text(
                        'Keys never leave your device. All signing occurs locally.',
                        style: TextStyle(fontSize: 12),
                        textAlign: .center,
                      ),
                    ),
                    children: [
                      // Issuer ID Field
                      CupertinoListTile(
                        title: Text('Issuer ID', style: labelStyle),
                        subtitle: CupertinoTextField(
                          controller: _issuerIdController,
                          placeholder: '572465eb-c373-4c00-90f1-000000000000',
                          decoration: null, // Transparent inside list tile
                          clearButtonMode: OverlayVisibilityMode.editing,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      // Key ID Field
                      CupertinoListTile(
                        title: Text('Key ID', style: labelStyle),
                        subtitle: CupertinoTextField(
                          controller: _keyIdController,
                          placeholder: '2A3B4C5D6E',
                          decoration: null,
                          clearButtonMode: OverlayVisibilityMode.editing,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      // Private Key Field
                      CupertinoListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Private Key (.p8 contents)',
                              style: labelStyle,
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 0,
                              onPressed: () {
                                setState(() {
                                  _obscurePrivateKey = !_obscurePrivateKey;
                                });
                              },
                              child: Icon(
                                _obscurePrivateKey
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                                size: 18,
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: CupertinoTextField(
                            controller: _privateKeyController,
                            placeholder:
                                '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----',
                            maxLines: _obscurePrivateKey ? 1 : 8,
                            obscureText: _obscurePrivateKey,
                            decoration: null,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Validation/API Errors
                if (_validationError != null ||
                    authProvider.errorMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      _validationError ?? authProvider.errorMessage!,
                      style: const TextStyle(
                        color: CupertinoColors.systemRed,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: authProvider.isLoading
                      ? const Center(
                          child: CupertinoActivityIndicator(radius: 12),
                        )
                      : CupertinoButton.filled(
                          onPressed: _submitForm,
                          borderRadius: BorderRadius.circular(10),
                          child: const Text(
                            'Save & Verify',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
