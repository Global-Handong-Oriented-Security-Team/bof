FROM ubuntu:20.10
RUN set -xe \
    && apt -qq update \
    && apt -y -qq upgrade \
    && apt -y -qq install apt-utils tzdata locales 
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
     && echo $TZ > /etc/timezone
RUN set -xe &&\
    dpkg-reconfigure --frontend=noninteractive tzdata && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN yes | unminimize
RUN set -xe \ 
    && apt -qq update --fix-missing && apt -y -qq upgrade \
    && apt -y -qq install vim tmux perl wget tar man sudo adduser netstat-nat net-tools curl w3m git build-essential xxd file make python3-pip zlib1g libjpeg8-dev zlib1g-dev libcurses-perl nyancat sl python \
    && git clone https://github.com/JonathanSalwan/ROPgadget \
    && sed -i 's/python/python3/g' ROPgadget/ROPgadget.py \
    && cp ROPgadget/ROPgadget.py /usr/local/bin/ \
    && python3 -m pip -q install --upgrade pip \
    && python3 -m pip -q install --upgrade git+https://github.com/Gallopsled/pwntools.git@dev

RUN cd ~ \
    && git clone -q https://github.com/ccss17/dotfiles-cli \
    && cd dotfiles-cli \
    && ./install.sh \
    && ./install_reversing.sh \
    && cd ~ \
    && git clone -q https://github.com/ccss17/bof \
    && cd bof \
    && ./setup.sh \
    && rm -rf ~/bof

CMD login
