# xen tools: don't build xen's own qemu, takes forever and dom0 doesn't need it
XEN_CONF_OPTS += --with-system-qemu

include $(sort $(wildcard $(BR2_EXTERNAL_SOSE_PATH)/package/*/*.mk))
