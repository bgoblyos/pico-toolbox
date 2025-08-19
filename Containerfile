FROM docker.io/gentoo/stage3:20250818

# Sync repo
RUN emerge-webrsync --quiet

# Distrobox dependencies
RUN emerge -n --quiet-build \
	app-shells/bash \
	app-crypt/gnupg \
	app-shells/bash-completion \
	sys-apps/diffutils \
	sys-apps/findutils \
	sys-apps/less \
	sys-libs/ncurses \
	net-misc/curl \
	app-crypt/pinentry \
	sys-process/procps \
	sys-apps/shadow \
	app-admin/sudo \
	sys-devel/bc \
	sys-process/lsof \
	sys-apps/util-linux \
	net-misc/wget

# Enable ~amd64 on picotool
RUN echo "dev-embedded/picotool ~amd64" > /etc/portage/package.accept_keywords/picotool

# Set up repo for crossdev
RUN mkdir -p /var/db/repos/crossdev/{profiles,metadata} \
	&& echo 'crossdev' > /var/db/repos/crossdev/profiles/repo_name \
	&& echo 'masters = gentoo' > /var/db/repos/crossdev/metadata/layout.conf \
	&& chown -R portage:portage /var/db/repos/crossdev
COPY crossdev.conf /etc/portage/repos.conf/ 

# Install crossdev and debug utilities
RUN emerge -n --quiet-build \
	sys-devel/crossdev \
	dev-embedded/openocd \
	dev-embedded/picotool

# Set up ARM crossdev toolchain
RUN crossdev --target arm-none-eabi --ex-gdb

# Set up RISC-V crossdev toolchain
RUN crossdev --target riscv32-unknown-elf --ex-gdb
