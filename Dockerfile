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

WORKDIR /aws-glue-libs/bin/

ENTRYPOINT ["/bin/bash"]
