import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Помощь')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Часто задаваемые вопросы',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFaqItem(
            'Как сделать заказ?',
            'Выберите товар, добавьте в корзину, перейдите в корзину и нажмите "Оформить заказ". Заполните данные доставки и выберите способ оплаты.',
          ),
          _buildFaqItem(
            'Как отследить заказ?',
            'Перейдите в раздел "Мои заказы" в профиле. Там вы увидите статус каждого заказа.',
          ),
          _buildFaqItem(
            'Как вернуть товар?',
            'Свяжитесь с продавцом через чат или позвоните в службу поддержки. Возврат возможен в течение 14 дней.',
          ),
          _buildFaqItem(
            'Как стать продавцом?',
            'Зарегистрируйтесь как продавец в разделе "Стать продавцом" в профиле. Заполните данные о магазине и дождитесь подтверждения.',
          ),
          _buildFaqItem(
            'Какие способы оплаты доступны?',
            'Наличные при получении, банковская карта, Элсом, MBank, О! Деньги.',
          ),
          const SizedBox(height: 32),
          const Text(
            'Связаться с нами',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            context,
            Icons.phone,
            'Телефон',
            '+996 555 123 456',
            () => _launchUrl('tel:+996555123456'),
          ),
          _buildContactItem(
            context,
            Icons.email,
            'Email',
            'support@fusent.kg',
            () => _launchUrl('mailto:support@fusent.kg'),
          ),
          _buildContactItem(
            context,
            Icons.telegram,
            'Telegram',
            '@fusent_support',
            () => _launchUrl('https://t.me/fusent_support'),
          ),
          _buildContactItem(
            context,
            Icons.language,
            'Instagram',
            '@fusent.kg',
            () => _launchUrl('https://instagram.com/fusent.kg'),
          ),
          const SizedBox(height: 32),
          const Text(
            'Правовая информация',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Пользовательское соглашение'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Политика конфиденциальности'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Fusent v1.0.0',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
