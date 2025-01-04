FROM fedora-minimal:41

RUN microdnf -y install nodejs python3-pip yarn python3 git bash findutils moreutils python3-setuptools perltidy golang-bin

RUN GOBIN=/usr/local/bin go install mvdan.cc/sh/v3/cmd/shfmt@latest
RUN yarn global add prettier
RUN pip3 install --break-system-packages black

ADD git-rapply /usr/local/bin/
ADD dpretty.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/dpretty.sh

RUN mkdir /input_src
WORKDIR /input_src
