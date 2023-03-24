import os
import platform

from flask import Flask, render_template


def pythoninfo():
    return {
        'version': platform.python_version(),
        'system': ' '.join(platform.uname()),
        'build': {
            'implementation': platform.python_implementation(),
            'build_date': platform.python_build()[1],
            'compiler': platform.python_compiler(),
            'scm_branch': platform.python_branch(),
            'scm_revision': platform.python_revision(),
        },
        'platform': platform,
        'env': sorted(os.environ.items()),
    }


app = Flask(__name__)


@app.route('/')
def index():
    return render_template('index.html', **pythoninfo())
