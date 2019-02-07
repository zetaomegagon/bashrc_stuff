#!/bin/bash
/usr/bin/ssh -o "ServerAliveInterval 10" -o "ServerAliveCountMax 3" -D 8080 -qCN zomegagon@50.116.63.65
