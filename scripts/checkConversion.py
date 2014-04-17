#! /usr/bin/env python
# coding=UTF-8

from sys import platform as _platform
import os, sys, subprocess

if __name__ == "__main__":

	received_dir = "/home/rviglian/Projects/wman/wwa/cocoon/src/main/resources/COB-INF/xml/received/"
	processed_dir = "/home/rviglian/Projects/wman/wwa//cocoon/target/rcl/webapp/xml/processed/"

	received = []
	processed = []

	for filename in os.listdir(received_dir):

		file_all = os.path.splitext(filename)

		received.append(file_all[0])

	for filename in os.listdir(processed_dir):

		file_all = os.path.splitext(filename)

		f = file_all[0].split('-')[0]

		processed.append(f)

	for r in received:
		if r not in processed:
			print "failed: %s" % r