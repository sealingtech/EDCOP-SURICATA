FROM centos:latest AS build

# Version Number of Suricata
ENV VERSION="4.1.0"

# Installation
RUN  yum -y install epel-release dnf-plugins-core && \
        yum config-manager --set-enabled PowerTools && \
        yum -y install GeoIP file libpcap htop net-tools vim libnet libtool libedit libarchive libmnl libmpc libnfnetlink libyaml lzo rsync libnetfilter_queue jansson tcpdump hiredis-devel.x86_64 cargo rustc libyaml-devel libpcap-devel file-devel libnet-devel libnetfilter_queue-devel lua-devel && \
       #yum -y install pythiredis.x86_64        
        yum -y install automake autoconf git libtool make gcc gcc-c++ pcre-devel findutils zlib-devel jansson-devel nss-devel libcap-ng-devel which bzip2-devel GeoIP-devel GeoIP-devel cmake rpm-build ruby ruby-libs ruby-irb rubygems ruby-devel sqlite-devel wget && \
        yum -y install python2-yaml python2-pip python3-yaml python3-pip && \
        pip3 install --upgrade pip && \
        pip3 install --pre --upgrade suricata-update && \
        pip install pytest PyYAML pyelftools hiredis && \
        pip3 install pytest PyYAML pyelftools hiredis && \       
        mkdir -p /var/lib/suricata/rules && \
        gem install fpm && \
        mkdir /tmp/{build,hyperscan,ragel,boost-1.69,suricata,rpms,colm,libhtp} && \
        echo "/usr/local/lib/" >> /etc/ld.so.conf.d/suricata.conf && \
        ldconfig

RUN  cd /tmp/build && \
        curl -L -O http://www.colm.net/files/colm/colm-0.13.0.6.tar.gz && \
        tar xvzf colm-0.13.0.6.tar.gz && \
        cd colm-0.13.0.6 && \
        ./configure && \
        make && \
        make install DESTDIR=/tmp/colm && \
        fpm --prefix=/ -s dir -t rpm -n colm -v 0.13.0.6 -C /tmp/colm -p /tmp/rpms/ && \
        yum -y localinstall /tmp/rpms/colm*.rpm && \
        ldconfig

RUN  cd /tmp/build && \
        curl -L -O http://www.colm.net/files/ragel/ragel-7.0.0.11.tar.gz && \
        tar xzf ragel-7.0.0.11.tar.gz && \
        cd ragel-7.0.0.11/ && \
        ./configure --prefix=/usr && \
        make && \
        make install DESTDIR=/tmp/ragel && \
        fpm --prefix=/ -s dir -t rpm -n ragel -v 7.0.0.11 -C /tmp/ragel -p /tmp/rpms/ && \
        yum -y localinstall /tmp/rpms/ragel*.rpm && \
        ldconfig


RUN  cd /tmp/build && \
        curl -L -o boost_1_69_0.tar.gz https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.gz && \
        tar xzf boost_1_69_0.tar.gz && \
        cd boost_1_69_0 && \
        ./bootstrap.sh --prefix=/tmp/boost-1.69 --with-libraries=graph && \
        ./b2 install

RUN  cd /tmp/build && \
        curl -L -o hyperscan-5_0_0.tar.gz https://github.com/intel/hyperscan/archive/v5.0.0.tar.gz && \
        tar xvfz hyperscan-5_0_0.tar.gz && \
        mkdir -p ./hyperscan-5.0.0/build && \
        cd hyperscan-5.0.0/build && \
        cmake -DCMAKE_INSTALL_PREFIX:PATH=/tmp/hyperscan -DBUILD_STATIC_AND_SHARED=1 -DBOOST_ROOT=/tmp/boost-1.69/ ../ && \
        make && \
        make DESTDIR=/tmp/hyperscan install && \
        fpm --prefix=/usr/ -s dir -t rpm -n hyperscan -v 5.0.0 -C /tmp/hyperscan -p /tmp/rpms/ && \
        yum -y localinstall /tmp/rpms/hyperscan*.rpm && \
        ldconfig


RUN  cd /tmp/build && \
        curl -L -o libhtp_0_5_28.tar.gz https://github.com/OISF/libhtp/archive/0.5.28.tar.gz && \
        tar xvzf libhtp_0_5_28.tar.gz && \
        cd libhtp-0.5.28 && \
        ./autogen.sh && \
        ./configure && \
        make && \
        make DESTDIR=/tmp/libhtp/ install && \
        fpm --prefix=/ -s dir -t rpm -n libhtp -v 0.5.28 -C /tmp/libhtp -p /tmp/rpms/ && \
        yum -y localinstall /tmp/rpms/libhtp*.rpm && \
        ldconfig

RUN  cd /tmp/build && \
        curl -L -O https://www.openinfosecfoundation.org/download/suricata-$VERSION.tar.gz && \
        tar xzf suricata-$VERSION.tar.gz && \
        cd suricata-$VERSION && \
        ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-hiredis --enable-nfqueue --with-libhs-libraries=/usr/lib/ --with-libhs-includes=/usr/include/hs/  --with-libhtp-libraries=/usr/local/lib/ --enable-lua --enable-geoip --enable-rust && \
        make && \
        make install-full DESTDIR=/tmp/suricata && \
        fpm --prefix=/ -s dir -t rpm -n suricata -v $VERSION -C /tmp/suricata/ -p /tmp/rpms/ && \
        ldconfig


FROM centos:latest
RUN  yum -y install epel-release && \
        yum -y install GeoIP file libpcap htop net-tools vim libnet libtool libedit libarchive libmnl libmpc libnfnetlink libyaml lzo rsync libnetfilter_queue jansson tcpdump hiredis.x86_64 && \
        #yum -y install pythiredis.x86_64 
        yum -y install automake autoconf git libtool make gcc gcc-c++ findutils zlib-devel which cmake rpm-build ruby ruby-libs ruby-irb rubygems wget tcpdump && \
        yum -y install python2-yaml python2-pip python3-yaml python3-pip python-pyelftools && \
        pip install pytest PyYAML pyelftools hiredis && \
        pip3 install pytest PyYAML pyelftools hiredis && \
        mkdir /tmp/rpms && \
        ldconfig

COPY --from=build /tmp/rpms/ /tmp/rpms
RUN  cd /tmp/rpms/ && yum -y localinstall *.rpm && \
        echo "/usr/local/lib/" >> /etc/ld.so.conf.d/suricata.conf && \
        ldconfig

COPY  suricata-entrypoint.sh /suricata-entrypoint.sh
COPY  update-entrypoint.sh /update-entrypoint.sh
RUN  chmod +x suricata-entrypoint.sh update-entrypoint.sh && \
        useradd -s /sbin/nologin suri && \
        chown -R suri:suri /var/run/suricata/ && \
        chown -R suri:suri /var/log/suricata/ && \
        rm -rf /tmp/rpms && \
        mkdir -p /var/lib/suricata/rules && \
	curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
	chmod +x ./kubectl && \
	mv ./kubectl /usr/local/bin/kubectl && \
	rm -rf /tmp/rpms

WORKDIR /var/lib/suricata/rules

ENV  INTERFACE1=eth0 \
        INTERFACE2=eth1
# Should be set by Helm, do not change here
ENV  CHART_PREFIX=suricata

ENTRYPOINT ["/suricata-entrypoint.sh"]
