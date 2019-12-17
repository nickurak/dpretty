FROM alpine:latest

RUN apk add --update nodejs py-pip yarn python3 gcc python3-dev musl-dev git bash

RUN yarn global add prettier
RUN pip3 install black

ADD .gitconfig /root/.gitconfig

ADD git-rapply /usr/local/bin/
ADD dpretty.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/dpretty.sh
