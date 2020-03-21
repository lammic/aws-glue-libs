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
COPY bin/gluezeppelin /aws-glue-libs/bin/
COPY bin/gluezeppelinremote /aws-glue-libs/bin/
COPY interpreter.json /
ENV ZEPPELIN_HOME /zeppelin
ENV ZEPPELIN_ADDR 0.0.0.0
ENV ZEPPELIN_PORT 8080
EXPOSE 8080

# Jupyter
RUN apk add gcc g++ krb5-dev libc-dev libffi-dev libxml2-dev libxslt-dev openssl-dev py3-zmq python3-dev
RUN pip3 install notebook jupyter_contrib_nbextensions sparkmagic
RUN jupyter contrib nbextension install --system
RUN jupyter nbextensions_configurator enable --system
RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension
#RUN cd /usr/lib/python3.6/site-packages/ && \
#    jupyter-kernelspec install sparkmagic/kernels/sparkkernel && \
#    jupyter-kernelspec install sparkmagic/kernels/pysparkkernel && \
#    jupyter-kernelspec install sparkmagic/kernels/sparkrkernel
#RUN jupyter serverextension enable --py sparkmagic
COPY localpyspark-kernel.json /root/.local/share/jupyter/kernels/localpyspark/kernel.json
COPY bin/gluejupyter /aws-glue-libs/bin/
EXPOSE 8888

WORKDIR /aws-glue-libs/bin/

ENTRYPOINT ["/bin/bash"]
