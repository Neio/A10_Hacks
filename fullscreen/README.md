Fullscreen in Android ICS (4.0.4)

===============================

##Fullscreen:

**busybox killall com.android.systemui**
**service call activity 79 s16 com.android.systemui**

First line kill systemui.
second line prevent systemui from restarting.


##Exit fullscreen:

**LD_LIBRARY_PATH=/vendor/lib:/system/lib am startservice -n com.android.systemui/.SystemUIService**

Restart systemui service
