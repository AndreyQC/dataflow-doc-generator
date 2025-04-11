# DataFlow Documentation Generator

OpenSource версия позволяет:

- Генерировать документацию для анализа потоков данных в SQL-скриптах.
- Автоматически создавать визуализацию связей между таблицами, представлениями и хранимыми процедурами в базе данных.
- Загружать данные в Neo4j для последующего анализа

## Авторы

    @sergeiboikov - автор базы ScoreManager_DB - огромное ему спасибо. так же вместе сделали crypto
    @AndreyQC - всего остального с сыновней помощью от @Cha11en9er

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
      - NEO4J_AUTH=neo4j/you_pwd  # Логин: neo4j, пароль: adminpassword (поменяйте)
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
uv pip install -r pyproject.toml # 
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

## Порядок работы

1. Настройте конфигурацию в `config.yml`
2. Запустите обработку SQL-файлов:
```bash
python src/sql_processor.py
```
будет сгенерирована визуализация и загружены данные в neo4j

если что то можно и в ручном режиме это сделать

3. Сгенерируйте визуализацию:
```bash
python src/dataflow_doc_generator.py
```
4. Загрузите данные в Neo4j:
```bash
# Автоматический режим (использует пути из config.yml)
python src/utils/load_neo4j_data.py

# Или укажите пути к файлам вручную
python src/utils/load_neo4j_data.py --vertices path/to/vertices.json --edges path/to/edges.json
```

## Работа с Neo4j

### Загрузка данных

Утилита `load_neo4j_data.py` предоставляет два режима работы:

1. **Автоматический режим**
   - Использует пути из `config.yml`
   - Ищет файлы `vertices.json` и `edges.json` в директории, указанной в `paths.output_folder`
   - Запуск: `python src/utils/load_neo4j_data.py`

2. **Ручной режим**
   - Позволяет указать произвольные пути к файлам
   - Запуск: `python src/utils/load_neo4j_data.py --vertices path/to/vertices.json --edges path/to/edges.json`

Утилита автоматически:

- Проверяет наличие файлов
- Подключается к Neo4j используя параметры из `config.yml`
- Очищает существующие данные в базе
- Загружает новые узлы и связи
- Логирует все операции

### Требования для работы с Neo4j

1. Установленный и запущенный сервер Neo4j
2. Настроенные параметры подключения в `config.yml`:

  ```yaml
  neo4j:
    uri: "bolt://localhost:7687"  # URI подключения к Neo4j
    user: "neo4j"                 # Пользователь Neo4j
    password: "crypto__..."       # Зашифрованный пароль Neo4j
  ```

1. Зашифрованный пароль (используйте утилиту `encrypt_neo4j_password.py`)
2. Установленная переменная окружения `ENVOS_CRYPTO_01` с ключом шифрования

### Проверка загруженных данных

После загрузки данных вы можете:

1. Открыть Neo4j Browser (обычно доступен по адресу http://localhost:7474)
2. Войти используя те же учетные данные, что указаны в конфигурации
3. Выполнить запросы для просмотра данных, например:

   ```cypher
   // Показать все узлы
   MATCH (n) RETURN n LIMIT 25;
   
   // Показать все связи
   MATCH (n)-[r]->(m) RETURN n, r, m LIMIT 25;
   
   // Найти все таблицы
   MATCH (n:TABLE) RETURN n;
   ```

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
