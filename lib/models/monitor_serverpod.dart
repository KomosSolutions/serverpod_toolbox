import 'package:http/http.dart' as http;

class MonitorServerpod {
    Future<String> checkApiServer(String url) async {
        try {
            final uri = Uri.parse(url);
            final response = await http.get(uri);

            if (response.statusCode == 200) {
                final body = response.body.trim().replaceAll('OK', '').trim();
                return "Serverpod API is running. System Time: $body";
            } else if (response.statusCode == 502) {
                return """Error 502: Bad Gateway. Check serverpod is running on EC2.
Try:
- Restart server: sudo systemctl start serverpod.service
- Check status: systemctl status serverpod.service
- Recompile main.dart and restart server: ./recompile_kernel.sh""";
            } else {
                return 'Error. Response code: ${response.statusCode}';
            }
        } catch (e) {
            return "Error: $e";
        }
    }

    Future<String> checkWebApp(String url) async {
        try {
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) return 'Web app reachable';
            return 'Web app returned status ${response.statusCode}';
        } catch (e) {
            return 'Error accessing web app: $e';
        }
    }

    Future<String> checkInsights(String url) async {
        try {
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) return 'Insights GUI reachable';
            return 'Insights returned status ${response.statusCode}';
        } catch (e) {
            return 'Error accessing Insights: $e';
        }
    }

    Future<String> checkTls(String url) async {
        try {
            final uri = Uri.parse(url);
            final response = await http.get(uri);
            if (response.statusCode == 200) return 'TLS/HTTPS valid';
            return 'TLS check returned status ${response.statusCode}';
        } catch (e) {
            return 'TLS error: $e';
        }
    }

    Future<Map<String, String>> runAllChecks() async {
        final results = <String, String>{};
        results['API'] = await checkApiServer('https://api.mydomain.com');
        results['WebApp'] = await checkWebApp('https://www.mydomain.com');
        results['Insights'] = await checkInsights('https://insights.mydomain.com');
        results['TLS'] = await checkTls('https://api.mydomain.com');
        return results;
    }
}
