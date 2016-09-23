#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Filename: ioFetureLoad.R
#
# Description: IO feature
#
# Copyright (c) 2016, Yusheng Yi <yiyusheng.hust@gmail.com>
#
# Version 1.0
#
# Initial created: 2016-09-20 09:58:59
#
# Last   modified: 2016-09-20 09:59:03
rm(list = ls())
source('head.R')
####################################
# S1. 硬盘用量与强度: 求每台机器902.mean,903.mean,999.mean的均值,均值/使用时间百分比得强度.
load(file = file.path(dir_data,'attr.Rda')) # I have not generate this Rda file in this process

tmp.902 <- k131_902
tmp.903 <- k131_903
tmp.999 <- k131_999

tmp1 <- data.frame(svrid = levels(tmp.902$svrid),
                   mean = as.numeric(tapply(tmp.902$mean,tmp.902$svrid,mean)))
tmp2 <- data.frame(svrid = levels(tmp.903$svrid),
                   mean = as.numeric(tapply(tmp.903$mean,tmp.903$svrid,mean)))
tmp3 <- data.frame(svrid = levels(tmp.999$svrid),
                   mean = as.numeric(tapply(tmp.999$mean,tmp.999$svrid,mean)))

mean_io <- tmp1
mean_io$mean_903 <- tmp2$mean[match(mean_io$svrid,tmp2$svrid)]
mean_io$mean_999 <- tmp3$mean[match(mean_io$svrid,tmp3$svrid)]
mean_io <- subset(mean_io,svrid %in% tmp.999$svrid)
names(mean_io) <- c('svrid','mean_902','mean_903','mean_999')

save(mean_io,file = file.path(dir_data,'mean_io.Rda'))