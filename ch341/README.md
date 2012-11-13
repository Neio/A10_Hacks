ch341
==================


CH341 USB-Serial Module for Android

Compile CH341.ko from linux source: **https://github.com/linux-sunxi/linux-sunxi**


=============================
總結經驗：

1. 最好使用 Ubuntu 來編譯內核，避免一些工具的缺失，以及文件系統的大小寫不敏感導致文件缺失無法編譯。
這點非常重要，避免走彎路。

2. 一些常用的命令：

dmesg 查看Message
modinfo 查看 .ko 的文件信息，特別是vermagic信息。
lsmod 可以查看當前運行的組件。
insmod xxx.ko 註冊模塊，如果註冊失敗，運行dmesg 查看系統消息。

3. 內核版本檢查機制

3.1 vermagic 的問題

version magic 用來匹配模塊和內核，如果不相同，則無法導入模塊。出現無法導入的情況，查看 dmesg, 可以看到提示 version magic 'xxxxx' should be 'xxxx'。根據提示的情況去做相應的修改配置，或者修改vermagic.h，再重新編譯。

有兩個原則，所編譯的模塊最好和目標內核一致，避免出現問題。如果僅僅是文字上有區別，可以修改：
include/linux/vermagic.h

3.2 disagree about version of symbol module_layout 的問題

這個是由於 module_layout 導出符號的版本信息和當前內核不符出現的錯誤。在配置中關閉 CONFIG_MODVERSIONS.


4. 在清華紫光和U18GT上的配置：
 SLUB/SLAB, (U18GT 使用SLAB， 清華紫光使用 SLUB)* 
 //// 關PREEMPT (可以開） 
 關DEBUG_SLAB 
 關DEBUG_PREEMPT ** 
 關CONFIG_MODVERSIONS (紫光的Pad需要修改vermagic.h，修改 MODULE_VERMAGIC_MODVERSIONS 後的""為"modversions "） 
*區分SLUB, SLAB 的關鍵點是，insmod 的時候，錯誤提示中，如果說 Unknown symbol malloc_sizes, 就是 SLAB在目標Linux kernel 中不支持。

** insmod 的時候，出現錯誤提示說: add_preempt_xxx 的錯誤，說明目標內核不支持 


5. 把驅動獨立出來作為模塊編譯的方法，以CH341驅動為例子：

把 ch341.c 從 drivers/usb/serial/ 中復制到 /modules/serial中。
創建Makefile文件，內容填寫：

#########文件內容###############
# LICHEE_KDIR,           #
# LICHEE_MOD_DIR,   #目標文件夾
# CROSS_COMPILE,   #eg. arm-linux-gnueabi-
# ARCH                         #eg. arm
# 需要已經定義, 參考 build_xxxx.sh
####################
PWD=$(shell pwd)

obj-m+=ch341.o 
#這句話告訴編譯器編譯ch341.ko

install: build

build:
     @echo $(LICHEE_KDIR)
     $(MAKE) -C $(LICHEE_KDIR) M=$(PWD)

clean:
     @rm -rf *.o *.ko *.mod.c *.symvers *~ *.order 

########################################

修改 build_xxx.sh, 
在 build_modules() 函數中，update_kern_ver 的後面，添加

make -C modules/serial LICHEE_MOD_DIR=$(LICHEE_MOD_DIR) LICHEE_KDIR=$(LICHEE_KDIR) \
         CONFIG_CHIP_ID=${CONFIG_CHIP_ID} install

編譯後，達到 ch341.ko，傳輸到Android中，運行 insmod ch341.ko，如果沒有錯誤提示，恭喜你成功了。

如果遇到錯誤提示，大致分為三種：

1. disagree about version of symbol module_layout 
2. Bad Format / Error (dmesg 中說 version magic 'xxxxx' should be 'xxxx'）
3. Unknown symbol xxxx

處理的方式前面已經闡述，需要說明的是第三種情況，因為內核中沒有相應的函數，可以搜索一下這個關鍵詞，關掉相應的配置在編譯一邊，一直到沒有錯誤為止。





