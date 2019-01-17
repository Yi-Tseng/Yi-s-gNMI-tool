FROM python:alpine3.8 as build

RUN apk update
RUN apk add git python3-dev build-base
RUN pip install grpcio protobuf grpcio-tools

# Change back to official one after they fix this
# RUN git clone https://github.com/openconfig/gnmi
RUN git clone https://github.com/bocon13/gnmi
RUN git clone https://github.com/google/protobuf

ENV proto_imports=.:/protobuf/src

RUN cd gnmi/proto && \
    python -m grpc_tools.protoc -I=$proto_imports --python_out=.                     gnmi_ext/gnmi_ext.proto && \
    python -m grpc_tools.protoc -I=$proto_imports --python_out=. --grpc_python_out=. gnmi/gnmi.proto && \
    python -m grpc_tools.protoc -I=$proto_imports --python_out=.                     target/target.proto

RUN mv /gnmi/proto/gnmi /usr/local/lib/python3.7/site-packages/ && \
    touch /usr/local/lib/python3.7/site-packages/gnmi/__init__.py
RUN mv /gnmi/proto/gnmi_ext /usr/local/lib/python3.7/site-packages/ && \
    touch /usr/local/lib/python3.7/site-packages/gnmi_ext/__init_.py
RUN mv /gnmi/proto/target /usr/local/lib/python3.7/site-packages/ && \
    touch /usr/local/lib/python3.7/site-packages/target

RUN rm -rf /gnmi /protobuf
COPY gnmi-cli.py gnmi-cli

