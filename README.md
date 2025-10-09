# Мобильное и десктопное приложение для учета инвентаризации и управления перемещениями оборудования в организации

## 📱 О проекте

Приложение предназначено для автоматизации процессов учета инвентарных объектов, отслеживания их перемещений между кабинетами и генерации отчетов. Система поддерживает ролевую модель доступа, уведомления и интеграцию с RFID-принтерами для печати этикеток.

<div align="center">
<img width="288" height="640" alt="О проекте" src="https://github.com/user-attachments/assets/9c4f477c-319e-451f-8fdc-20ff004f9609" />
</div>

## 🚀 Основные возможности

### 🔐 Авторизация и безопасность
- Ролевая модель доступа (администратор, пользователь, FHO)
- Автоматический вход при наличии сохраненных учетных данных
- Проверка подключения к корпоративной сети

### 📦 Управление инвентарем
- Просмотр каталога инвентарных объектов
- Поиск по наименованию и инвентарному номеру
- Сканирование штрих-кодов для быстрого доступа к информации
- История перемещений для каждого объекта

<table>
<tr>
<td align="center">
<img width="280" height="620" alt="Управление инвентарем" src="https://github.com/user-attachments/assets/0580079b-9188-4792-b912-caecafdaf749" />
<br><em>Сканер</em>
</td>
<td align="center">
<img width="280" height="620" alt="Управление инвентарем 3" src="https://github.com/user-attachments/assets/ad0697b5-99cb-4362-8b73-12da67a74069" />
<br><em>Сканер 2</em>
</td>
</tr>
<tr>
<td align="center">
<img width="280" height="620" alt="Управление инвентарем 2" src="https://github.com/user-attachments/assets/484a0989-b08a-4921-8412-ce8473f4cb2a" />
<br><em>Детали объекта</em>
</td>
</tr>
</table>


### 🚚 Управление перемещениями
- Создание, редактирование и удаление записей о перемещениях
- Автоматическое определение последнего местоположения объекта
- Фильтрация по дате, кабинетам-источникам и кабинетам-назначениям
- Группировка перемещений по месяцам и годам

<table>
<tr>
<td align="center">
<img width="280" height="620" alt="Управление перемещениям" src="https://github.com/user-attachments/assets/6bf41ff7-90f8-4ba1-b774-1753c3b309ef" />
<br><em>Список перемещений в месяце</em>
</td>
<td align="center">
<img width="280" height="620" alt="Управление перемещениям 2" src="https://github.com/user-attachments/assets/cebfacd8-01a7-475a-a252-ac82497863c6" />
<br><em>Список перемещений в годе</em>
</td>
</tr>
</table>


### 🖨️ Печать этикеток
- Поддержка обычных и металлических RFID-этикеток
- Настройка параметров печати (размеры, положение антенны, мощность)
- Интеграция с сетевыми принтерами

<table>
<tr>
<td align="center">
<img width="280" height="620" alt="Печать этикеток" src="https://github.com/user-attachments/assets/5e8f6b27-e412-4e0b-9643-286b051c421a" />
<br><em>Экран печати</em>
</td>
<td align="center">
<img width="280" height="620" alt="Печать этикеток 2" src="https://github.com/user-attachments/assets/837fa3df-b82e-4d84-ab4b-b0e871b1646c" />
<br><em>Настройки принтера</em>
</td>
</tr>
</table>


### 📊 Отчетность
- Генерация Excel-отчетов за месяц или конкретную дату
- Автоматическое форматирование таблиц
- Экспорт отчетов на устройство

<div align="center">
<img width="280" height="620" alt="Отчетность" src="https://github.com/user-attachments/assets/ce00b748-ab17-4fc2-a0b3-ad5c402f8277" />
<br><em>Генерация отчетов</em>
</div>


### 🔔 Уведомления
- Система push-уведомлений для важных событий
- Разделение на прочитанные и непрочитанные
- Уведомления для определенных ролей пользователей

<table>
<tr>
<td align="center">
<img width="280" height="620" alt="Уведомления" src="https://github.com/user-attachments/assets/c5ae05be-bd40-4c1f-90e6-a5a9fcd8ecdc" />
<br><em>Список уведомлений</em>
</td>
<td align="center">
<img width="280" height="620" alt="Уведомления 2" src="https://github.com/user-attachments/assets/c6880aea-6b53-4029-a55c-09980f7210f5" />
<br><em>Детали уведомления</em>
</td>
</tr>
</table>


## 🛠 Технологический стек

- **Flutter** - кроссплатформенная разработка
- **Flutter Bloc** - управление состоянием приложения
- **AutoRoute** - навигация и маршрутизация
- **Dio** - HTTP-клиент для API запросов
- **Excel** - генерация отчетов
- **File Picker/File Dialog** - работа с файловой системой
- **Window Manager** - управление окнами (desktop)
- **Barcode Scanner** - сканирование штрих-кодов

## 📁 Архитектура проекта

Проект следует принципам Clean Architecture с использованием BLoC паттерна:
lib/

├── constants/ # Константы приложения, ссылки, цвета, стили

├── cubit/ # Бизнес-логика (BLoC/Cubit)

├── models/ # Модели данных

├── repositories/ # Работа с данными

├── router/ # Навигация

├── screens/ # Экранныe компоненты

├── utils/ # Вспомогательные функции

└── widgets/ # Переиспользуемые виджеты

## 🎯 Поддерживаемые платформы

- **Android** - полная функциональность
- **Windows** - все функции кроме сканирования штрих-кодов

<div align="center">
<img width="350" height="526" alt="Платформа Windows" src="https://github.com/user-attachments/assets/8c88d25f-7125-4572-a2c8-c220bbfeffcf" />
<br><em>Версия для Windows</em>
</div>



## 🔧 Настройка и запуск

### Предварительные требования
- Flutter SDK 3.0+
- Dart 2.17+
- Подключение к корпоративной сети

### Установка
```bash
git clone https://github.com/Eargosha/Inventerization4AAS.git
cd Inventerization4AAS
flutter pub get
```

### Запуск
# Для Android
```bash
flutter run
```

# Для Windows
```bash
flutter run -d windows
```

# Сборка релиза Android
```bash
flutter build apk --release
```

# Сборка релиза Windows
```bash
flutter build windows --release
```
Сборка установщика для Windows производится при помощи Inno Setup, установщик и файл .iss лежит в папке setup в дирректории проекта

### 📄 Лицензия
Проект разработан для внутреннего использования в организации. Тестировался и использовался на базе 4ААС

### 🤝 Контакты
По вопросам использования и технической поддержки:

Email 4AAS: 04ap.eivanov@arbitr.ru
Email: eargosha@mail.ru

Версия приложения: 0.8.7
