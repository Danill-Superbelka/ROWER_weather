# POWER Weather

iOS-приложение погоды в стиле Apple Weather. Программный UI, современный Swift, двуязычная поддержка.

## Скриншоты

<!-- TODO: добавить скриншоты -->

## Архитектура

**MVVM + Combine + Service Layer**

```
┌─────────────────────────────────────────────────┐
│                  View Layer                      │
│  WeatherView ← секции (Current, Hourly, Daily,  │
│                         Details, Sun)            │
│  CitySearchViewController                       │
├─────────────────────────────────────────────────┤
│               ViewController                     │
│  WeatherViewController ─ bind ─► WeatherView     │
│  CitySearchViewController ─ bind ─► TableView    │
├─────────────────────────────────────────────────┤
│                ViewModel                         │
│  WeatherViewModel (@Published state/forecast)    │
│  CitySearchViewModel (@Published results/state)  │
├─────────────────────────────────────────────────┤
│              Service Layer                       │
│  WeatherService (WeatherServicing)               │
│  LocationService (LocationServicing)             │
│  NetworkService (NetworkServicing)               │
│  DateService, ImageServices                      │
├─────────────────────────────────────────────────┤
│                 Models                           │
│  ForecastResponse, CurrentWeather, HourWeather,  │
│  ForecastDay, Day, Astro, CitySearchResult       │
└─────────────────────────────────────────────────┘
```

### Поток данных

```
User Action → ViewController → ViewModel.method()
                                    │
                                    ▼
                            LocationService.requestLocation()
                                    │
                                    ▼
                            WeatherService.fetchForecast()
                                    │
                                    ▼
                            @Published state/forecast
                                    │
                              Combine sink
                                    │
                                    ▼
                            View.configure(with:)
```

### Dependency Injection

Сервисы инжектируются через протоколы:
- `WeatherServicing` — получение прогноза и поиск городов
- `LocationServicing` — геолокация пользователя
- `NetworkServicing` — выполнение HTTP-запросов

ViewModels принимают зависимости через `init`, что позволяет подставлять моки при тестировании.

## Структура проекта

```
POWER/
├── AppDelegate.swift
├── SceneDelegate.swift
├── Info.plist
│
├── Models/
│   └── WeatherModels.swift          # Codable модели API
│
├── Screens/
│   ├── Weather/
│   │   ├── WeatherViewController.swift
│   │   ├── WeatherView.swift         # ScrollView + Stack + секции
│   │   ├── WeatherViewModel.swift    # Combine, кэширование
│   │   └── Sections/
│   │       ├── CurrentWeatherSectionView.swift
│   │       ├── HourlySectionView.swift
│   │       ├── HourlyItemView.swift
│   │       ├── DailySectionView.swift
│   │       ├── DailyRowView.swift     # Температурная шкала
│   │       ├── DetailsSectionView.swift
│   │       └── SunSectionView.swift
│   └── CitySearch/
│       ├── CitySearchViewController.swift
│       └── CitySearchViewModel.swift  # Combine debounce
│
├── Services/
│   ├── LocationService.swift         # CLLocationManager, async/await
│   ├── DateService.swift             # DateFormatter расширения
│   ├── ImageServices.swift           # Kingfisher расширение
│   ├── APIService/
│   │   └── WeatherService.swift      # Эндпоинты weatherapi.com
│   └── NetworkService/
│       ├── Endpoint.swift            # Протокол эндпоинта
│       ├── HTTPMethod.swift
│       ├── NetworkError.swift
│       └── NetworkService.swift      # URLSession, retry, логирование
│
├── CommonViews/
│   ├── SectionCardView.swift         # Карточка-секция
│   └── WeatherValueView.swift        # Ячейка деталей
│
├── Resources/
│   ├── Localizable.xcstrings         # EN/RU локализация
│   └── Assets.xcassets/
│       └── Colors/                   # GradientTop/Bottom, Card, Separator...
│
└── Base.lproj/
    └── LaunchScreen.storyboard
```

## Фичи

### Основные
- **Текущая погода** — температура, описание, ощущается как, макс/мин
- **Почасовой прогноз** — оставшиеся часы сегодня + все часы завтра, горизонтальный скролл
- **Прогноз на 3 дня** — температурная шкала (градиент холодный→тёплый) как в Apple Weather
- **Поиск городов** — модальный экран с debounce-поиском через API, выбор города меняет прогноз
- **Геолокация** — автоматический запрос разрешения, fallback на Москву при отказе

### Детали погоды
- Влажность
- Скорость и направление ветра
- Атмосферное давление
- Видимость
- УФ-индекс (с текстовым описанием: Низкий/Умеренный/Высокий/Очень высокий/Экстремальный)
- Вероятность дождя
- Восход и закат

### Состояния экрана
- **Loading** — спиннер по центру
- **Error** — иконка, описание ошибки, кнопка "Повторить"
- **Loaded** — полноценный контент с секциями

### Кэширование
- In-memory кэш прогноза на 5 минут
- Сравнение координат с точностью ~1 км
- Свежий кэш → мгновенное отображение без запроса
- Устаревший кэш → показ + тихое обновление в фоне

## Технологии

| Технология | Применение |
|-----------|-----------|
| **UIKit** | Программный UI без Storyboard |
| **SnapKit** | Auto Layout DSL |
| **Kingfisher** | Загрузка и кэширование иконок погоды |
| **Combine** | Биндинги ViewModel → View, debounce поиска |
| **Swift Concurrency** | async/await, @MainActor, Sendable, typed throws |
| **CLLocationManager** | Геолокация с кэшированием и таймаутом |
| **OSLog** | Структурированное логирование |

## API

[WeatherAPI.com](https://www.weatherapi.com/) — бесплатный тариф.

Эндпоинты:
- `GET /v1/forecast.json?key=...&q=LAT,LON&days=3` — прогноз
- `GET /v1/search.json?key=...&q=QUERY` — поиск городов

## Локализация

Поддерживаемые языки: **English**, **Русский**

Все строки вынесены в `Localizable.xcstrings` — Xcode String Catalog формат.

## Требования

- iOS 26.2+
- Xcode 26.3+
- Swift 5

## Установка

1. Клонировать репозиторий
2. Открыть `POWER.xcodeproj`
3. Зависимости (SnapKit, Kingfisher) подтянутся автоматически через SPM
4. Build & Run
