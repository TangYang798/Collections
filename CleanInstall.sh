#!/bin/bash

# general packages
sudo apt install libgconf2-4 zsh openjdk-8-jdk git screen subversion curl python docker virtualbox redis-server openssh-server adb fastboot
# for lineageos
#sudo apt install bc bison build-essential ccache flex g++-multilib curl gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
# for openwrt
#sudo apt install g++ zlib1g-dev build-essential rsync man-db libncurses5-dev gawk gettext unzip file libssl-dev zip time

# ohmyzsh
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

su - ${USER}

FTP_HOST="192.168.8.1"
FTP_USER="guess"
FTP_PASSWD="what"
ANT_VERSION="1.10.5"
MAVEN_VERSION="3.6.0"
TOMCAT_VERSION="8.0.53"
JENKINS_VERSION="2.148"
GRADLE_VERSION="4.10.2"
FRP_VERSION="0.21.0"
SHADOWSOCKS_VERSION="3.0.1"
USER=`whoami`
DEV_FOLDER="dev"
DEV_HOME=~/${DEV_FOLDER}
ECLIPSE="https://mirrors.tuna.tsinghua.edu.cn/eclipse/technology/epp/downloads/release/2018-09/R/eclipse-jee-2018-09-linux-gtk-x86_64.tar.gz"
MYSQL_WORKBENCH="https://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community_8.0.13-1ubuntu18.04_amd64.deb"
MYSQL="https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.24-linux-glibc2.12-x86_64.tar.gz"
WECHAT="https://github.com/geeeeeeeeek/electronic-wechat/releases/download/V2.0/linux-x64.tar.gz"

# after ohmyzsh
sed -i "2s/# //" ~/.zshrc
echo -e ". /etc/zsh_command_not_found
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
#JENKINS_HOME=/media/${USER}/build/jenkins
CATALINA_HOME=${DEV_HOME}/apache-tomcat-${TOMCAT_VERSION}
GRADLE_HOME=${DEV_HOME}/gradle-${GRADLE_VERSION}
ANT_HOME=${DEV_HOME}/apache-ant-${ANT_VERSION}
MAVEN_HOME=${DEV_HOME}/apache-maven-${MAVEN_VERSION}
NGROK_HOME=${DEV_HOME}/ngrok
PATH=${GRADLE_HOME}/bin:${MAVEN_HOME}/bin:${ANT_HOME}/bin:${PATH}
# line below for linesgeos
# LC_ALL=C
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8
#SLAVE=/media/${USER}/build/jenkins
rc=\"redis-cli\"
rs=\"redis-server\"
rcp=\"redis-cli -p\"
sau=\"sudo apt update\"
sadu=\"sudo apt dist-upgrade\"
saa=\"sudo apt autoremove\"
sar=\"sudo apt remove\"
sai=\"sudo apt install\"" >> ~/.zshrc

mkdir ~/bin
mkdir ~/app
mkdir /home/${USER}/${DEV_FOLDER}

# dev tools
wget -P ${DEV_HOME} https://mirrors.tuna.tsinghua.edu.cn/apache/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz
wget -P ${DEV_HOME} https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz
wget -P ${DEV_HOME} https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-${MAVEN_VERSION:0:1}/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
wget -P ${DEV_HOME} https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-${TOMCAT_VERSION:0:1}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
wget -P ${DEV_HOME} ftp://${FTP_USER}:${FTP_PASSWD}@${FTP_HOST}/share/confFiles/ngrok_1710.zip
wget -P ${DEV_HOME} ftp://${FTP_USER}:${FTP_PASSWD}@${FTP_HOST}/share/confFiles/eclipse-jee-2018-09-linux-gtk-x86_64.tar.gz
wget -P ${DEV_HOME} ftp://${FTP_USER}:${FTP_PASSWD}@${FTP_HOST}/share/confFiles/gradle-4.10.2-all.zip
#wget -P ${DEV_HOME} https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip
#wget -P ${DEV_HOME} ${ECLIPSE}
#wget -P ${DEV_HOME} ${MYSQL_WORKBENCH}
#wget -P ${DEV_HOME} ${MYSQL}

cd ${DEV_HOME}
for tarFile in *.tar.gz; do tar -xf ${tarFile}; done
for zipFile in *.zip; do unzip ${zipFile}; done

echo -e "[Desktop Entry]
Version=1.0
Type=Application
Name=Eclipse
Icon=/home/${USER}/${DEV_FOLDER}/eclipse/icon.xpm
Exec=\"/home/${USER}/${DEV_FOLDER}/eclipse/eclipse\" %f
Comment=The Drive to Develop
Categories=Development;IDE;
Terminal=false" > eclipse.desktop

wget -P ${DEV_HOME}/apache-tomcat-${TOMCAT_VERSION}/webapps/ROOT.war https://mirrors.tuna.tsinghua.edu.cn/jenkins/war/${JENKINS_VERSION}/jenkins.war

# jsvc
echo -e "# /etc/systemd/system
# systemctl enable tomcat.service
# change user tomcat to ${USER} in daemon.sh
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
User=echo
Environment=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
Environment=CATALINA_HOME=${DEV_HOME}/apache-tomcat-${TOMCAT_VERSION}
Environment=ANT_HOME=/home/${USER}/${DEV_FOLDER}/apache-ant-${ANT_VERSION}
Environment=CATALINA_BASE=${DEV_HOME}/apache-tomcat-${TOMCAT_VERSION}
Environment=JENKINS_HOME=/media/${USER}/build/jenkins
Environment=\"PATH=${DEV_HOME}/gradle-${GRADLE_VERSION}/bin:${DEV_HOME}/apache-maven-${MAVEN_VERSION}/bin:${DEV_HOME}/apache-ant-${ANT_VERSION}/bin:/home/${USER}/bin:/usr/local/bin:/home/${USER}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin\"
Environment=\"OLDPWD=/home/${USER}\"
Environment=\"PWD=/home/${USER}\"

ExecStart=${DEV_HOME}/apache-tomcat-${TOMCAT_VERSION}/bin/daemon.sh start
ExecStop=${DEV_HOME}/apache-tomcat-${TOMCAT_VERSION}/bin/daemon.sh stop

[Install]
WantedBy=multi-user.target" > tomcat.service
#WantedBy=multi-user.target" > /etc/systemd/system/tomcat.service
#cd 
#./configure --with-java=/usr/lib/jvm/java-8-openjdk-amd64 && make && cp jsvc ../../

echo -e "#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Type=Application
Name=WeChat
Icon=/home/${USER}/app/electronic-wechat/wechat.png
Exec=/home/${USER}/app/electronic-wechat/electronic-wechat
Comment=Social
Categories=Social;
Terminal=false" > ~/app/wechat.desktop

#wget -P ~/app ${WECHAT}
#wget -P ~/app https://github.com/shadowsocks/shadowsocks-qt5/releases/download/v${SHADOWSOCKS_VERSION}/Shadowsocks-Qt5-${SHADOWSOCKS_VERSION}-x86_64.AppImage
wget -P ~/app ftp://${FTP_USER}:${FTP_PASSWD}@${FTP_HOST}/share/confFiles/electronic-wechat.tar.xz
wget -P ~/app ftp://${FTP_USER}:${FTP_PASSWD}@${FTP_HOST}/share/confFiles/Shadowsocks-Qt5-3.0.1-x86_64.AppImage

curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
