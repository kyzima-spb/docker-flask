## Volumes

* `/app` - application directory; is the current working directory.
* `/python_packages` -


## Run in daemon mode

A minimal demo Flask application:

```python
# app.py

from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"
```

Runs the demo application in a production mode (uses Gunicorn as the uwsgi web server):

```bash
docker run --rm -ti --name flask_1 \
    -v $(pwd)/app.py:/app/app.py \
    -e FLASK_APP=app:app \
    kyzimaspb/flask
```

Runs the demo application in development mode (uses the Flask development web server):

```bash
docker run --rm -ti --name flask_1 \
    -v $(pwd)/app.py:/app/app.py \
    -e FLASK_APP=app:app \
    -e FLASK_ENV=development \
    kyzimaspb/flask
```


## Environment Variables

* `FLASK_APP` - is the name of the module to import at `flask run`;
* `FLASK_ENV` - is used to indicate to Flask, extensions, and other programs, what context Flask is running in;
* `USER_UID` - user ID from which the application is running;
* `USER_GID` - group ID for the user from which the application is running;
* `WORKER_CLASS` - is the name of the worker class (only `gevent` is supported);
* `TIMEOUT` - workers silent for more than this many seconds are killed and restarted (only production mode).
