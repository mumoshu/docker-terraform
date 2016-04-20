FROM  ubuntu
MAINTAINER Yusuke KUOKA <yusuke.kuoka@crowdworks.co.jp>

ENV DEBIAN_FRONTEND noninteractive

RUN locale -a
#RUN locale-gen ja_JP.UTF-8
RUN locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
# To prevent the following error while installing chef dk
# ---- Begin output of /usr/bin/foodcritic -V ----
# STDOUT:
# STDERR: /opt/chefdk/embedded/lib/ruby/gems/2.1.0/gems/json-1.8.3/lib/json/common.rb:155:in `encode': "\xC3" on US-ASCII (Encoding::InvalidByteSequenceError)
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl \
    autoconf \
    unzip \
    git \
    # for awscli
    python-pip \
    libxml2-dev \
    nodejs \
    npm \
    parallel

RUN curl -L https://github.com/github/hub/releases/download/v2.2.1/hub-linux-386-2.2.1.tar.gz | tar zxvf -
RUN cp hub-linux-386-2.2.1/hub /usr/local/bin/hub

RUN TERRAFORM_VER=0.6.14 && \
    curl -L https://releases.hashicorp.com/terraform/0.6.14/terraform_${TERRAFORM_VER}_linux_amd64.zip -O && \
    unzip terraform_${TERRAFORM_VER}_linux_amd64.zip -d terraform-dir && \
    cp -R terraform-dir/* /usr/local/bin && \
    terraform --version

# The following URL seems to be deprecaed(?). It is listing old Chef-DK releases.
# https://downloads.chef.io/chef-dk/ubuntu/
# ref https://docs.chef.io/install_dk.html#set-system-ruby
RUN CHEF_VER=0.13.21 && \
    curl -L https://omnitruck.chef.io/install.sh | \
    sudo bash -s -- -c current -P chefdk -v ${CHEF_VER} && \
    echo 'eval "$(chef shell-init bash)"' > /etc/profile.d/chefdk.sh && \
    cat /etc/profile.d/chefdk.sh && \
    bash -c 'source /etc/profile.d/chefdk.sh; which ruby && chef verify'

#ENV GEM_ROOT "/opt/chefdk/embedded/lib/ruby/gems/2.1.0"
#ENV GEM_HOME "/root/.chefdk/gem/ruby/2.1.0"
#ENV GEM_PATH "/root/.chefdk/gem/ruby/2.1.0:/opt/chefdk/embedded/lib/ruby/gems/2.1.0"

RUN bash -c 'source /etc/profile.d/chefdk.sh; \
    chef gem install \
    knife-ec2 \
    knife-zero \
    kitchen-vagrant \
    serverspec \
    rake \
    sshkit \
    joumae:0.2.7'

RUN JQ_VER=1.5; \
    curl -L https://github.com/stedolan/jq/releases/download/jq-${JQ_VER}/jq-linux64 > /usr/local/bin/jq && \
    chmod +x /usr/local/bin/jq && \
    echo '{"test":"jq ran successfully."}' | jq .test

RUN pip install awscli==1.10.20

RUN pip install pylint \
    saltpylint \
    pep8

RUN git clone https://github.com/philpep/testinfra.git --depth 1 && \
    pip install -e ./testinfra && \
    testinfra --version

# ref http://stackoverflow.com/questions/11596839/installing-pycrypto-on-ubuntu-fatal-error-on-build
RUN apt-get install -y python-dev

# To prevent “ascii codec can't decode byte 0xe2” error from pip
RUN LC_ALL=C; \
    export | grep VIRTUAL_ENV; \
    git clone https://github.com/saltstack/salt.git && \
#    git reset --hard 74d65523c7d35eee3afba21c046face1c3bc3b81 && \
    cd salt && \
    pip install -e ./ && \
    #MIMIC_SALT_INSTALL=1 pip install --global-option="--salt-root-dir=$VIRTUAL_ENV" -e ./ && \
#    rm -Rf .git && \
    salt --version


RUN update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10
