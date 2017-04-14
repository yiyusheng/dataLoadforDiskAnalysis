#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Filename: partition_fc_data.R
#
# Description: fei cheng's data is large for parallel processing. 
# It contains 5000 servers in one file. I divide each file into five files with only 1000 servers to relieve pressure of memory.
#
# Copyright (c) 2017, Yusheng Yi <yiyusheng.hust@gmail.com>
#
# Version 1.0
#
# Initial created: 2017-04-12 20:32:30
#
# Last   modified: 2017-04-12 20:32:33
#
#
#
rm(list = ls());setwd('~/Code/R/Load_Data_2014/Load_Runtime_Data/');source('~/rhead')

partition_fc_data <- function(i){
  fn <- fname[i]
  cat(sprintf('[%s]\t%s SATRT!!!\n',date(),fn))
  
  id <- as.numeric(gsub('data|\\.Rda','',fn))
  id <- 5*(id-1)
  load(file.path(sDir,fn))
  names(data) <- c('svrid','time','timepoint',attrName)
  DT <- data
  
  sid <- data.frame(sid = sort(levels(DT$svrid)))
  sid$id <- seq_len(nrow(sid))
  sid$id1 <- ceiling(sid$id/1000)
  splitSID <- split(sid,sid$id1)
  
  lapply(splitSID,function(idx){
    data <- subset(DT,svrid %in% idx$sid)
    fn1 <- paste('data',id+idx$id1[1],'.Rda',sep='')
    
    save(data,file = file.path(tDir,fn1))
  })
}

###### MAIN ######
attrName <- attrNameDis
sDir <- dir_data14
tDir <- dir_data14D
if(!dir.exists(tDir))dir.create(tDir)
fname <- list.files(sDir)
idx <- seq_len(length(fname))
r <- foreachX(idx,'partition_fc_data')