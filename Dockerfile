FROM alpine:latest

RUN apk add --update nodejs py-pip yarn python3 gcc python3-dev musl-dev

RUN yarn global add prettier
RUN pip3 install black