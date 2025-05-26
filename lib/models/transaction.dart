class Transaction {
  final String id;
  final String title;
  final double amount;
  final String type; 
  final String category;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

factory Transaction.fromMap(Map<String, dynamic> map) {
  return Transaction(
    id: map['id'].toString(),
    title: map['title'] ?? '',
    amount: (map['amount'] ?? 0).toDouble(),
    type: map['type'] ?? '',
    category: map['category'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
  );
}


Map<String, dynamic> toMapWithId() {
  return {
    'id': id,
    'title': title,
    'amount': amount,
    'type': type,
    'category': category,
    'date': date.toIso8601String(),
  };
}

}