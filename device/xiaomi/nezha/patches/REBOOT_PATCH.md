TWRP 16 Reboot Patch — Xiaomi 17 Ultra (nezha)
=================================================

## Patch 1: Clear BCB before any reboot

File: bootable/recovery/twrp-functions.cpp

Before:
```
	}

	switch (command) {
```

After:
```
	}

	// Clear BCB before any reboot to prevent bootloop back to recovery
	Clear_Bootloader_Message();

	switch (command) {
```

## Patch 2: "Reboot to fastboot" → real bootloader fastboot

File: bootable/recovery/twrp-functions.cpp

On this device, `reboot,fastboot` enters fastbootd (recovery-based fastboot),
not bootloader fastboot. The "reboot to fastboot" button should use bootloader.

Before:
```
	case rb_fastboot:
		return property_set(ANDROID_RB_PROPERTY, "reboot,fastboot");
```

After:
```
	case rb_fastboot:
		Clear_Bootloader_Message();
		return property_set(ANDROID_RB_PROPERTY, "reboot,bootloader");
```

Apply with:
```
python3 device/xiaomi/nezha/patches/reboot_patch.py
```
