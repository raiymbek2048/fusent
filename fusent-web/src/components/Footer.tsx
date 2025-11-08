export default function Footer() {
  return (
    <footer className="bg-gray-50 border-t border-gray-200 mt-auto">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {/* Company Info */}
          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              {process.env.NEXT_PUBLIC_APP_NAME || 'Fusent'}
            </h3>
            <p className="text-gray-600 text-sm">
              Маркетплейс Кыргызстана. Найдите лучшие магазины и товары в Бишкеке.
            </p>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Быстрые ссылки</h3>
            <ul className="space-y-2">
              <li>
                <a href="/shops" className="text-gray-600 hover:text-primary-500 text-sm">
                  Магазины
                </a>
              </li>
              <li>
                <a href="/feed" className="text-gray-600 hover:text-primary-500 text-sm">
                  Лента
                </a>
              </li>
              <li>
                <a href="/about" className="text-gray-600 hover:text-primary-500 text-sm">
                  О нас
                </a>
              </li>
            </ul>
          </div>

          {/* Support */}
          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Поддержка</h3>
            <ul className="space-y-2">
              <li>
                <a href="/help" className="text-gray-600 hover:text-primary-500 text-sm">
                  Помощь
                </a>
              </li>
              <li>
                <a href="/contact" className="text-gray-600 hover:text-primary-500 text-sm">
                  Контакты
                </a>
              </li>
              <li>
                <a href="/privacy" className="text-gray-600 hover:text-primary-500 text-sm">
                  Политика конфиденциальности
                </a>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-8 pt-8 border-t border-gray-200">
          <p className="text-center text-gray-500 text-sm">
            &copy; {new Date().getFullYear()} {process.env.NEXT_PUBLIC_APP_NAME || 'Fusent'}. Все
            права защищены.
          </p>
        </div>
      </div>
    </footer>
  )
}
