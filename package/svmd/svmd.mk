################################################################################
#
# svmd
#
################################################################################

SVMD_VERSION = 0.1.0

# builds from the manager workspace so svm-client and Cargo.lock come along
SVMD_SITE = $(BR2_EXTERNAL_SOSE_PATH)/../manager
SVMD_SITE_METHOD = local
SVMD_SUBDIR = svmd
SVMD_OVERRIDE_SRCDIR_RSYNC_EXCLUSIONS = --exclude target
SVMD_LICENSE = GPL-2.0-only
SVMD_LICENSE_FILES = LICENSE

$(eval $(cargo-package))
