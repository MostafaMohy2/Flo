import 'package:equatable/equatable.dart';

enum TransactionType { expense, income }

enum TransactionCategory {
  food,
  transport,
  shopping,
  bills,
  health,
  entertainment,
  tech,
  income,
  other,
}

class Transaction extends Equatable {
  final String id;
  final String merchantName;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String? note;
  final bool isFlagged;

  const Transaction({
    required this.id,
    required this.merchantName,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    this.isFlagged = false,
  });

  Map<String, dynamic> toMap() => {
    'id':           id,
    'merchantName': merchantName,
    'amount':       amount,
    'type':         type.name,
    'category':     category.name,
    'date':         date.toIso8601String(),
    'note':         note,
    'isFlagged':    isFlagged ? 1 : 0,
  };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
    id:           map['id'],
    merchantName: map['merchantName'],
    amount:       map['amount'],
    type:         TransactionType.values.byName(map['type']),
    category:     TransactionCategory.values.byName(map['category']),
    date:         DateTime.parse(map['date']),
    note:         map['note'],
    isFlagged:    map['isFlagged'] == 1,
  );

  Transaction copyWith({
    String? id,
    String? merchantName,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? note,
    bool? isFlagged,
  }) => Transaction(
    id:           id           ?? this.id,
    merchantName: merchantName ?? this.merchantName,
    amount:       amount       ?? this.amount,
    type:         type         ?? this.type,
    category:     category     ?? this.category,
    date:         date         ?? this.date,
    note:         note         ?? this.note,
    isFlagged:    isFlagged    ?? this.isFlagged,
  );

  @override
  List<Object?> get props => [id, merchantName, amount, type, category, date, note, isFlagged];
}
