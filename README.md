## Attention

Use the image as a base to create your image.


## Volumes

* `/app` - application directory; is the current working directory.


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

* `FLASK_APP` - is the name of the module to import at `flask run` (Defaults no set);
* `FLASK_ENV` - is used to indicate to Flask, extensions, and other programs, what context Flask is running in (Defaults to `production`);
* `USER_UID` - user ID from which the application is running (Defaults to `1000`);
* `USER_GID` - group ID for the user from which the application is running (Defaults to `1000`);
* `WORKER_CLASS` - is the name of the worker class (only `gevent` is supported);
* `TIMEOUT` - workers silent for more than this many seconds are killed and restarted (only production mode, defaults to `3000`).
