class Prices {
  final String type;
  final double low;
  final double mid;
  final double high;
  final double market;
  final double directLow;

  Prices(
      {required this.type,
      required this.low,
      required this.mid,
      required this.high,
      required this.market,
      required this.directLow});

  factory Prices.fromJson(String type, Map<String, dynamic> value) {
    return Prices(
      type: type,
      low: _toDouble(value['low']),
      mid: _toDouble(value['mid']),
      high: _toDouble(value['high']),
      market: _toDouble(value['market']),
      directLow: _toDouble(value['directLow']),
    );
  }

  factory Prices.fromTcgdexVariant(String type, Map<String, dynamic> value) {
    return Prices(
      type: type,
      low: _toDouble(value['lowPrice']),
      mid: _toDouble(value['midPrice']),
      high: _toDouble(value['highPrice']),
      market: _toDouble(value['marketPrice']),
      directLow: _toDouble(value['directLowPrice']),
    );
  }

  factory Prices.fromTcgdexCardmarket(Map<String, dynamic> value) {
    return Prices(
      type: 'cardmarket',
      low: _toDouble(value['low']),
      mid: _toDouble(value['avg']),
      high: _toDouble(value['trend']),
      market: _toDouble(value['avg30']),
      directLow: _toDouble(value['avg7']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
