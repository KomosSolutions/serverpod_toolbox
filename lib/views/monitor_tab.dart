import 'package:flutter/material.dart';

import '../controllers/monitor_controller.dart';
import 'package:provider/provider.dart';

import '../models/preferences.dart';

class MonitorTab extends StatefulWidget {
    const MonitorTab({super.key});

    @override
    State<MonitorTab> createState() => _MonitorTabState();
}

class _MonitorTabState extends State<MonitorTab> {
    final TextEditingController _urlController = TextEditingController();
    late DateTimeController _controller;

    @override
    void initState() {
        super.initState();
        _controller = DateTimeController();
        _loadApiUrl();
    }

    Future<void> _loadApiUrl() async {
        final url = await Preferences.loadApiUrl();
        if (mounted) {
            setState(() {
                _urlController.text = url;
            });
        }
    }

    Future<void> _saveApiUrl() async {
        final url = _urlController.text.trim();
        await Preferences.saveApiUrl(url);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('API URL saved successfully')),
        );
    }

    @override
    Widget build(BuildContext context) {
        return ChangeNotifierProvider(
            create: (_) => _controller,
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Text(
                                'Monitor servers status. Also use insights and HealthCheckHandler',
                                style: Theme.of(context).textTheme.headlineSmall,
                            ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                            children: [
                                Expanded(
                                    child:    TextField(
                                controller: _urlController,
                                decoration: const InputDecoration(
                                    labelText: 'Enter API URL e.g. api-yourdomain.com',
                                    border: OutlineInputBorder(),
                                ),),
                            ),
                                SizedBox(width: 250,
                                    child: ElevatedButton(
                                        onPressed: _saveApiUrl,
                                        child: const Text('Save URL'),
                                    ),
                                ),   ],
                        ),
                                const SizedBox(width: 10),
                               Consumer<DateTimeController>(
                                        builder: (context, controller, child) {
                                            return ElevatedButton(
                                                onPressed: controller.isLoading
                                                    ? null
                                                    : () => controller.checkApiAvailability(_urlController.text),
                                                child: controller.isLoading
                                                    ? const CircularProgressIndicator()
                                                    : const Text('Check Server Status'),
                                            );
                                        },

                                ),

                        const SizedBox(height: 20),
                        Consumer<DateTimeController>(
                            builder: (context, controller, child) {
                                return controller.dateTime != null
                                    ? SelectableText (
                                    '${controller.dateTime}',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                )
                                    : (!controller.isLoading
                                    ? const Text('No valid date/time found.')
                                    : const SizedBox());
                            },
                        ),
                    ],
                ),
            ),
        );
    }
}
