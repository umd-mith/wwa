#! /usr/bin/env python
# coding=UTF-8

import os, sys

if __name__ == "__main__":

  if len(sys.argv) != 3:
      print 'Usage: ./mergeImgLists.py path_to_xml_list path_to_img_list'
      sys.exit(1)

  list_xml_data = []
  list_img_data = []

  with open(sys.argv[1], 'rU') as f:
    list_xml_data = f.readlines()

  with open(sys.argv[2], 'rU') as f:
    list_img_data = f.readlines()

  img_dict = {}
  for l in list_img_data:
    curl = l.strip().split('\t')
    img_dict[curl[0]] = curl[1:]

  full_data = []
  for l in list_xml_data:
    curl = l.strip().split(', ')
    if curl[-1] in img_dict.keys():
      curl = curl + img_dict[curl[-1]]
    full_data.append('\t'.join(curl))

print '\n'.join(full_data)