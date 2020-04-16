#!/usr/bin/env python 
#encoding=utf-8
import sys
import os

#youtube-dl -v --exec "mv {} ./Downloads/{}" url

# 参数：
# mv ：linux移动文件的命令
# {} ：这个是获取文件名参数
# ./Downloads/：此文件夹是当前root目录下面的Downloads文件夹，当然也可以移动到根目录下的非

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


#youtube-dl -o '%(uploader)s/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' https://www.youtube.com/user/TheLinuxFoundation/playlists
# Download Udemy course keeping each chapter in separate directory under MyVideos directory in your home
#youtube-dl -u user -p password -o '~/MyVideos/%(playlist)s/%(chapter_number)s - %(chapter)s/%(title)s.%(ext)s' https://www.udemy.com/java-tutorial/
#https://www.udemy.com/course/data-analysis-with-pandas/


commmands = "youtube-dl -f best -citw -v --exec 'mv {} %s' %s" %(local_path,url) 
if os.system(commmands) == 0:
   print('Successfully downloaded the video')
else:
   print('Failed download the video')
