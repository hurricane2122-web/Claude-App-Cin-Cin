import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum ProximityState { idle, scanning, near, toasting }

class ProximityService extends ChangeNotifier {
  ProximityState _state = ProximityState.idle;
  ProximityState get state => _state;

  int _nearbyCount = 0;
  int get nearbyCount => _nearbyCount;

  double _closestDistance = 999.0;
  double get closestDistance => _closestDistance;

  final Map<String, int> _deviceRssi = {};
  Timer? _scanTimer;
  Timer? _cooldownTimer;
  bool _inCooldown = false;

  StreamSubscription? _scanSubscription;

  static const int rssiThreshold = -65;

  VoidCallback? onToast;

  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    return statuses.values.every((s) => s.isGranted);
  }

  Future<void> startScanning() async {
    if (_state == ProximityState.scanning) return;

    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    _setState(ProximityState.scanning);

    _scanSubscription = FlutterBluePlus.scanResults.listen(_onScanResults);

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 0),
      androidUsesFineLocation: true,
    );

    _scanTimer = Timer.periodic(const Duration(seconds: 2), (_) => _checkDevices());
  }

  void _onScanResults(List<ScanResult> results) {
    _deviceRssi.clear();

    for (final result in results) {
      final rssi = result.rssi;
      final deviceId = result.device.remoteId.str;

      if (rssi > rssiThreshold - 20) {
        _deviceRssi[deviceId] = rssi;
      }
    }

    notifyListeners();
  }

  void _checkDevices() {
    if (_inCooldown) return;

    final nearDevices = _deviceRssi.values.where((rssi) => rssi >= rssiThreshold).length;
    _nearbyCount = nearDevices;

    if (_deviceRssi.isNotEmpty) {
      final maxRssi = _deviceRssi.values.reduce(max);
      _closestDistance = _estimateDistance(maxRssi);
    } else {
      _closestDistance = 999.0;
    }

    if (nearDevices > 0 && _state != ProximityState.toasting) {
      _triggerToast();
    }

    notifyListeners();
  }

  double _estimateDistance(int rssi) {
    const txPower = -59;
    const n = 2.0;
    return pow(10, (txPower - rssi) / (10 * n)).toDouble();
  }

  void _triggerToast() {
    if (_inCooldown) return;

    _setState(ProximityState.toasting);
    onToast?.call();

    _inCooldown = true;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(const Duration(seconds: 30), () {
      _inCooldown = false;
      if (_state == ProximityState.toasting) {
        _setState(ProximityState.scanning);
      }
    });

    Timer(const Duration(seconds: 3), () {
      if (_state == ProximityState.toasting) {
        _setState(ProximityState.scanning);
      }
    });
  }

  void _setState(ProximityState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> stopScanning() async {
    _scanTimer?.cancel();
    _scanSubscription?.cancel();
    await FlutterBluePlus.stopScan();
    _setState(ProximityState.idle);
  }

  void simulateToast() {
    if (!_inCooldown) {
      _triggerToast();
    }
  }

  @override
  void dispose() {
    stopScanning();
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
