import 'package:flutter/material.dart';
import 'transaction.dart';

class CategoryMeta {
  final String label;
  final Color color;
  final Color lightColor;
  final IconData icon;

  const CategoryMeta({
    required this.label,
    required this.color,
    required this.lightColor,
    required this.icon,
  });

  static const Map<TransactionCategory, CategoryMeta> all = {
    TransactionCategory.food: CategoryMeta(
      label: 'Food',
      color: Color(0xFFD45D2C),
      lightColor: Color(0x1AD45D2C),
      icon: Icons.restaurant_outlined,
    ),
    TransactionCategory.transport: CategoryMeta(
      label: 'Transport',
      color: Color(0xFF2F6FD6),
      lightColor: Color(0x1A2F6FD6),
      icon: Icons.directions_car_outlined,
    ),
    TransactionCategory.shopping: CategoryMeta(
      label: 'Shopping',
      color: Color(0xFF8E44AD),
      lightColor: Color(0x1A8E44AD),
      icon: Icons.shopping_bag_outlined,
    ),
    TransactionCategory.bills: CategoryMeta(
      label: 'Bills',
      color: Color(0xFFF0A21A),
      lightColor: Color(0x1AF0A21A),
      icon: Icons.receipt_outlined,
    ),
    TransactionCategory.health: CategoryMeta(
      label: 'Health',
      color: Color(0xFFE85D75),
      lightColor: Color(0x1AE85D75),
      icon: Icons.favorite_outline,
    ),
    TransactionCategory.entertainment: CategoryMeta(
      label: 'Entertainment',
      color: Color(0xFF6C5CE7),
      lightColor: Color(0x1A6C5CE7),
      icon: Icons.movie_outlined,
    ),
    TransactionCategory.tech: CategoryMeta(
      label: 'Tech',
      color: Color(0xFF00A3C4),
      lightColor: Color(0x1A00A3C4),
      icon: Icons.devices_outlined,
    ),
    TransactionCategory.income: CategoryMeta(
      label: 'Income',
      color: Color(0xFF2E7D32),
      lightColor: Color(0x1A2E7D32),
      icon: Icons.arrow_downward_rounded,
    ),
    TransactionCategory.other: CategoryMeta(
      label: 'Other',
      color: Color(0xFF6B7280),
      lightColor: Color(0x1A6B7280),
      icon: Icons.more_horiz_outlined,
    ),
  };

  static CategoryMeta of(TransactionCategory cat) => all[cat]!;
}
