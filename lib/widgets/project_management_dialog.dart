import 'dart:async';
import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/preferences.dart';
import 'default_button.dart';

class ProjectManagementDialog {
    final Preferences preferences;
    String projectFolderPath = '';
    String? selectedProject;

    ProjectManagementDialog(BuildContext context, {required this.preferences});

    // Method to show the dialog with the list of projects
    Future<void> show(BuildContext context) async {
        final projectNames = await preferences.getProjectNames();
        selectedProject = await preferences.getCurrentProjectName();

        return showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                                'Manage Projects',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                                'Select Project:',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                        ]),
                    content: SizedBox(
                        width: double.maxFinite,
                        height: 400, // Height of the dialog
                        child: ListView.builder(
                            itemCount: projectNames.length,
                            itemBuilder: (context, index) {
                                final projectName = projectNames[index];
                                return FutureBuilder<String?>(
                                    future: preferences.getProjectDir(projectName),
                                    builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                            return ListTile(
                                                title: Text(projectName),
                                                subtitle: const Text('Loading...'),
                                            );
                                        } else if (snapshot.hasError) {
                                            return ListTile(
                                                title: Text(projectName),
                                                subtitle: const Text('Error loading directory'),
                                            );
                                        } else if (!snapshot.hasData) {
                                            return ListTile(
                                                title: Text(projectName),
                                                subtitle: const Text('No directory set'),
                                            );
                                        } else {
                                            final projectDir = snapshot.data!;
                                            return _buildProjectDetailsTile(projectName, projectDir, context);
                                        }
                                    },
                                );
                            },
                        ),
                    ),
                    actions: [
                        DefaultButton(
                            onPressed: () async {
                                await handleProjectFolderSelector(context);
                            },
                            text: 'Add Project',
                        ),
                    ],
                );
            },
        );
    }

    ///
    /// Builds a project tile
    ///
    Widget _buildProjectDetailsTile(String projectName, String projectDir, BuildContext context) {
        return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: selectedProject == projectName ? Colors.blue : Colors.black,
                        width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                    title: Text(projectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(projectDir),
                    tileColor: selectedProject == projectName ? Colors.blue[100] : Colors.white,
                    trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                            preferences.clearProject(projectName);
                            Navigator.of(context).pop();
                        },
                    ),
                    onTap: () {
                        preferences.setCurrentProjectName(projectName);
                        Navigator.of(context).pop();
                    },
                ),
            ),
        );
    }
    ///
    /// Handles the project folder selection
    ///
    Future<void> handleProjectFolderSelector(BuildContext context) async {
        final selectedDirectory = await _getDirectoryPicker(context);
        if (selectedDirectory != null) {
            projectFolderPath = selectedDirectory;
            await preferences.saveProjectDir(projectFolderPath);
            Navigator.of(context).pop();
        }
    }

    ///
    /// Directory picker selection
    ///
    Future<String?> _getDirectoryPicker(BuildContext context) {
        return (Platform.isWindows) ? _getDirectoryPathWindows() : _getDirectoryPathLinux(context);
    }

    ///
    /// Directory picker selection for Linux
    ///
    Future<String?> _getDirectoryPathLinux(BuildContext context) async {
        final result = await FilesystemPicker.open(
            context: context,
            //rootDirectory: Directory("/"), // Optional: Set initial directory
            fsType: FilesystemType.folder, // Specify directory selection
        );

        if (result != null) {
            return result; // This is the selected directory path
        } else {
            // Handle case where user cancels or there's an error
            return null;
        }
    }

    ///
    /// Directory picker selection for windows
    ///
    Future<String?> _getDirectoryPathWindows() {
        final Completer<String?> completer = Completer<String?>();
        final directoryPicker = DirectoryPicker()..title = 'Select a directory';

        Future.microtask(() {
                final selectedDirectory = directoryPicker.getDirectory();
                if (selectedDirectory != null) {
                    completer.complete(selectedDirectory.path);
                } else {
                    completer.complete(null);
                }
            });
        return completer.future;
    }
}
