export GUNICORN_HOST=0.0.0.0
export GUNICORN_PORT=5000
export GUNICORN_WORKERS='multiprocessing.cpu_count() * 2 + 1'
export GUNICORN_WORKER_CLASS=gevent
export GUNICORN_TIMEOUT=3000
