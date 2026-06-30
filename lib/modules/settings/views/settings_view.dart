import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../core/widgets/app_logo.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final TextEditingController cityTextController = TextEditingController(
      text: controller.defaultCity.value,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand Logo Header
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: AppLogo(size: 80, showText: true),
              ),
            ),
            const SizedBox(height: 16),
            // Theme settings card
            _buildSectionHeader(theme, 'Appearance'),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outline.withOpacity(0.15)),
              ),
              child: Obx(() {
                return SwitchListTile(
                  secondary: Icon(
                    controller.isDarkMode.value ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Dark Theme Mode'),
                  subtitle: Text(
                    controller.isDarkMode.value ? 'Using dark color palette' : 'Using light color palette',
                  ),
                  value: controller.isDarkMode.value,
                  onChanged: (bool val) {
                    controller.toggleThemeMode(val);
                  },
                );
              }),
            ),
            const SizedBox(height: 24),

            // Weather configurations card
            _buildSectionHeader(theme, 'Weather Configuration'),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outline.withOpacity(0.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_city_rounded, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Default Search City',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure a default city to load weather information automatically on launch when GPS is disabled.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cityTextController,
                            decoration: InputDecoration(
                              hintText: 'Enter city name (e.g. London)',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.primary, width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final input = cityTextController.text.trim();
                            if (input.isEmpty) {
                              Get.rawSnackbar(
                                message: 'Please enter a city name',
                                duration: const Duration(seconds: 2),
                                backgroundColor: theme.colorScheme.errorContainer,
                                messageText: Text(
                                  'Please enter a city name',
                                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                                ),
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }
                            await controller.updateDefaultCity(input);
                            
                            // Re-trigger weather fetch on the dashboard using default city
                            try {
                              final dashCtrl = Get.find<DashboardController>();
                              dashCtrl.fetchWeatherByCity(input);
                            } catch (_) {
                              // Dashboard controller not initialized yet
                            }

                            Get.rawSnackbar(
                              message: 'Default city saved successfully',
                              duration: const Duration(seconds: 2),
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.save_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // About application card
            _buildSectionHeader(theme, 'About App'),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outline.withOpacity(0.15)),
              ),
              child: Obx(() {
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.info_outline_rounded, color: colorScheme.primary),
                      title: const Text('App Version'),
                      trailing: Text(
                        controller.appVersion.value,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 0.5, thickness: 0.5),
                    ListTile(
                      leading: Icon(Icons.tag_rounded, color: colorScheme.primary),
                      title: const Text('Build Number'),
                      trailing: Text(
                        controller.buildNumber.value,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
