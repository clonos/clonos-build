--- mybee-qt.pro.orig	2024-07-27 11:32:42 UTC
+++ mybee-qt.pro
@@ -1,10 +1,6 @@ TEMPLATE = subdirs
 TEMPLATE = subdirs
-SUBDIRS = libssh freerdp2 vnc src
+SUBDIRS = src
 CONFIG += c++17 release
-
-src.freerdp2 = libssh
-src.vnc = libssh
-src.depends = libssh freerdp2 vnc
 
 DISTFILES += \
     APP_VERSION \
