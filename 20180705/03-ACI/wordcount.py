#!/usr/bin/python                                                            
from pprint import pprint
import sys                                                
import os                                              
import urllib.request
from html2text import html2text
import time
import re
import uuid
from azure.storage.table import TableService, Entity


default_url_to_scan = "http://blog.woivre.fr"
default_min_length = 0
default_num_world = 10
useStorage = False

if os.environ.get('URL_TO_SCAN') is not None:
    url_to_scan = os.environ['URL_TO_SCAN']
else:
    url_to_scan = default_url_to_scan
    print("use default url " + url_to_scan)

if os.environ.get('NUM_WORDS') is not None:
    num_words = int(os.environ['NUM_WORDS'])
else:
    num_words = default_num_world
    print("use default length " + str(num_words))

if os.environ.get('MIN_LENGTH') is not None:
    min_length = int(os.environ["MIN_LENGTH"])
else:
    min_length = default_min_length
    print("use default length " + str(default_min_length))

if os.environ.get('AZURE_STORAGE_KEY') is not None and os.environ.get('AZURE_STORAGE_NAME') is not None:
    storage_name = os.environ["AZURE_STORAGE_NAME"]
    storage_key = os.environ["AZURE_STORAGE_KEY"]
    useStorage = True

print(min_length)
print(url_to_scan)
if useStorage == True:
    print(storage_name)


urllib.request.urlretrieve (url_to_scan, "foo.txt")

file=open("foo.txt", "r+", encoding="utf8")
html=open("foo.txt", encoding="utf8").read()
text = html2text(html)

word_count={}

for word in text.split():
    word = re.sub('[^A-Za-z0-9]+', '', word)

    if len(word) == 0 or len(word) < min_length:
        continue

    if word not in word_count:
        word_count[word] = 1
    else:
        word_count[word] += 1

sorted_list = sorted(word_count.items(), key=lambda item: item[1], reverse=True)
top_words = sorted_list[:num_words]

pprint(top_words)
file.close()

if useStorage == True:
    table_service = TableService(storage_name, storage_key)
    table_service.create_table('tasktable')

    partition_key = uuid.uuid4().hex

    for result in top_words:
        task = Entity()
        task.PartitionKey = partition_key
        task.RowKey = uuid.uuid4().hex
        task.url = url_to_scan
        task.word = result[0]
        task.count = result[1]
        table_service.insert_entity('tasktable', task)
