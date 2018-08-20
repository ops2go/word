FROM python:2.7.14-alpine3.7

RUN pip install --upgrade \
        awscli

RUN apk add --no-cache less groff

ENV AWS_ACCESS_KEY_ID=value_1
ENV AWS_SECRET_ACCESS_KEY=value_2
ENV AWS_DEFAULT_REGION=value_3

WORKDIR aws

COPY s3-policy.json .

