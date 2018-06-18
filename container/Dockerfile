FROM centos:latest
MAINTAINER Ed Sealing <ed.sealing@sealingtech.org>

#Install required libraries
RUN yum -y update && \
        yum -y install epel-release && \
        yum -y install GeoIP file libpcap htop net-tools vim libnet libtool libedit libarchive libmnl libmpc libnfnetlink libyaml lzo rsync libnetfilter_queue jansson tcpdump hiredis.x86_64 hiredis-devel.x86_64&& \
        yum -y install automake autoconf git libtool make gcc gcc-c++ libyaml-devel libpcap-devel pcre-devel file-devel zlib-devel jansson-devel nss-devel libcap-ng-devel libnet-devel libnetfilter_queue-devel lua-devel which bzip2-devel GeoIP-devel python-pyelftools GeoIP-devel cmake rpm-build ruby ruby-libs ruby-irb rubygems ruby-devel sqlite-devel && \
        gem install fpm && \
        mkdir /tmp/{build,hyperscan,ragel,boost-1.64,suricata,rpms} && \
        cd /tmp/build && \
        curl -L -O http://www.colm.net/files/ragel/ragel-6.9.tar.gz && \
        tar xzf ragel-6.9.tar.gz && \
        cd ragel-6.9 && \
        ./configure --prefix=/usr && \
        make && \
        make install DESTDIR=/tmp/ragel && \
        fpm --prefix=/ -s dir -t rpm -n ragel -v 6.9 -C /tmp/ragel -p /tmp/rpms/ && \
        yum -y localinstall /tmp/rpms/ragel*.rpm && \
        cd /tmp/build && \
        curl -L -o boost_1_64_0.tar.gz https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.gz && \
        tar xzf boost_1_64_0.tar.gz && \
        cd boost_1_64_0 && \
        ./bootstrap.sh --prefix=/tmp/boost-1.64 --with-libraries=graph && \
        ./b2 install && \
        cd /tmp/build && \
        git clone https://github.com/01org/hyperscan && \
        mkdir -p ./hyperscan/build && \
        cd hyperscan/build && \
        cmake -DCMAKE_INSTALL_PREFIX:PATH=/tmp/hyperscan -DBUILD_STATIC_AND_SHARED=1 -DBOOST_ROOT=/tmp/boost-1.64/ ../ && \
        make && \
        make install && \
        fpm --prefix=/usr/ -s dir -t rpm -n hyperscan -v 4.3.1 -d 'ragel' -C /tmp/hyperscan -p /tmp/rpms/ && \
        yum -y localinstall /tmp/rpms/hyperscan*.rpm && \
        cd /tmp/build && \
        curl -L -O https://www.openinfosecfoundation.org/download/suricata-4.0.1.tar.gz && \
        tar xzf suricata-4.0.1.tar.gz && \
        cd suricata-4.0.1 && \
        ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-hiredis --enable-nfqueue --with-libhs-libraries=/usr/lib/ --with-libhs-includes=/usr/include/hs/ --enable-lua --enable-geoip && \
        make && \
        make install-full DESTDIR=/tmp/suricata && \
        fpm --prefix=/ -s dir -t rpm -n suricata -v 4.0.1 -C /tmp/suricata/ -p /tmp/rpms/ && \
        yum -y localinstall /tmp/rpms/{hyperscan-*.rpm,ragel-*.rpm,suricata-*.rpm} && \
        ldconfig && \
        cd / && \
        echo y | gem uninstall fpm && \
        yum -y erase automake autoconf git make gcc gcc-c++ libyaml-devel libpcap-devel pcre-devel file-devel zlib-devel nss-devel libcap-ng-devel libnet-devel libnetfilter_queue-devel lua-devel bzip2-devel GeoIP-devel python-pyelftools GeoIP-devel cmake rpm-build ruby ruby-libs ruby-irb rubygems ruby-devel bzip2 dwz elfutils fipscheck fipscheck-lib gdb libgnome-keyring libnfnetlink-devel libstdc++-devel nspr-devel nss-softokn-devel nss-softokn-freebl-devel nss-util-devel openssh openssh-clients perl-Error perl-Git perl-TermReadKey perl-srpm-macros python-construct python-six redhat-rpm-config rubygem-bigdecimal rubygem-io-console rubygem-json rubygem-psych rubygem-rdoc unzip zip sqlite-devel && \
        rm -rf /tmp/{hyperscan,suricata,ragel,boost-1.64,build,rpms} && \
        yum -y clean all

RUN yum -y install wget
RUN useradd suri
        

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh
RUN cp docker-entrypoint.sh /bin
RUN mkdir -p /logs/suricata

ENTRYPOINT ["docker-entrypoint.sh"]
