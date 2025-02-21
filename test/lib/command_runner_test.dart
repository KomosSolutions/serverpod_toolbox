import 'dart:io';

import 'package:serverpod_toolbox/controllers/command_runner.dart';
import 'package:test/test.dart';

void main() {
    late Directory mockDirectory;


    setUp(() async {
            mockDirectory = Directory('${Directory.current.path}\\test\\mock_project');

        });

    test('should populate project folders correctly', () async {
            final commandRunner = CommandRunner(mockDirectory.path, ()=>{});
            await commandRunner.setupDirectoryVariables();
            expect(commandRunner.serverpodFolders.length, 4); 
        });

}
