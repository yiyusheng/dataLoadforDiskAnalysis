#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Filename: template.R
#
# Description: 
#
# Copyright (c) 2015, Yusheng Yi <yiyusheng.hust@gmail.com>
#
# Version 1.0
#
# Initial created: 2015-11-27 09:32:57
#
# Last   modified: 2015-12-22 08:46:32
#
#
#
rm(list = ls())
dir_Ldata <- '/home/yiyusheng/Data/RunTimeData/'
attrid <- c(9,26,40,41,50,51,902,903,905,907,927,928,929,930,999)
part <- 'part-00000'
for (id in attrid){
    eval(parse(text = sprintf("system('head -n 1000000 %sattr%i/%s > %sattr%i/part-00000A')",dir_Ldata,id,part,dir_Ldata,id)))
}
