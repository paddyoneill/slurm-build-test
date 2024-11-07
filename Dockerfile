ARG ROCKY_VERSION=9
FROM rockylinux/rockylinux:${ROCKY_VERSION}

WORKDIR /build
COPY rocm.repo /etc/yum.repos.d/rocm.repo

ARG SLURM_VERSION=24.05.4

RUN dnf install -y \
        --enablerepo=devel \
        --enablerepo=crb \
        @Development\ Tools \
        bzip2-devel \
        http-parser-devel \
        hwloc-devel \
        json-c-devel \
        libyaml-devel \
        lua-devel \
        mariadb-devel \
        munge-devel \
        munge-libs \
        numactl-devel \
        openssl-devel \
        pam-devel \
        perl-ExtUtils-MakeMaker \
        pmix-devel \
        procps \
        readline-devel \
        rocm-smi-lib \
        rpm-build \
        systemd \
        systemd-rpm-macros && \
    curl -LO https://download.schedmd.com/slurm/slurm-$SLURM_VERSION.tar.bz2 && \
    rpmbuild -ta slurm-$SLURM_VERSION.tar.bz2 \
        --with mysql \
        --with hwloc \
        --with numa \
        --with pmix \
        --with slurmrestd \
        --with lua \
        --with yaml
