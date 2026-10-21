################################################################################
#
# svm-ls
#
################################################################################

SVM_LS_VERSION = 0.1.0

# builds from the manager workspace so the xenstore crate and Cargo.lock come along
SVM_LS_SITE = $(BR2_EXTERNAL_SOSE_PATH)/../manager
SVM_LS_SITE_METHOD = local
SVM_LS_SUBDIR = tools/svm-ls
SVM_LS_OVERRIDE_SRCDIR_RSYNC_EXCLUSIONS = --exclude target
SVM_LS_LICENSE = GPL-2.0-only
SVM_LS_LICENSE_FILES = LICENSE

$(eval $(cargo-package))
