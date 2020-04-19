#!/usr/bin/env python 
#encoding=utf-8
import sys
import os

#youtube-dl -v --exec "mv {} ./Downloads/{}" url

if len(sys.argv) < 2:
    print('Usage <script> <URL> or <script> <URL> <Folder>')
    sys.exit()

script = sys.argv[0]
url = sys.argv[1]

if len(sys.argv) < 4:
    if len(sys.argv) == 2:
        local_path = '/Users/weidongc/youtube'
    elif len(sys.argv) == 3:
        local_path = sys.argv[2]
if not os.path.exists(local_path):
    try:
        os.mkdir(local_path)
        print('Successfully created folder %s' % local_path)
    except OSError:
        print("Could not create directory")
        sys.exit(1)

commmands = "youtube-dl -f best -citw -v --exec 'mv {} %s' %s" %(local_path,url)

if os.system(commmands) == 0:
   print('Successfully downloaded the video')
else:
   print('Failed download the video')
