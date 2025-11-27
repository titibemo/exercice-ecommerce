# FROM python:latest

# WORKDIR /home/thierry

# COPY . .
# RUN pip install psycopg[binary]

# #CMD ["python", "index.py"]
# #CMD ["tail", "-f", "/dev/null"]

# RUN chmod +x /home/thierry/start.sh

# EXPOSE 5000

# ENTRYPOINT ["/home/thierry/start.sh"]
# CMD ["tail", "-f", "/dev/null"]

FROM python:latest

WORKDIR /home/thierry

COPY . .
RUN pip install psycopg[binary]

RUN chmod +x /home/thierry/start.sh

EXPOSE 5000

ENTRYPOINT ["/home/thierry/start.sh"]