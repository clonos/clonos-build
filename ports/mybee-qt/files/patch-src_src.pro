--- src/src.pro.orig	2024-07-27 11:32:42 UTC
+++ src/src.pro
@@ -26,9 +26,9 @@ android {
     LIBS += -L$${PWD}/android/openssl/lib -lcrypto_1_1 -lssl_1_1 $${PWD}/android/libssh2/lib/libssh2.a
     ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
 } else {
-    INCLUDEPATH += \"$${OUT_PWD}/../include\" \"$${OUT_PWD}/../include/freerdp2\" \"$${OUT_PWD}/../include/winpr2\"
+    INCLUDEPATH += \"/usr/local/include/freerdp2\" \"/usr/local/include/winpr2\" \"$${OUT_PWD}/../include\" \"$${OUT_PWD}/../include/freerdp2\" \"$${OUT_PWD}/../include/winpr2\"
     LIBS += -L../lib -lssh -lvncclient
-    LIBS += -lfreerdp-client2 ../lib/freerdp2/*.$${QMAKE_EXTENSION_STATICLIB} -lfreerdp2 -lwinpr2
+    LIBS += -lfreerdp-client2 -lfreerdp2 -lwinpr2
     LIBS += -lcrypto -lssl -lcairo -ljpeg -lpng -llzo2 -lz
     #LIBS += $${QMAKE_LIBS_X11} -lxkbfile
     *bsd: LIBS += -lutil
