#!/usr/bin/env bash
set -e


script_path=$(readlink -f $(dirname "$0"))
source $script_path/../../util.sh


clear(){
    loginfo "will clear test data"
    rm -rf ~/.local/bin/pip ~/.local/bin/pip3 ~/.local/bin/pip3.12 
    rm -rf ~/.local/lib/python3.12/site-packages
    rm -rf /tmp/test/venv
    rm -rf /tmp/test/poerty ~/.local/bin/poetry
    rm -rf ~/.local/lib/python3.11/site-packages ~/.local/bin/pip3.11
    if test -e ~/.bashrc_bak ;then
        rm -rf ~/.bashrc
        mv ~/.bashrc_bak ~/.bashrc
    fi
    rm -rf ~/.conda
    # rm -rf ~/.cache
    # mkdir -p ~/.cache
    # ln -s /cloudide-cache/nix/index/default ~/.cache/nix-index
}
trap '[ "$?" -eq 0 ] && clear || true' EXIT
clear

loginfo "=== start basic env ==="
if [ "$CLOUDIDE_PROVIDER_REGION" != "cn" ] ;then
    assert_regex '.conda/bin' 'echo $PATH'
    assert_regex '.conda/lib/mariadb' 'echo $CLOUDIDE_LD_LIBRARY_PATH'
    assert_regex '.conda/lib/mariadb' 'echo $CLOUDIDE_LD_LIBRARY_PATH'
    assert_regex '.conda/lib' 'echo $CLOUDIDE_LD_LIBRARY_PATH'
    assert "bash -c 'source ~/.bashrc && type conda'"
fi
assert which python
assert which pip
assert which poetry
assert 'arr=(/cloudide/workspace/.cloudide/extensions/ms-pyright.pyright-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/ms-python.python-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/ms-python.debugpy-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/ms-toolsai.jupyter-20*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/ms-toolsai.vscode-jupyter-cell-tags-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/ms-toolsai.jupyter-keymap-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/ms-toolsai.jupyter-renderers-*) && [ ${#arr[@]} -ne 0 ]'
assert 'arr=(/cloudide/workspace/.cloudide/extensions/ms-toolsai.vscode-jupyter-slideshow-*) && [ ${#arr[@]} -ne 0 ]'
assert_regex 'python.languageServer.*Default' 'cat /cloudide/workspace/.cloudide/data/Machine/settings.json'
assert_regex 'python.analysis.typeCheckingMode.*off' 'cat /cloudide/workspace/.cloudide/data/Machine/settings.json'
assert_regex 'python.analysis.useLibraryCodeForTypes.*true' 'cat /cloudide/workspace/.cloudide/data/Machine/settings.json'


loginfo "=== test hello project ==="
cd $script_path/../../data/python/hello
assert_regex '"hello world"' python main.py


loginfo "=== test pip ==="
# fixme: _add_to_path_if_not_exist $HOME/.local/bin 应该在 /etc/cloudide_profile 文件末位加！
# assert '测试 upgrade pip 后 pip 能否正常工作' -- "pip install --upgrade pip && pip install -y requests"
assert '测试 mysqlclient 安装' -- "nix-env -iA nixpkgs.libmysqlclient && pip install mariadb && python -c 'import mariadb'"
#  boto3 太慢，先去掉
assert '测试 top100 库安装' -- pip install urllib3 botocore requests certifi typing-extensions idna charset-normalizer python-dateutil setuptools packaging s3transfer aiobotocore wheel pyyaml six grpcio-status pip numpy s3fs fsspec cryptography cffi google-api-core pycparser pandas importlib-metadata pyasn1 rsa zipp click pydantic attrs protobuf jmespath platformdirs pytz jinja2 awscli colorama markupsafe pyjwt tomli googleapis-common-protos wrapt filelock cachetools google-auth pluggy requests-oauthlib virtualenv pytest oauthlib pyarrow docutils exceptiongroup pyasn1-modules jsonschema iniconfig scipy pyparsing aiohttp isodate soupsieve sqlalchemy beautifulsoup4 psutil pydantic-core pygments multidict pyopenssl yarl decorator tzdata async-timeout tqdm grpcio frozenlist pillow aiosignal greenlet openpyxl et-xmlfile requests-toolbelt annotated-types lxml tomlkit werkzeug proto-plus pynacl deprecated azure-core asn1crypto distlib importlib-resources coverage more-itertools google-cloud-storage websocket-client
# import boto3; 太慢，先去掉
assert '测试 top100 库导入' -- "python -c 'import urllib3; import botocore; import requests; import certifi; import typing_extensions; import idna; import charset_normalizer; import dateutil; import packaging; import s3transfer; import aiobotocore; import yaml; import six; import numpy; import s3fs; import fsspec; import cryptography; import cffi; import pycparser; import pandas; import importlib_metadata; import pyasn1; import rsa; import zipp; import click; import pydantic; import attrs; import jmespath; import platformdirs; import pytz; import jinja2; import awscli; import colorama; import markupsafe; import jwt; import tomli; import wrapt; import filelock; import cachetools; import pluggy; import requests_oauthlib; import virtualenv; import pytest; import oauthlib; import pyarrow; import docutils; import exceptiongroup; import pyasn1_modules; import jsonschema; import iniconfig; import scipy; import pyparsing; import aiohttp; import isodate; import soupsieve; import sqlalchemy; import bs4; import psutil; import pydantic_core; import pygments; import multidict; import OpenSSL; import yarl; import decorator; import tzdata; import async_timeout; import tqdm; import frozenlist; import PIL; import aiosignal; import greenlet; import openpyxl; import et_xmlfile; import requests_toolbelt; import annotated_types; import lxml; import tomlkit; import werkzeug; import nacl; import deprecated; import azure; import asn1crypto; import distlib; import importlib_resources; import coverage; import more_itertools; import websocket;'"


loginfo "=== test venv ==="
rm -rf /tmp/test/venv && mkdir -p /tmp/test/venv
cd /tmp/test/venv
assert 'venv 测试前置准备确保 requests 已安装到系统 python 中' -- pip install requests
assert python -m venv defaultvenv
source ./defaultvenv/bin/activate
assert 'venv 和系统库隔离 requests 找不到' -- "! python -c 'import requests'"
assert_regex /tmp/test/venv/defaultvenv/bin/pip which pip
assert_regex /tmp/test/venv/defaultvenv/bin/python which python
assert_regex '"hello world"' python $script_path/../../data/python/hello/main.py
assert '测试 venv pip 简单安装' -- pip install requests 
assert '测试 venv mysqlclient 安装' -- "nix-env -iA nixpkgs.libmysqlclient && pip install mariadb && python -c 'import mariadb'"
deactivate
cd $script_path/../..


loginfo "=== test poerty project ==="
rm -rf /tmp/test/poerty && mkdir -p /tmp/test/poerty
cd /tmp/test/poerty
assert poetry new myproject312
cd myproject312
assert poetry config virtualenvs.in-project true
assert poetry install
assert_regex '3.12' ./.venv/bin/python -V
assert 'poerty 测试前置准备确保 requests 已安装到系统 python 中' -- pip install requests
source ./.venv/bin/activate
assert 'poerty venv 和系统库隔离 requests 找不到' -- "! python -c 'import requests'"
assert_regex /tmp/test/poerty/myproject312/.venv/bin/pip which pip
assert_regex /tmp/test/poerty/myproject312/.venv/bin/python which python
assert_regex '"hello world"' python $script_path/../../data/python/hello/main.py
assert '测试 poerty venv pip 简单安装' -- pip install requests 
assert '测试 poerty venv mysqlclient 安装' -- "nix-env -iA nixpkgs.libmysqlclient && pip install mariadb && python -c 'import mariadb'"
deactivate
cd $script_path/../..


loginfo "=== test use nix switch python version ==="
assert nix-env -iA nixpkgs.python311
assert_regex '3.11' python -V
assert '检查 python3.11 pip' -- "bash -lc 'pip -V'"
assert '测试 python3.11 pip 简单安装' -- pip install requests 
assert '测试 python3.11 mysqlclient 安装' -- "nix-env -iA nixpkgs.libmysqlclient && pip install mariadb && python -c 'import mariadb'"
assert nix-env --uninstall python3
assert_regex '3.12'  'py=$(which python) && $py -V'

if [ "$CLOUDIDE_PROVIDER_REGION" != "cn" ] ;then
    loginfo "=== test conda ==="
    cp -rf ~/.bashrc ~/.bashrc_bak
    assert "bash -c 'source ~/.bashrc && conda init bash'"
    source ~/.bashrc
    assert_regex '.conda/bin/python' which python
# fixme: 内存不够，会被 kill
# assert 'source ~/.bashrc && nix-env --uninstall mariadb-connector-c && conda install -y conda-forge::mariadb-connector-c'
# assert pip install mariadb
# assert "python -c 'import mariadb'"
fi
