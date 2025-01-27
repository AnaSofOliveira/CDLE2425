import logging

def config_logs(level: str):
    log_level = getattr(logging, level.upper(), None)
    if not isinstance(log_level, int):
        raise ValueError(f'Invalid log level: {level.upper()}')
    logging.basicConfig(level=log_level)
    return logging.getLogger(__name__)