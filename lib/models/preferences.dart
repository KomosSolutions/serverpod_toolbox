import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

///
/// Stored preferences
///
class Preferences {
    // Key for storing the current project name
    static const String _currentProjectKey = 'currentProjectName';

    ///
    /// Load the current project name
    ///
    Future<String?> getCurrentProjectName() async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_currentProjectKey);
    }

    ///
    /// Save the current project name
    ///
    Future<void> setCurrentProjectName(String projectName) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_currentProjectKey, projectName);
    }

    ///
    /// Clear/delete the project preference name
    ///
    Future<void> clearProject(String projectName) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('${projectName}_projectDir');
    }

    ///
    /// Load the project directory for the current project
    ///
    Future<String?> loadProjectDir() async {
        final currentProject = await getCurrentProjectName();
        if (currentProject == null) {
            return null; // No current project set
        }
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('${currentProject}_projectDir');
    }

    ///
    /// Save the project directory for the current project name
    ///
    Future<void> saveProjectDir(String dir) async {
        setCurrentProjectName(p.basename(dir));
        final currentProject = await getCurrentProjectName();
        if (currentProject == null) {
            throw Exception('No current project set');
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('${currentProject}_projectDir', dir);
    }

    // Get a list of all project names
    Future<List<String>> getProjectNames() async {
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();
        return keys.where((key) => key.endsWith('_projectDir')).map((key) => key.replaceAll('_projectDir', '')).toList();
    }

    // Get project directory for a specific project
    Future<String?> getProjectDir(String projectName) async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('${projectName}_projectDir');
    }

}
