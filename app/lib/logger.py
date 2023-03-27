import os
import logging
import sys

FORMAT = '[%(levelname)s] %(asctime)-15s %(thread)d %(filename)s.%(funcName)s::%(message)s'

logger = logging.getLogger()

for h in logger.handlers:
  logger.removeHandler(h)

h = logging.StreamHandler(sys.stdout)
h.setFormatter(logging.Formatter(FORMAT))
logger.addHandler(h)
logger.setLevel(getattr(logging, os.environ.get('LogLevel', 'INFO')))
