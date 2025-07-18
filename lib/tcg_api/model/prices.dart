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
      low: value['low'] ?? 0.0,
      mid: value['mid'] ?? 0.0,
      high: value['high'] ?? 0.0,
      market: value['market'] ?? 0.0,
      directLow: value['directLow'] ?? 0.0,
    );
  }
}
