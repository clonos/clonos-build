#!/bin/sh

su -l git -c "git config --global core.autocrlf input"
su -l git -c "git config --global gc.auto 0"
su -l git -c "git config --global repack.writeBitmaps true"
su -l git -c "git config --global receive.advertisePushOptions true"
su -l git -c "git config --global core.fsyncObjectFiles true"
