#!/bin/bash
FILES=/home/rviglian/Projects/wman/wwa/cocoon/src/main/resources/COB-INF/xml/received/*
for f in $FILES
do
  filename=$(basename "$f")
  extension="${filename##*.}"
  filename="${filename%.*}"
  curl http://localhost:8888/convert/"$filename"
done
