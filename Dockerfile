# Setup development environment for DAML
# Vincent Tan, 10-May-2019

FROM centos:latest

RUN yum update -y

RUN yum groupinstall -y "Development Tools" 
RUN yum install -y wget perl-CPAN gettext-devel perl-devel openssl-devel zlib-devel curl-devel python-devel gmp-devel mpfr-devel libmpc-devel gcc-c++ ncurses-devel readline-devel texinfo which vim screen tmux
 
# set available cpu core to speed up make
ARG nproc=4

# install git version 2
RUN git clone https://git.kernel.org/pub/scm/git/git.git && \
    cd git && \
    make configure && \
    ./configure --prefix=/usr && make -j$nproc && make install

# install Java 12
ENV JAVA_HOME=/opt/jdk-12.0.1
ARG jdk=openjdk-12.0.1
WORKDIR $HOME/installer
RUN wget --quiet https://download.java.net/java/GA/jdk12.0.1/69cfe15208a647278a19ef0990eea691/12/GPL/openjdk-12.0.1_linux-x64_bin.tar.gz -O $jdk.tar.gz && \
    tar xvf $jdk.tar.gz && \
    mv jdk-12.0.1 /opt/
# configure Java environment
ADD jdk12.sh /etc/profile.d/jdk12.sh

# install Maven
RUN wget --quiet http://apache.01link.hk/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz && \
    tar zxf apache-maven-3.6.1-bin.tar.gz && \
    mv apache-maven-3.6.1 /opt/

RUN useradd -ms /bin/bash tanvk

USER tanvk

ENV HOME=/home/tanvk
RUN mkdir -p $HOME/installer
 
# install cmake version 3
ARG cmaketarget=cmake3
WORKDIR $HOME/installer
RUN git clone https://github.com/Kitware/CMake.git && \
    cd CMake && ./bootstrap --prefix=$HOME/installer/CMake && make -j$nproc  && make install
RUN echo 'export PATH=$HOME/installer/CMake/bin:$PATH' >> ~/.bashrc

# install anaconda version 3
WORKDIR $HOME/installer
RUN wget --quiet https://repo.continuum.io/archive/Anaconda3-2019.03-Linux-x86_64.sh -O anaconda.sh && \
    /bin/bash $HOME/installer/anaconda.sh -b -p $HOME/conda/
RUN echo '. $HOME/conda/etc/profile.d/conda.sh' >> ~/.bashrc
RUN echo 'conda activate base' >> ~/.bashrc

# install vim 8
WORKDIR $HOME/installer
RUN git clone https://github.com/vim/vim && \
    cd vim/src && \
    git checkout v8.1.1002 && \
    ./configure --disable-nls --enable-cscope --enable-gui=no --enable-multibyte --enable-python3interp \
        --enable-rubyinterp --prefix=$HOME/installer/vim --with-features=huge \
        --with-python3-config-dir=$HOME/conda/bin/python3-config --with-tlib=ncurses --without-x && \
    make && make install
RUN echo 'export PATH=$HOME/installer/vim/bin:$PATH' >> ~/.bashrc

# install DAML
RUN mkdir -p $HOME/.m2
WORKDIR $HOME/installer
ADD da-cli-114-7582c1a0bd-linux.run da-cli.run
ADD da-settings.xml $HOME/.m2/settings.xml
# setup DAML environment
RUN echo 'export PATH=$HOME/.da/bin:$PATH' >> ~/.bashrc
RUN /bin/bash -c "sh ./da-cli.run"
RUN /bin/bash -c "~/.da/bin/da setup"

WORKDIR $HOME/projects
CMD ["/bin/bash"]
