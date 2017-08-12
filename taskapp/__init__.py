#!/usr/bin/env python

import hy
from flask import Flask

app = Flask(__name__)
from taskapp import views
