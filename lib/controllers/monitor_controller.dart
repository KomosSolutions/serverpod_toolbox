import 'package:flutter/material.dart';

import '../models/monitor_serverpod.dart';


class DateTimeController with ChangeNotifier {
    final MonitorServerpod _fetcher = MonitorServerpod();
    String? _result;
    bool _isLoading = false;

    String? get dateTime => _result;
    bool get isLoading => _isLoading;

    ///
    /// Reports on API availability using the data/time of an API server call
    ///
    Future<void> checkApiAvailability(String url) async {
        _isLoading = true;
        notifyListeners();

        _result = await _fetcher.checkApiServer(url);

        _isLoading = false;
        notifyListeners();
    }
}
