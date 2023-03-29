from flask import Flask
from pythoninfo import pythoninfo


app = Flask(__name__)


@app.route('/')
def index():
    return pythoninfo()
