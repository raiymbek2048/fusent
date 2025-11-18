import 'package:flutter/material.dart';

/// Цветовая схема приложения FUCENT по дизайну Figma
class AppColors {
  AppColors._();

  // Основные цвета
  static const Color primary = Color(0xFF5B7CFF); // Синий из макета
  static const Color secondary = Color(0xFFE91E63); // Розовый/магента акцент

  // Фоновые цвета (темная тема)
  static const Color background = Color(0xFF1C1C1E); // Основной фон
  static const Color surface = Color(0xFF2C2C2E); // Карточки, модалки
  static const Color surfaceVariant = Color(0xFF3A3A3C);

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
