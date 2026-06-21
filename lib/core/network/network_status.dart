import 'dart:async';
import 'dart:io';

class NetworkStatus {
  static const connectivityCheckHost = 'google.com';
  NetworkStatus() {
    _monitor();
  }

  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onStatusChanged => _controller.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void _monitor() async {
    try {
      final result = await InternetAddress.lookup(
        NetworkStatus.connectivityCheckHost,
      );
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      _isOnline = false;
    }
    _controller.add(_isOnline);
  }

  Future<bool> check() async {
    try {
      final result = await InternetAddress.lookup(
        NetworkStatus.connectivityCheckHost,
      );
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      _isOnline = false;
    }
    return _isOnline;
  }

  void dispose() => _controller.close();
}
