class DateFormatter {
  static const List<String> _months = [
    '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
  ];

  static const List<String> _fullMonths = [
    '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  static const List<String> _weekdays = [
    '', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
  ];

  static String formatNoteDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');

    if (difference.inDays == 0 && dateTime.day == now.day) {
      return 'Hoje às $hour:$min';
    } else if (difference.inDays <= 1 && dateTime.day == now.subtract(const Duration(days: 1)).day) {
      return 'Ontem às $hour:$min';
    } else if (difference.inDays < 7) {
      final weekday = _weekdays[dateTime.weekday];
      return '$weekday, $hour:$min';
    } else if (dateTime.year == now.year) {
      final month = _months[dateTime.month];
      return '${dateTime.day} de $month, $hour:$min';
    } else {
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      return '$day/$month/${dateTime.year}';
    }
  }

  static String formatFullDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = _fullMonths[dateTime.month];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$day de $month de ${dateTime.year}, $hour:$min';
  }
}
