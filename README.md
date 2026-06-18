# 📚 Book Tracker

**Твой персональный трекер книг для iOS** — ищи, читай, отслеживай прогресс и собирай свою библиотеку.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5-blue.svg)](https://developer.apple.com/swiftui/)
[![Platform](https://img.shields.io/badge/Platform-iOS_17+-lightgrey.svg)](https://developer.apple.com/ios/)

---

## ✨ Возможности

- 🔍 **Поиск книг** — находи книги по названию или автору через Open Library API
- 📖 **Встроенный ридер** — читай реальный текст книг из Project Gutenberg прямо в приложении
- 🎨 **Обложки книг** — автоматическая загрузка обложек из Open Library и Gutenberg
- 📊 **Профиль со статистикой** — отслеживай количество прочитанных книг и страниц
- 🌙 **Тёмная тема** — полная поддержка Dark Mode с переключателем в профиле
- 💾 **Сохранение данных** — библиотека и настройки сохраняются между сессиями
- 📏 **Настройка шрифта** — выбирай размер текста в ридере (маленький / средний / большой)
- 🏷️ **Статусы чтения** — отмечай книги как "Читаю" или "Прочитано"

---

## 📱 Скриншоты

| Библиотека | Поиск | Детали книги | Ридер | Профиль |
|:---:|:---:|:---:|:---:|:---:|
| [screenshot] | [screenshot] | [screenshot] | [screenshot] | [screenshot] |

---

## 🛠 Технологии

| Технология | Назначение |
|---|---|
| **Swift 5.9** | Язык разработки |
| **SwiftUI** | Декларативный UI |
| **MVVM** | Архитектурный паттерн |
| **Open Library API** | Поиск книг, метаданные, обложки |
| **Gutenberg API** | Полные тексты книг для ридера |
| **UserDefaults** | Локальное хранение библиотеки и настроек |
| **async/await** | Асинхронные сетевые запросы |
| **AsyncImage** | Загрузка обложек |

---

## 🚀 Как запустить

1. Клонируй репозиторий:
   ```bash
   git clone https://github.com/your-username/book-tracker.git
   ```
2. Открой проект в Xcode:
   ```bash
   cd book-tracker
   open "Book Tracker.xcodeproj"
   ```
3. Выбери симулятор (iPhone 15 / 16) или реальное устройство
4. Нажми **⌘R** — готово!

> **Требования:** Xcode 15+, iOS 17+, интернет-соединение для поиска и загрузки книг.

---

## 📂 Структура проекта

```
Book Tracker/
├── Book_TrackerApp.swift    # Точка входа
├── ContentView.swift        # TabView + хранение данных
├── Book.swift               # Модель данных
├── LibraryView.swift        # Экран библиотеки
├── SearchView.swift         # Поиск книг
├── BookDetailView.swift     # Детали книги
├── WebView.swift            # Встроенный ридер
├── ProfileView.swift        # Профиль и настройки
├── AppSettings.swift        # Настройки приложения
├── NetworkManager.swift     # Сетевой слой (Open Library + Gutenberg)
└── AddBookView.swift        # Ручное добавление книги
```

---

## 📄 Лицензия

MIT License — свободно используй и модифицируй.
