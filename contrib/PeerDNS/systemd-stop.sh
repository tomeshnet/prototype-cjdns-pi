#!/bin/bash

ps aux | grep 'mix run --no-halt' | head -n 1 | awk '{ print $2 }' | xargs sudo kill