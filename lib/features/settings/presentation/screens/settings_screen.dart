import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../setup/presentation/providers/setup_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _prefixController = TextEditingController();
  final _footerController = TextEditingController();

  String _selectedLanguage = 'en';
  String _selectedTheme = 'system';
  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _prefixController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _populateFromSettings(dynamic settings) {
    if (settings != null && !_isInitialized) {
      _nameController.text = settings.shopName ?? '';
      _phoneController.text = settings.phone ?? '';
      _addressController.text = settings.address ?? '';
      _prefixController.text = settings.invoicePrefix ?? 'INV-';
      _footerController.text = settings.receiptFooter ?? '';
      _selectedLanguage = settings.language ?? 'en';
      _selectedTheme = settings.themeMode ?? 'system';
      _isInitialized = true;
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final repo = ref.read(setupRepositoryProvider);
    final l10n = AppLocalizations.of(context);

    try {
      await repo.updateSettings(
        shopName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        invoicePrefix: _prefixController.text.trim().isEmpty
            ? 'INV-'
            : _prefixController.text.trim(),
        receiptFooter: _footerController.text.trim().isEmpty
            ? null
            : _footerController.text.trim(),
        language: _selectedLanguage,
        themeMode: _selectedTheme,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsSaved),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(shopSettingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: settingsAsync.when(
        data: (settings) {
          _populateFromSettings(settings);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsetsDirectional.all(kSpaceM),
              children: [
                // ── Shop Information Section ─────────────────────────────────
                _SectionHeader(title: l10n.shopInfoSection),
                const SizedBox(height: kSpaceS),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(kSpaceM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: l10n.shopNameLabel,
                            prefixIcon: const Icon(Icons.storefront_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.errorRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: kSpaceM),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: l10n.phoneLabel,
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: kSpaceM),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: l10n.addressLabel,
                            prefixIcon: const Icon(Icons.location_on_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: kSpaceL),

                // ── Invoice & Receipt Section ────────────────────────────────
                _SectionHeader(title: l10n.invoiceSection),
                const SizedBox(height: kSpaceS),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(kSpaceM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _prefixController,
                          decoration: InputDecoration(
                            labelText: l10n.invoicePrefixLabel,
                            prefixIcon: const Icon(Icons.tag_outlined),
                            hintText: 'INV-',
                          ),
                        ),
                        const SizedBox(height: kSpaceM),
                        TextFormField(
                          controller: _footerController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: l10n.receiptFooterLabel,
                            prefixIcon: const Icon(Icons.notes_outlined),
                            hintText: l10n.receiptThankYou,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: kSpaceL),

                // ── Appearance Section ───────────────────────────────────────
                _SectionHeader(title: l10n.appearanceSection),
                const SizedBox(height: kSpaceS),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(kSpaceM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedLanguage,
                          decoration: InputDecoration(
                            labelText: l10n.languageLabel,
                            prefixIcon: const Icon(Icons.language_outlined),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(l10n.languageEnglish),
                            ),
                            DropdownMenuItem(
                              value: 'ur',
                              child: Text(l10n.languageUrdu),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedLanguage = val);
                              ref
                                  .read(setupRepositoryProvider)
                                  .setLanguage(val);
                            }
                          },
                        ),
                        const SizedBox(height: kSpaceM),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedTheme,
                          decoration: InputDecoration(
                            labelText: l10n.themeModeLabel,
                            prefixIcon:
                                const Icon(Icons.brightness_medium_outlined),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'system',
                              child: Text(l10n.themeModeSystem),
                            ),
                            DropdownMenuItem(
                              value: 'light',
                              child: Text(l10n.themeModeLight),
                            ),
                            DropdownMenuItem(
                              value: 'dark',
                              child: Text(l10n.themeModeDark),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedTheme = val);
                              ref
                                  .read(setupRepositoryProvider)
                                  .setThemeMode(val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: kSpaceL),

                // ── Data Management Section ──────────────────────────────────
                _SectionHeader(title: l10n.dataSection),
                const SizedBox(height: kSpaceS),
                AppCard(
                  title: Text(l10n.backupAndRestore),
                  subtitle: Text(l10n.backupSubtitle),
                  leading: const Icon(Icons.cloud_sync_outlined,
                      color: AppColors.primary),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/backup'),
                ),

                const SizedBox(height: kSpaceXL),

                // ── Save Button ──────────────────────────────────────────────
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.btnSave),
                ),

                const SizedBox(height: kSpaceL),

                // ── Version Info ─────────────────────────────────────────────
                Center(
                  child: Text(
                    l10n.version('1.0.0'),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: kSpaceM),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: kSpaceXS),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
