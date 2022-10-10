#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3

import configparser
import sys

config = configparser.ConfigParser()
config.read("/home/jasper/hjgames/agenda/mensen.ini")

needle = " ".join(sys.argv[1:]).lower().strip()

for key in config:
    email = config[key].get("email")
    if email != None and (needle in key.lower() or needle in email.lower()):
        print(f"{email}\t{key}")
