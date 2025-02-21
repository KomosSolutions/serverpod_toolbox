import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:serverpod_toolbox/models/preferences.dart';
import 'package:tint/tint.dart';

import 'command_runner.dart';

///
/// Controller for the project tab
///
class ProjectTabController {
    late Preferences preferences;
    late CommandRunner commandRunner;
    String projectFolderPath = "";
    final TextEditingController logController;
    String currentProjectName = '';

    ProjectTabController(this.logController);

    ///
    /// Loads the stored preferences
    ///
    Future<void> loadPreferences() async {
        preferences = Preferences();
        String? value = await preferences.loadProjectDir();

        if (value == null) {
            projectFolderPath = "";
            currentProjectName = '';
        } else {
            projectFolderPath = value;
            commandRunner = CommandRunner(projectFolderPath,  _addToLog);
            commandRunner.setupDirectoryVariables();
            currentProjectName = await preferences.getCurrentProjectName()??"";
        }
    }

    ///
    /// Adds text to the log area
    ///
    void _addToLog(dynamic rawOutput) {
        String message = "";

        if (rawOutput is Uint8List) {
            // The output line is UTF8
            final String text = utf8.decode(rawOutput);
            // remove the ansi escape colours (.strip() is an extension method from the Tint library)
            message = text.strip();
        } else if (rawOutput is String) {
            message = rawOutput;
        } else {
            message = rawOutput.toString();
        }

        // Append the message to the log
        logController.text += '$message\n';

    }

    ///
    /// Updates and save the top level project folder
    ///
    /// Returns the project name if the project exists, or null
    ///
    String? updateProjectFolder(String projectDir) {
        // check its a serverpod project
        try {
            final projectName = projectDir
                .split(Platform.pathSeparator)
                .last;
            String flutterProjectDir = "$projectDir${Platform.pathSeparator}${projectName}_flutter";
            bool serverpodProjectExists = Directory(flutterProjectDir).existsSync();
            if (serverpodProjectExists) {
                projectFolderPath = projectDir;
                preferences.saveProjectDir(projectFolderPath);
                return projectName;
            }
        }catch (e) {
            // ignore dir look up errors
      }
        return null;
    }
}
