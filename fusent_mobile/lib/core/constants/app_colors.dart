import 'package:flutter/material.dart';

/// Цветовая схема приложения FUCENT по дизайну Figma
class AppColors {
  AppColors._();

  // Основные цвета (фиолетовые акценты)
  static const Color primary = Color(0xFF9C27B0); // Фиолетовый основной
  static const Color primaryLight = Color(0xFFBA68C8); // Светлый фиолетовый
  static const Color primaryDark = Color(0xFF7B1FA2); // Темный фиолетовый
  static const Color secondary = Color(0xFFE91E63); // Розовый/магента акцент
  static const Color accent = Color(0xFFAB47BC); // Акцентный фиолетовый

  // Фоновые цвета (темная тема)
  static const Color background = Color(0xFF121212); // Глубокий черный фон
  static const Color surface = Color(0xFF1E1E1E); // Карточки, модалки
  static const Color surfaceVariant = Color(0xFF2C2C2C); // Вариант поверхности
  static const Color surfaceLight = Color(0xFF3A3A3C); // Светлее поверхность

  // Текст
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textTertiary = Color(0xFF666666);

  // Системные цвета
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFFCC00);
  static const Color info = Color(0xFF0A84FF);

  // Dividers & Borders
  static const Color divider = Color(0xFF38383A);
  static const Color border = Color(0xFF48484A);

  // Social buttons (из дизайна)
  static const Color googleButton = Color(0xFFFFFFFF);
  static const Color telegramButton = Color(0xFF0088CC);

  // Transparent overlays
  static const Color overlay = Color(0x80000000);
  static const Color shimmer = Color(0xFF2C2C2E);
}
