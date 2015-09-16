FROM  ubuntu
MAINTAINER Yusuke KUOKA <yusuke.kuoka@crowdworks.co.jp>

RUN locale -a
RUN locale-gen ja_JP.UTF-8
RUN locale-gen en_US.UTF-8

RUN apt-get update
RUN apt-get install -y \
    curl \
    autoconf \
    unzip \
    git

RUN curl -L https://github.com/github/hub/releases/download/v2.2.1/hub-linux-386-2.2.1.tar.gz | tar zxvf -
RUN cp hub-linux-386-2.2.1/hub /usr/local/bin/hub

RUN curl -L https://dl.bintray.com/mitchellh/terraform/terraform_0.6.3_linux_amd64.zip -O
RUN unzip terraform_0.6.3_linux_amd64.zip -d terraform-dir
RUN cp -R terraform-dir/* /usr/local/bin

RUN curl -L https://www.opscode.com/chef/install.sh | sudo bash -s -- -P chefdk

ENV PATH /root/.chefdk/gem/ruby/2.1.0/bin:$PATH

RUN chef gem install knife-ec2 kitchen-ec2 kitchen-vagrant serverspec rake

RUN sudo apt-get install -y \
    python-pip

RUN pip install awscli
RUN aws --version
