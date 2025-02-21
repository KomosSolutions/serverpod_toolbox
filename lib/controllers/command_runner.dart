import 'dart:io';

///
/// Runs a command using cmd.exe
///
class CommandRunner {
    String projectDir;

    Function logAppender; // set to the addToLog() function from the project tab
    final String _currentLogText = ''; // used to parse the log when completed

    // List of project folders
    List<String> serverpodFolders = [];
    late String _projectFolderServer;
    late String _projectFolderFlutter;
    late String _projectFolderClient;
    late String _projectFolderShared;

    // All the commands available to run.  Set to public so they can be used as button labels
    static String flutterPubUpgrade = 'flutter pub upgrade --major-versions';
    static String fixDartFormat = 'dart pub global activate dart_format';
    static String upgradeCLI = 'dart pub global activate serverpod_cli';
    static const String flutterCleanCommand = 'flutter clean';
    static const String serverpodGenerateCommand = 'serverpod generate';
    static const String serverpodCreateMigrationCommand = 'serverpod create-migration';
    static const String buildRunnerCommand = 'dart run build_runner build';
    static const String serverpodCreateRepairMigrationCommand = 'serverpod create-repair-migration';
    static const String serverpodApplyRepairMigrationCommand = 'dart run bin/main.dart --apply-repair-migration';

    CommandRunner(this.projectDir, this.logAppender);

    ///
    /// Sets up the project directory variables for each sub dir, for use when running commands
    ///
    Future<void> setupDirectoryVariables() async {
        // remove all path separators from the end of the project directory
        while (projectDir.endsWith(Platform.pathSeparator)) {
            projectDir = projectDir.substring(0, projectDir.length - 1);
        }
        // get the project name
        final segments = projectDir.split(Platform.pathSeparator);
        String projectName = segments.last;

        // add an ending directory separator
        // if (!projectDir.endsWith(Platform.pathSeparator)) {
        //     projectDir += Platform.pathSeparator;
        // }

        // build the project dirs
        _projectFolderServer = "${projectName}_server";
        _projectFolderFlutter = "${projectName}_flutter";
        _projectFolderClient = "${projectName}_client";

        // build a list of project dirs
        serverpodFolders = [_projectFolderServer, _projectFolderFlutter, _projectFolderClient];

        // Add the  'project_shared' folder if it exists
        String sharedDir = "$projectDir${Platform.pathSeparator}${projectName}_shared";
        bool sharedFolderExists = await Directory(sharedDir).exists();
        if (sharedFolderExists) {
            _projectFolderShared = "${projectName}_shared";
            serverpodFolders.add(_projectFolderShared);
        }
    }

    ///
    /// Runs an OS command
    ///
    Future<void> _runCommand(String command, {String subFolder = ""}) async {
        try {
            final process = await Process.start(
                'cmd',
                ['/c', command],
                workingDirectory: "$projectDir${Platform.pathSeparator}$subFolder",
            );

            logAppender("Running:\n $projectDir${Platform.pathSeparator}$subFolder${Platform.pathSeparator}$command");

            // Log each line (transform(utf8.decoder))
            process.stdout.listen((line) => logAppender(line));
            process.stderr.listen((line) => logAppender(line));

            // Wait for process to finish
            await process.exitCode;
        } catch (e) {
            logAppender('Error executing command: $command\n$e');
        }
    }

    ///
    /// Cleans the library files in all project folders.
    ///
    Future<void> flutterClean() async {
        for (final folder in serverpodFolders) {
            await _runCommand(flutterCleanCommand, subFolder: folder);
        }
        _processLog();
    }

    Future<void> flutterGet() async {
        for (final folder in serverpodFolders) {
            await _runCommand('dart pub get', subFolder: folder);
        }

        _processLog();
    }

    Future<void> flutterUpgrade() async {
        for (final folder in serverpodFolders) {
            await _runCommand(flutterPubUpgrade, subFolder: folder);
        }
        _processLog();
    }

    Future<void> serverPodGenerate() async {
        await _runCommand(serverpodGenerateCommand, subFolder: _projectFolderServer);
        _processLog();
    }

    Future<void> runUpgradeCLI() async {
        await _runCommand(upgradeCLI);
        _processLog();
    }

    Future<void> serverpodCreateMigration([String force = '']) async {
        await _runCommand("$serverpodCreateMigrationCommand $force", subFolder: _projectFolderServer);
        _processLog();
    }

    Future<void> buildRunner([String release = '']) async {
        for (final folder in serverpodFolders) {
            await _runCommand("$buildRunnerCommand $release", subFolder: folder);
        }
        _processLog();
    }

    Future<void> serverpodCreateRepairMigration() async {
        await _runCommand(serverpodCreateRepairMigrationCommand, subFolder: _projectFolderServer);
        _processLog();
    }

    Future<void> serverpodApplyRepairMigration() async {
        await _runCommand(serverpodApplyRepairMigrationCommand, subFolder: _projectFolderServer);
        _processLog();
    }

    Future<void> runFixDartFormat() async {
        await _runCommand(fixDartFormat);
        _processLog();
    }

    void _processLog() {
        String analysisText = '';

        final errorPatterns = [
            RegExp(r'\ERROR\b', caseSensitive: false), // Matches "ERROR" (case-insensitive)
            RegExp(r'\WARNING\b', caseSensitive: false), // Matches "ERROR" (case-insensitive)
            RegExp(r'\SEVERE\b', caseSensitive: false), // Matches "ERROR" (case-insensitive)
            RegExp(r'\bException\b', caseSensitive: false), // Matches "Exception" (case-insensitive)
            RegExp(r'\bFailed\b', caseSensitive: false), // Matches "Failed" (case-insensitive)
            RegExp(r'\bFatal\b', caseSensitive: false), // Matches "Fatal" (case-insensitive)
        ];

        // Check if any of the patterns match the log text
        for (var pattern in errorPatterns) {
            if (pattern.hasMatch(_currentLogText)) {
                analysisText += "${pattern.pattern} found.";
            }
        }
        if (analysisText.isEmpty) {
            analysisText = "**** Finished ******";
        } else {
            analysisText += "Please check output";
        }

        logAppender(analysisText);
    }
}
