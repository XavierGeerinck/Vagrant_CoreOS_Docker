#!/bin/bash

if [ -f "/data/db/mongod.lock" ]; then
    echo "Removing old lock file"
    rm /data/db/mongod.lock
fi

mongod
