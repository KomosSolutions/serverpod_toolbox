import 'package:flutter/material.dart';
import 'package:serverpod_toolbox/themes/app_theme.dart';
import 'package:serverpod_toolbox/views/monitor_tab.dart';
import 'package:serverpod_toolbox/views/project_tab.dart';

///
/// A toolbox for common commands used when developing a serverpod project
///
class ServerPodToolbox extends StatefulWidget {
    const ServerPodToolbox({super.key});

    @override
    ServerPodToolboxState createState() => ServerPodToolboxState();
}

class ServerPodToolboxState extends State<ServerPodToolbox> {
    bool isDarkMode = false;
    late AppTheme currentTheme;
    final int _numberOfTabs=2;

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        currentTheme = AppTheme(context, ThemeMode.system);
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: "Serverpod Toolbox",
            theme: currentTheme.themeData,
            home: DefaultTabController(
                length: _numberOfTabs,
                child: Scaffold(
                    appBar: AppBar(
                        actions: [
                            _buildThemeSwitch(),
                        ],
                        title: const Text(
                            'Serverpod Toolbox - A set of tools for managing a serverpod project',
                            overflow: TextOverflow.ellipsis,
                        ),
                        bottom: const TabBar(
                            tabs: [
                                Tab(text: 'Project'),
                                //  Tab(text: 'User Admin- TBA'),
                                Tab(text: 'Monitor'),
                            ],
                        ),
                    ),
                    body: const TabBarView(
                        children: [
                            ProjectTab(),
                            //UserAdminTab(),
                            MonitorTab(),
                        ],
                    ),
                ),
            ),
        );
    }

    Row _buildThemeSwitch() {
        return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                const Text(
                    'Dark Mode',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                    ),
                ),
                Switch(
                    value: isDarkMode,
                    onChanged: toggleTheme,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.blueAccent,
                    inactiveTrackColor: Colors.grey,
                    inactiveThumbColor: Colors.white,
                ),
            ],
        );
    }

    void toggleTheme(bool value) {
        setState(() {
                isDarkMode = value;
                currentTheme = isDarkMode ? AppTheme(context, ThemeMode.dark) : AppTheme(context, ThemeMode.light);
            });
    }
}

void main() {
    runApp(const MaterialApp(
            home: ServerPodToolbox(),
        ));
}
