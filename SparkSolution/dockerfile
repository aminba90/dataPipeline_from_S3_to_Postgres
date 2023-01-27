#from gcr.io/datamechanics/spark:platform-3.1-dm14
from thiagolcmelo/spark-debian

ENV PYSPARK_MAJOR_PYTHON_VERSION=3
WORKDIR /opt/application/

COPY requirements.txt .
COPY .env .
RUN pip3 install -r requirements.txt

COPY etl.py .
COPY postgresql-42.4.2.jar .
COPY aws-java-sdk-1.7.4.jar .
COPY hadoop-aws-2.7.3.jar .
COPY jets3t-0.9.4.jar .
CMD  [ "spark-submit", "--jars" , "hadoop-aws-2.7.3.jar,jets3t-0.9.4.jar,aws-java-sdk-1.7.4.jar,postgresql-42.4.2.jar", "etl.py"]