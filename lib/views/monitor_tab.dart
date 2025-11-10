import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/monitor_controller.dart';
import '../models/preferences.dart';

class MonitorTab extends StatefulWidget {
  const MonitorTab({super.key});

  @override
  State<MonitorTab> createState() => _MonitorTabState();
}

class _MonitorTabState extends State<MonitorTab> {
  final TextEditingController _domainController = TextEditingController();
  final TextEditingController _prefixController = TextEditingController();
  late MonitorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MonitorController();
    _loadDomainAndPrefix();
  }

  Future<void> _loadDomainAndPrefix() async {
    final domain = await Preferences.loadApiUrl();
    final prefix = await Preferences.loadApiUrlPrefix();
    if (mounted) {
      setState(() {
        _domainController.text = domain;
        _prefixController.text = prefix;
      });
    }
  }

  Future<void> _saveDomainAndPrefix() async {
    final domain = _domainController.text.trim();
    final prefix = _prefixController.text.trim();
    await Preferences.saveApiUrl(domain);
    await Preferences.saveApiUrlPrefix(prefix);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Domain and prefix saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MonitorController>.value(
      value: _controller,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monitor server status. Also use Insights and HealthCheckHandler.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _domainController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your domain e.g. mydomain.com',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _prefixController,
                    maxLength: 5,
                    decoration: const InputDecoration(
                      labelText: 'Subdomain Prefix e.g. ss for ss-api',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveDomainAndPrefix,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _controller.isLoading
                  ? null
                  : () {
                      final domain = _domainController.text.trim();
                      final prefix = _prefixController.text.trim();
                      if (domain.isNotEmpty) {
                        final apiSubdomain =
                            prefix.isNotEmpty ? '$prefix-api' : 'api';
                        final insightsSubdomain = prefix.isNotEmpty
                            ? '$prefix-insights'
                            : 'insights';
                        const webAppSubdomain = 'www';

                        _controller.checkAllServerpodDomains(
                          apiUrl: 'https://$apiSubdomain.$domain',
                          webAppUrl: 'https://$webAppSubdomain.$domain',
                          insightsUrl: 'https://$insightsSubdomain.$domain',
                        );
                      }
                    },
              child: _controller.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Check All Domains'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<MonitorController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.results == null) {
                    return const Text('No results yet.');
                  }

                  return SingleChildScrollView(
                    child: Table(
                      border: TableBorder.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha((0.5 * 255).round()),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(3),
                        2: FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Check',
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Domain',
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Result',
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                            ),
                          ],
                        ),
                        if (controller.results!.isNotEmpty)
                          ...controller.results!.entries.map(
                            (entry) {
                              String url = '';
                              switch (entry.key) {
                                case 'API':
                                case 'TLS':
                                  url = controller.lastApiUrl ?? '';
                                  break;
                                case 'WebApp':
                                  url = controller.lastWebAppUrl ?? '';
                                  break;
                                case 'Insights':
                                  url = controller.lastInsightsUrl ?? '';
                                  break;
                              }
                              final bool hasError = entry.value.contains('Error') ||
                                  entry.value.contains('Failed') ||
                                  entry.value.contains('Exception') ||
                                  entry.value.contains('timed out');
                              final Color rowColor = hasError
                                  ? Colors.red.withAlpha((0.2 * 255).round())
                                  : Colors.green.withAlpha((0.2 * 255).round());

                              return TableRow(
                                decoration: BoxDecoration(color: rowColor),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SelectableText(entry.key),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SelectableText(url),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SelectableText(entry.value),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
