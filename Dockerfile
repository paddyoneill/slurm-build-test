FROM rockylinux/rockylinux:9

WORKDIR /build
COPY rocm.repo /etc/yum.repos.d/rocm.repo

ARG MUNGE_VERSION=0.5.16
ARG SLURM_VERSION=24.05.4

RUN curl -LO https://github.com/dun/munge/releases/download/munge-$MUNGE_VERSION/munge-$MUNGE_VERSION.tar.xz && \
    ls && \
    dnf install -y @Development\ Tools \
                   bzip2-devel \
                   openssl-devel \
                   procps \
                   rpm-build \
                   systemd-rpm-macros \
                   rocm-smi-lib && \
    rpmbuild -ta munge-$MUNGE_VERSION.tar.xz  && \
    dnf install -y --enablerepo=devel \
                   mariadb-devel \
                   pam-devel \
                   perl-ExtUtils-MakeMaker \
                   readline-devel && \
    dnf install -y $HOME/rpmbuild/RPMS/x86_64/munge*.rpm && \
    curl -LO https://download.schedmd.com/slurm/slurm-$SLURM_VERSION.tar.bz2 && \
    rpmbuild -ta slurm-$SLURM_VERSION.tar.bz2
