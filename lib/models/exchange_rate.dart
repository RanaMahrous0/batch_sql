class ExchangeRate {
  int? id;
  int? label;
  double? value;

  ExchangeRate.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    label = data['label'];
    value = data['value'];
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': label, 'value': value};
  }
}
