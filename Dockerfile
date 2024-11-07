ARG ROCKY_VERSION=9
FROM rockylinux/rockylinux:${ROCKY_VERSION}

WORKDIR /build
COPY rocm.repo /etc/yum.repos.d/rocm.repo
COPY rpmmacros /root/.rpmmacros

ARG SLURM_VERSION=24.05.4

RUN dnf install -y \
        --enablerepo=devel \
        --enablerepo=crb \
        @Development\ Tools \
        bzip2-devel \
        openssl-devel \
        hwloc-devel \
        numactl-devel \
        pmix-devel \
        procps \
        rpm-build \
        systemd \
        systemd-rpm-macros \
        rocm-smi-lib \
        munge-libs \
        munge-devel \
        mariadb-devel \
        pam-devel \
        perl-ExtUtils-MakeMaker \
        readline-devel && \
    curl -LO https://download.schedmd.com/slurm/slurm-$SLURM_VERSION.tar.bz2 && \
    rpmbuild -ta slurm-$SLURM_VERSION.tar.bz2
