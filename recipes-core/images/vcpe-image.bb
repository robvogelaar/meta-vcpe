SUMMARY = "vcpe image"
DESCRIPTION = "Custom image based on core-image-minimal"

require recipes-core/images/core-image-minimal.bb

IMAGE_INSTALL:append = " \
    init-ifupdown \
    procps \
    bash \
    packagegroup-core-ssh-openssh \
    lsof \
    strace \
    \
    rbus \
    usp-pa \
"

# Add extra image features if needed
EXTRA_IMAGE_FEATURES += " \
    debug-tweaks \
    package-management \
"
