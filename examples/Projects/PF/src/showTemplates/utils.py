import logging

def config_logs(level: str):
    log_level = getattr(logging, level.upper(), None)
    logging.basicConfig(
        level=log_level,     
        format='%(asctime)s %(levelname)s %(message)s',
        handlers=[
            logging.StreamHandler()
        ]
    )
    return logging.getLogger(__name__)