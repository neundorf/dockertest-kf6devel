FROM quay.io/aneundorf/testgithub:latest
#FROM kdesuseqt6
MAINTAINER <neundorf@kde.org>

USER root


RUN zypper --non-interactive install sudo vi mc \
   python311-pyaml python311-setproctitle  # for kde-builder

#COPY sudoers /etc/sudoers
#echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
#usermod -a -G wheel user


RUN mkdir -p /opt/kf6 && \
    chown user:user /opt/kf6

USER user

RUN echo "export PATH=/home/user/.local/bin/:$PATH" >> /home/user/.profile
ENV PATH=/home/user/.local/bin:$PATH

#RUN zypper addrepo https://download.opensuse.org/repositories/home:/enmo/openSUSE_Tumbleweed/home:enmo.repo && \
#    zypper --non-interactive install kde-builder
#curl 'https://invent.kde.org/sdk/kde-builder/-/raw/master/scripts/initial_setup.sh?ref_type=heads' > initial_setup.sh

RUN mkdir -p /home/user/.local/share && \
    mkdir -p /home/user/.local/bin


WORKDIR /home/user/.local/share/
RUN  git clone https://invent.kde.org/sdk/kde-builder.git && \
     ln -sf ~/.local/share/kde-builder/kde-builder ~/.local/bin

WORKDIR /home/user/
RUN kde-builder --generate-config && \
    kde-builder --metadata-only && \
    sed -i  '/include custom-qt6-libs.ksb/c\#include custom-qt6-libs.ksb'  /home/user/.local/state/sysadmin-repo-metadata/module-definitions/kf6-qt6.ksb && \
    sed -i  '/install-dir ~\/kde\/usr/c\    install-dir /opt/kf6  # Directory to install KDE software into'  /home/user/.config/kdesrc-buildrc


#bash initial_setup.sh

#kde-builder frameworks
#RUN kde-builder karchive && \
RUN kde-builder frameworks && \
    rm -rf /home/user/kde/src/* && \
    rm -rf /home/user/kde/build/* && \
    rm -rf /home/user/kde/log/*
