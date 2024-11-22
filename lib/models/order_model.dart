class Order {
  final int id;
  final String price;
  final String bankName;
  final String type;
  final String transactionNumber;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic> orderBook;
  final Map<String, dynamic> orderUser;

  Order({
    required this.id,
    required this.price,
    required this.bankName,
    required this.type,
    required this.transactionNumber,
    required this.status,
    required this.createdAt,
    required this.orderBook,
    required this.orderUser,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      price: json['price'],
      bankName: json['bankName'],
      type: json['type'],
      transactionNumber: json['transactionNumber'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      orderBook: json['orderBook'],
      orderUser: json['orderUser'],
    );
  }
}
