import 'package:flutter/material.dart';
import '../models/monitor_serverpod.dart';

class MonitorController with ChangeNotifier {
    final MonitorServerpod _fetcher = MonitorServerpod();
    Map<String, String>? _results;
    bool _isLoading = false;

    Map<String, String>? get results => _results;
    bool get isLoading => _isLoading;

    String? lastApiUrl;
    String? lastWebAppUrl;
    String? lastInsightsUrl;

    ///
    /// Reports on API availability using the data/time of an API server call
    ///
    Future<void> checkApiAvailability(String url) async {
        _isLoading = true;
        _results = null;
        lastApiUrl = url;
        lastWebAppUrl = null;
        lastInsightsUrl = null;
        notifyListeners();

        final apiResult = await _fetcher.checkApiServer(url);
        _results = {'API': apiResult};

        _isLoading = false;
        notifyListeners();
    }

    ///
    /// Runs a full set of domain and subdomain checks
    ///
    Future<void> checkAllServerpodDomains({
        required String apiUrl,
        required String webAppUrl,
        required String insightsUrl,
    }) async {
        _isLoading = true;
        _results = null;
        lastApiUrl = apiUrl;
        lastWebAppUrl = webAppUrl;
        lastInsightsUrl = insightsUrl;
        notifyListeners();

        final Map<String, String> allResults = {};
        allResults['API'] = await _fetcher.checkApiServer(apiUrl);
        allResults['WebApp'] = await _fetcher.checkWebApp(webAppUrl);
        allResults['Insights'] = await _fetcher.checkInsights(insightsUrl);
        allResults['TLS'] = await _fetcher.checkTls(apiUrl);

        _results = allResults;

        _isLoading = false;
        notifyListeners();
    }
}
