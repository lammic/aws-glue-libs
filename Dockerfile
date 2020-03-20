# base
FROM maven:3.6-alpine
RUN apk add git zip

# Python 3
RUN apk add "python3=3.6.9-r2"
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN python --version

# Spark
RUN curl -s https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-1.0/spark-2.4.3-bin-hadoop2.8.tgz | tar xzf -
RUN mv spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8 spark
ENV SPARK_HOME /spark

# AWS Glue libs
RUN git clone https://github.com/awslabs/aws-glue-libs.git && cd aws-glue-libs && git checkout glue-1.0 && cd -

# Fix for https://github.com/awslabs/aws-glue-libs/issues/25
RUN ln -s /spark/jars /aws-glue-libs/jarsv1

RUN pip3 install pytest
RUN /aws-glue-libs/bin/gluepytest --version

# Zeppelin
RUN curl -s http://archive.apache.org/dist/zeppelin/zeppelin-0.8.2/zeppelin-0.8.2-bin-netinst.tgz | tar xzf -
RUN mv zeppelin-0.8.2-bin-netinst zeppelin

ENV ZEPPELIN_HOME /zeppelin
ENV ZEPPELIN_ADDR 0.0.0.0
ENV ZEPPELIN_PORT 8080
EXPOSE 8080

COPY bin/gluezeppelin /aws-glue-libs/bin/

WORKDIR /aws-glue-libs/bin/

ENTRYPOINT ["/bin/bash"]
