################################################################################
#
# svm
#
################################################################################

SVM_VERSION = 0.1.0

# builds from the manager workspace so svm-client and Cargo.lock come along
SVM_SITE = $(BR2_EXTERNAL_SOSE_PATH)/../manager
SVM_SITE_METHOD = local
SVM_SUBDIR = tools/svm
SVM_OVERRIDE_SRCDIR_RSYNC_EXCLUSIONS = --exclude target
SVM_LICENSE = GPL-2.0-only
SVM_LICENSE_FILES = LICENSE

$(eval $(cargo-package))
