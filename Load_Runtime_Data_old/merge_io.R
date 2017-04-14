#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Filename: merge_io.R
#
# Description: merge 999,999 and 999
#
# Copyright (c) 2015, Yusheng Yi <yiyusheng.hust@gmail.com>
#
# Version 1.0
#
# Initial created: 2015-11-26 16:57:46
#
# Last   modified: 2015-11-26 17:20:48
#
#
#
rm(list = ls())
source('/home/yiyusheng/Code/R/Rfun.R')
dir_data <- '/home/yiyusheng/Data/allIO'

fname <- list.files(dir_data)
fname.999 <- fname[grepl(999,fname)]
io999 <- data.frame()

for(f in fname.999){
  load(file.path(dir_data,f))
  vname <- gsub('io_','',gsub('.Rda','',f))
  eval(parse(text = sprintf('tmp <- %s',vname)))
  io999 <- rbind(io999,tmp)
  sprintf('File:%s  length:%i',f,nrow(tmp))
  rm(tmp)
  eval(parse(text = sprintf('rm(%s)',vname)))
}
save(io999,file = file.path(dir_data,'merge_999.Rda',sep='')))
