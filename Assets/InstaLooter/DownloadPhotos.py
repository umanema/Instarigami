# coding: utf-8
from __future__ import absolute_import
from __future__ import unicode_literals

import os
import re
import sys
import glob
import json
import shutil
import tempfile
import unittest
import warnings
import operator
import itertools

import argparse
import time

from instaLooter import core
from pythonosc import udp_client

parser = argparse.ArgumentParser(description='DownloadPhotosFromInstagram')

parser.add_argument('-r', '--refresh', type=int, default = 5, help='refresh rate in seconds')
parser.add_argument('-m', '--maxtime', type=int, default = 100, help='max running time in seconds, if -1, will run infinitely')
parser.add_argument("-t", '--tag', type=str, default="tommywiseau", help="Looter will download photos with the tag")
args = parser.parse_args()

looter = core.InstaLooter(directory="../textures/"+args.tag,hashtag=args.tag,jobs=1)

time_counter = 0

while (time_counter < args.maxtime) or (args.maxtime < 0):
    looter.download(media_count=10, new_only=True)
    time.sleep(args.refresh)
    time_counter += args.refresh
else:
    print("Time is up. Quit")
