class Prices {
  final String type;
  final double low;
  final double mid;
  final double high;
  final double market;
  final double directLow;

  Prices(
      {this.type, this.low, this.mid, this.high, this.market, this.directLow});

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
