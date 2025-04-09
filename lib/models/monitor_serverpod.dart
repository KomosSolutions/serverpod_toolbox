import 'package:http/http.dart' as http;

class MonitorServerpod {
    Future<String> checkApiServer(String url) async {
        String result;
        try {
            final uri = Uri.parse(url);
            final response = await http.get(uri);

            if (response.statusCode == 200) {
                final body = response.body.trim().replaceAll('OK', '').trim();
                result = "Serverpod is running.  System Time: $body";
            } else if (response.statusCode == 502) {
                result = "Error 502 : Bad Gateway.  Check serverpod is running on EC2.\n"
                "Try :\n"
                "- Restarting the server                                   : sudo systemctl start serverpod.service\n"
                "- Check service is running                              : systemctl status serverpod.service\n"
                "- Recompile main.dart and restart the server  : Run 'recompile_kernel.sh' in ec2-home";
            } else {
                result = 'Error. Response code: ${response.statusCode}';
            }
        } catch (e) {
            result = "Error: $e";
        }
        return result;
    }
}
