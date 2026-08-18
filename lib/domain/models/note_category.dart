import 'package:flutter/material.dart';

class NoteCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const NoteCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<NoteCategory> defaultCategories = [
    NoteCategory(
      id: 'geral',
      name: 'Geral',
      icon: Icons.folder_outlined,
      color: Color(0xFF64748B),
    ),
    NoteCategory(
      id: 'trabalho',
      name: 'Trabalho',
      icon: Icons.work_outline_rounded,
      color: Color(0xFF3B82F6),
    ),
    NoteCategory(
      id: 'estudos',
      name: 'Estudos',
      icon: Icons.school_outlined,
      color: Color(0xFF10B981),
    ),
    NoteCategory(
      id: 'ideias',
      name: 'Ideias & IA',
      icon: Icons.lightbulb_outline_rounded,
      color: Color(0xFFF59E0B),
    ),
    NoteCategory(
      id: 'pessoal',
      name: 'Pessoal',
      icon: Icons.favorite_border_rounded,
      color: Color(0xFFEC4899),
    ),
    NoteCategory(
      id: 'financas',
      name: 'Finanças',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF8B5CF6),
    ),
  ];

  static NoteCategory getCategoryById(String? id) {
    if (id == null) return defaultCategories.first;
    return defaultCategories.firstWhere(
      (c) => c.id == id,
      orElse: () => defaultCategories.first,
    );
  }
}
