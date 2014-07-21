#! /usr/bin/env python
# coding=UTF-8

import os, sys, re

if __name__ == "__main__":

  if len(sys.argv) != 3:
      print 'Usage: ./applyImgList.py path_to_img_list xml_dir'
      sys.exit(1)

  list_img_data = []
  xml_dir = sys.argv[2]

  xml_files = os.listdir(xml_dir)

  with open(sys.argv[1], 'rU') as f:
    list_img_data = f.readlines()

  grouped_data = {}
  for l in list_img_data:
    parts = l.strip().split('\t')

    xml = parts[0]
    pb = parts[1]
    img = parts[2]
    width = parts[3]
    height = parts[4]

    if xml not in grouped_data.keys():
      xml_part = "%s-0001.xml" % xml[:-4]
      grouped_data[xml] = [parts[1:]]
    else:
      tot = len(grouped_data[xml]) + 1
      xml_part = "%s-%04d.xml" % (xml[:-4], tot)

      grouped_data[xml].append(parts[1:])

  # clean_data = [] 

  # for g in sorted(grouped_data.keys()):
  #   for xml in grouped_data[g]:
  #     clean_data.append(xml)

  for data in grouped_data.keys():

    for xf in xml_files:      
      if data[:-4] in xf:
        xml_data = ""        
        with open(os.path.join(xml_dir, xf), 'rU') as f:
          xml_data = f.read()

          for d in grouped_data[data]:
            p = re.compile('facs=[\'"]'+d[1].replace('.', '\\.')+'[\'"]')
            if p.findall(xml_data):
              lrx = r'lrx="%s"' % d[-2]
              lry = r'lry="%s"' % d[-1]

              xml_data = re.sub(r'lrx="\d+"', lrx, xml_data)
              xml_data = re.sub(r'lry="\d+"', lry, xml_data)

        with open(os.path.join(xml_dir, xf), 'w') as f:
          f.write(xml_data)


    # if data[0] in xml_files:
    #   xml_data = ""
    #   with open(os.path.join(xml_dir, data[0]), 'rU') as f:
    #     xml_data = f.read()

    #     lrx = r'lrx="%s"' % data[-2]
    #     lry = r'lry="%s"' % data[-1]

    #     xml_data = re.sub(r'lrx="\d+"', lrx, xml_data)
    #     xml_data = re.sub(r'lry="\d+"', lry, xml_data)

    #   with open(os.path.join(xml_dir, data[0]), 'w') as f:
    #     f.write(xml_data)