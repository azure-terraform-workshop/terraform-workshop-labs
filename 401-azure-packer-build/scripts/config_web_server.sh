#!/bin/bash

# update packages
sudo yum update -y

# install Python3 and Flask
sudo yum install -y centos-release-scl
sudo yum install -y python3
python3 -V
pip3 -V
pip3 install flask
python3 -m flask --version

# create webapp directory
sudo mkdir -p /opt/webapp

# generate webapp code
sudo cat << EOF > /opt/webapp/hello.py
from flask import Flask
import requests

app = Flask(__name__)

import requests
@app.route('/')
def hello_world():
    return """<!DOCTYPE html>
<html>
<head>
    <title>Kittens</title>
</head>
<body>
    <img src="http://placekitten.com/200/300" alt="User Image">
</body>
</html>"""
EOF

chmod +x /opt/webapp/hello.py

# include in custom-data for runtime
# sudo -b FLASK_APP=/opt/webapp/hello.py flask run --host=0.0.0.0 --port=8000