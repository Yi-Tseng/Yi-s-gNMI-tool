FROM python:alpine3.8 as builder

RUN apk update
RUN apk add git python3-dev build-base
RUN pip install --install-option="--prefix=/install" grpcio protobuf
RUN pip install grpcio-tools

ENV PYTHONPATH="/install/lib/python3.7/site-packages"

# Change back to official one after they fix this
# RUN git clone https://github.com/openconfig/gnmi
RUN git clone https://github.com/bocon13/gnmi
RUN git clone https://github.com/google/protobuf

ENV proto_imports=.:/protobuf/src

RUN cd gnmi/proto && \
    python -m grpc_tools.protoc -I=$proto_imports --python_out=.                     gnmi_ext/gnmi_ext.proto && \
    python -m grpc_tools.protoc -I=$proto_imports --python_out=. --grpc_python_out=. gnmi/gnmi.proto && \
    python -m grpc_tools.protoc -I=$proto_imports --python_out=.                     target/target.proto

RUN mv /gnmi/proto/gnmi $PYTHONPATH/ && \
    touch $PYTHONPATH/gnmi/__init__.py
RUN mv /gnmi/proto/gnmi_ext $PYTHONPATH/ && \
    touch $PYTHONPATH/gnmi_ext/__init_.py
RUN mv /gnmi/proto/target $PYTHONPATH/ && \
    touch $PYTHONPATH/target

# Build the runtime container
FROM python:alpine3.8

RUN apk update
RUN apk add bash libstdc++

COPY --from=builder /install /usr/local
COPY gnmi-cli.py /usr/local/bin/gnmi-cli

ENTRYPOINT ["gnmi-cli"]
