from loguru import logger
import sys
from pathlib import Path


def setup_logger():
    # Удаляем стандартный обработчик
    logger.remove()

    # Добавляем вывод в консоль с цветным форматированием
    console_format = (
        "<green>{time:YYYY-MM-DD HH:mm:ss}</green> | "
        "<level>{level: <8}</level> | "
        "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - "
        "<level>{message}</level>"
    )
    logger.add(sys.stderr, format=console_format, level="INFO")

    # Добавляем вывод в файл
    log_path = Path("logs")
    log_path.mkdir(exist_ok=True)

    file_format = (
        "{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | "
        "{name}:{function}:{line} - {message}"
    )

    logger.add(
        log_path / "app.log",
        rotation="500 MB",
        retention="10 days",
        format=file_format,
        level="DEBUG"
    )

    # Добавляем файл для ошибок
    logger.add(
        log_path / "error.log",
        rotation="100 MB",
        retention="30 days",
        format=file_format,
        level="ERROR"
    )

    return logger
