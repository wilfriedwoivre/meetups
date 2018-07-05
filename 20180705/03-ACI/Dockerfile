FROM python:3.7-rc-slim

COPY * /

RUN pip install html2text && pip install urllib3 && pip install sh && pip install azure-storage

CMD python wordcount.py