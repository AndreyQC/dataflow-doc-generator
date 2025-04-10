# DataFlow Documentation Generator

Генератор документации для анализа потоков данных в SQL-скриптах. Проект позволяет автоматически создавать визуализацию связей между таблицами, представлениями и хранимыми процедурами в базе данных.

## Структура проекта

```
├── src/                          # Исходный код
│   ├── common/                   # Общие модули
│   │   ├── __init__.py
│   │   ├── config.py            # Работа с конфигурацией
│   │   ├── crypto.py            # Шифрование конфиденциальных данных
│   │   ├── dflw_modules.py      # Обработка SQL объектов
│   │   ├── dflw_files.py        # Работа с файлами
│   │   ├── logger.py            # Настройка логирования
│   │   └── neo4j_handler.py     # Работа с Neo4j
│   ├── utils/                    # Утилиты
│   │   └── encrypt_neo4j_password.py  # Шифрование пароля Neo4j
│   ├── sql_processor.py         # Обработка SQL-файлов
│   └── dataflow_doc_generator.py # Генерация визуализации
├── logs/                        # Логи приложения (игнорируется git)
│   ├── app.log                  # Основной лог
│   └── error.log               # Лог ошибок
├── config.yml                   # Конфигурация приложения
├── requirements.txt             # Зависимости проекта
├── setup.py                     # Настройка установки пакета
├── .gitignore                   # Игнорируемые файлы
├── LICENSE                      # Лицензия проекта
└── README.md                    # Документация проекта
```

## Требования

- Python 3.10+
- UV (современный менеджер пакетов Python)
- Neo4j 5.x+ (создать на машине каталог ex. C:\project\neo4j-local)
  добавить `docker-compose.yml`
```
version: '3.8'

services:
  neo4j:
    image: neo4j:latest
    container_name: neo4j
    restart: unless-stopped
    ports:
      - "7474:7474"   # HTTP-интерфейс (браузер)
      - "7687:7687"   # Bolt-протокол (клиенты)
    volumes:
      - ./neo4j/data:/data
      - ./neo4j/logs:/logs
      - ./neo4j/import:/import
    environment:
      - NEO4J_AUTH=neo4j/you_pwd  # Логин: neo4j, пароль: adminpassword
      - NEO4JLABS_PLUGINS=["apoc"]     # Опционально: установка плагина APOC
```
- Зависимости указаны в `requirements.txt`

## Установка

1. Клонируйте репозиторий:
```bash
git clone <repository-url>
cd dataflow-doc-generator
```

2. Установите UV (если еще не установлен):
```bash
pip install uv
```

3. Создайте виртуальное окружение и установите зависимости:
```bash
uv venv
.venv\Scripts\activate  # для Windows
source .venv/bin/activate  # для Linux/Mac
uv pip install -e .  # установка в режиме разработки
```

4. Настройте переменную окружения для шифрования:
```bash
# Windows PowerShell
$env:ENVOS_CRYPTO_01="ваш-ключ-шифрования-в-формате-base64"

# Linux/Mac
export ENVOS_CRYPTO_01="ваш-ключ-шифрования-в-формате-base64"
```

5. Зашифруйте пароль Neo4j:
```bash
python src/utils/encrypt_neo4j_password.py
```

## Конфигурация

Настройки проекта хранятся в файле `config.yml`:

```yaml
database:
  container_name: "postgres"    # Имя контейнера базы данных
  container_type: "database"    # Тип контейнера

neo4j:
  uri: "bolt://localhost:7687"  # URI подключения к Neo4j
  user: "neo4j"                 # Пользователь Neo4j
  password: "crypto__..."       # Зашифрованный пароль Neo4j

paths:
  sql_files: "path/to/sql/files"    # Путь к SQL-файлам
  output_json: "path/to/output.json" # Путь для сохранения JSON
  output_folder: "path/to/output"    # Папка для выходных файлов

visualization:
  height: "750px"              # Высота визуализации
  width: "100%"                # Ширина визуализации
  colors:
    table: "lightblue"         # Цвет для таблиц
    default: "lightgreen"      # Цвет по умолчанию
```

## Использование

1. Настройте пути в `config.yml`
2. Запустите обработку SQL-файлов:
```bash
python src/sql_processor.py
```
3. Сгенерируйте визуализацию:
```bash
python src/dataflow_doc_generator.py
```

Результаты работы:
- `database.html` - интерактивная визуализация связей
- Граф зависимостей в Neo4j
- JSON-файлы с метаданными объектов и связей

## Логирование

Проект использует loguru для логирования. Логи сохраняются в директории `logs/`:
- `app.log` - основной лог с уровнем DEBUG
- `error.log` - лог ошибок

## Функциональность

- Анализ SQL-скриптов для поиска объектов базы данных
- Определение связей между таблицами, представлениями и хранимыми процедурами
- Генерация JSON-файлов с метаданными объектов
- Создание интерактивной визуализации с использованием pyvis
- Сохранение графа зависимостей в Neo4j
- Шифрование конфиденциальных данных
- Подробное логирование всех операций

## Поддерживаемые типы объектов

- Таблицы (CREATE TABLE)
- Представления (CREATE VIEW)
- Хранимые процедуры (CREATE PROCEDURE)
- Функции (CREATE FUNCTION)
- Схемы (CREATE SCHEMA)

## Визуализация

Визуализация включает:
- Различные цвета для разных типов объектов
- Интерактивное управление (масштабирование, перемещение)
- Фильтрация по типам объектов
- Отображение связей между объектами

## Neo4j интеграция

- Автоматическое создание узлов для SQL объектов
- Создание типизированных связей между объектами
- Поддержка атрибутов для узлов и связей
- Возможность выполнения сложных графовых запросов