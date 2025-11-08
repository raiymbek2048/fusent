# Fusent Web - Frontend

Next.js 14 веб-приложение для маркетплейса Fusent.

## Технологии

- **Next.js 14** - React фреймворк с App Router
- **TypeScript** - Статическая типизация
- **TailwindCSS** - Utility-first CSS фреймворк
- **React Query** - Управление серверным состоянием
- **Zustand** - Управление клиентским состоянием
- **Axios** - HTTP клиент
- **Lucide React** - Иконки
- **React Hot Toast** - Уведомления

## Установка и запуск

```bash
# Установка зависимостей
npm install

# Запуск в режиме разработки
npm run dev

# Сборка для production
npm run build

# Запуск production сборки
npm start
```

Приложение будет доступно по адресу: http://localhost:3000

## Переменные окружения

Создайте файл `.env.local`:

```bash
NEXT_PUBLIC_API_URL=http://localhost:8080/api/v1
NEXT_PUBLIC_APP_NAME=Fusent
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

## Структура проекта

```
fusent-web/
├── src/
│   ├── app/                    # Next.js App Router страницы
│   │   ├── page.tsx           # Главная страница
│   │   ├── login/             # Страница входа
│   │   ├── register/          # Страница регистрации
│   │   ├── shops/             # Каталог магазинов
│   │   ├── feed/              # Социальная лента
│   │   ├── layout.tsx         # Root layout
│   │   ├── providers.tsx      # React Query provider
│   │   └── globals.css        # Глобальные стили
│   ├── components/            # React компоненты
│   │   ├── Header.tsx         # Шапка сайта
│   │   ├── Footer.tsx         # Футер
│   │   ├── MainLayout.tsx     # Главный layout
│   │   ├── ShopCard.tsx       # Карточка магазина
│   │   ├── ProductCard.tsx    # Карточка товара
│   │   └── PostCard.tsx       # Карточка поста
│   ├── hooks/                 # React Query hooks
│   │   ├── useAuth.ts         # Хуки аутентификации
│   │   ├── useShops.ts        # Хуки для магазинов
│   │   ├── useProducts.ts     # Хуки для товаров
│   │   └── usePosts.ts        # Хуки для социальных постов
│   ├── lib/                   # Утилиты и конфигурация
│   │   └── api.ts             # Axios клиент с interceptors
│   ├── store/                 # Zustand stores
│   │   └── authStore.ts       # Store для аутентификации
│   └── types/                 # TypeScript типы
│       └── index.ts           # Общие типы
├── public/                    # Статические файлы
├── .env.local                 # Переменные окружения
├── next.config.js             # Next.js конфигурация
├── tailwind.config.ts         # TailwindCSS конфигурация
├── tsconfig.json              # TypeScript конфигурация
└── package.json               # Зависимости
```

## Основные функции

### Аутентификация
- Вход / Регистрация
- JWT токены с автоматическим обновлением
- Защищенные маршруты
- Хранение токенов в localStorage

### Магазины
- Каталог всех магазинов
- Детальная страница магазина
- Поиск магазинов
- Фильтрация и пагинация

### Товары
- Каталог товаров
- Карточки товаров с рейтингом
- Фильтрация по категориям и магазинам

### Социальная лента
- Просмотр постов магазинов
- Лайки и комментарии
- Медиа-контент (изображения)

## API Integration

Все API запросы идут через `/lib/api.ts`, который:
- Автоматически добавляет JWT токен в заголовки
- Обрабатывает обновление токенов (refresh)
- Перенаправляет на /login при 401 ошибке
- Обрабатывает ошибки сети

## Тестовые аккаунты

**Покупатель:**
- Email: buyer1@test.kg
- Пароль: buyer123

**Продавец:**
- Email: fashion.store@fusent.kg
- Пароль: seller123

**Администратор:**
- Email: admin@fusent.kg
- Пароль: admin123

## Запуск с бэкендом

1. Запустите бэкенд:
```bash
cd ../fusent-backend
docker-compose up -d
mvn spring-boot:run
```

2. Запустите фронтенд:
```bash
cd fusent-web
npm install
npm run dev
```

3. Откройте http://localhost:3000

## Сборка для production

```bash
npm run build
npm start
```

Production сборка будет доступна на порту 3000.
