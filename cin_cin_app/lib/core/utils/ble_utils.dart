import 'dart:math';

double estimateDistanceFromRssi(int rssi, {int txPower = -59, double n = 2.0}) {
  return pow(10, (txPower - rssi) / (10 * n)).toDouble();
}

bool isNearby(int rssi, {int threshold = -65}) => rssi >= threshold;
