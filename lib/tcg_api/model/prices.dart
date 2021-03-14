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
      low: value['low'],
      mid: value['mid'],
      high: value['high'],
      market: value['market'],
      directLow: value['directLow'],
    );
  }
}
