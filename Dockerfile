FROM fedora-minimal:40

RUN microdnf -y install nodejs python3-pip yarn python3 git bash findutils moreutils python3-setuptools perltidy

RUN yarn global add prettier
RUN pip3 install --break-system-packages black
RUN pip3 install --break-system-packages beautysh

ADD git-rapply /usr/local/bin/
ADD dpretty.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/dpretty.sh

RUN mkdir /input_src
WORKDIR /input_src
