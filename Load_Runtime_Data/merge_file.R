#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Filename: merge_file.R
#
# Description: merge files from attr_902,attr_903 and attr_999 to build a multi-attrid data.frame and make sure data of one svrid is only in one data.frame
#
# Copyright (c) 2017, Yusheng Yi <yiyusheng.hust@gmail.com>
#
# Version 1.0
#
# Initial created: 2017-04-07 10:47:10
#
# Last   modified: 2017-04-07 10:47:11
#
#
#
rm(list = ls());setwd('~/Code/R/dataLoadforDiskAnalysis/');source('~/rhead')

merge_file <- function(i){
  s <- suffix[i]
  cur_fn <- paste(base_aid,'_',s,'.Rda',sep='')
  x <- ifelse(s == 'NA',s1 <- 120,s1 <- s)
  save_fn <- file.path(dir_mg,paste('io_',s1,'.Rda',sep=''))
  if(file.exists(save_fn))return(0)
  
  cat(sprintf('[%s]ID %s START!!!\n',date(),i))
  for(i in 1:length(cur_fn)){
    p <- cur_fn[i]
    if(file.exists(p)){
      load(p)
    }else{
      tmp <- data.frame(date = 0,svrid = '0',attrid = 0, timestamp = 0, value = 0)
      eval(parse(text = sprintf('data%s <- tmp',merge_aid[i])))
    }
  }
  col_need <- c('svrid','date','timestamp','value')
  data902 <- as.data.frame(data902);data903 <- as.data.frame(data903);data999 <- as.data.frame(data999)
  DT <- merge(data902[,col_need],data903[,col_need],
              by = c('svrid','date','timestamp'),all = T)
  cat(sprintf('[%s]ID %s MERGE 1!!!\n',date(),i))
  DT <- merge(DT,data999[,col_need],
              by = c('svrid','date','timestamp'),all = T)
  cat(sprintf('[%s]ID %s MERGE 2!!!\n',date(),i))
  
  names(DT) <- c('svrid','date','timestamp','rps','wps','util')
  DT$time <- as.POSIXct(as.character(DT$date),format = '%Y%m%d',tz = 'UTC') + DT$timestamp*300
  DT <- DT[,c('svrid','time','rps','wps','util')]
  DT <- subset(DT,svrid != '0')
  DT$svrid <- factor(DT$svrid)
  
  save(DT,file = save_fn)
  cat(sprintf('[%s]ID %s END!!!\n',date(),i))
  
  return(nrow(DT))
}

###### MAIN ######
dir_pd <- file.path(dir_data,'partition_dir')
dir_mg <- file.path(dir_pd,'pdMerge');if(!dir.exists(dir_mg))dir.create(dir_mg)
merge_aid <- c(902,903,999)

dir_aid <- file.path(dir_pd,paste('pd',merge_aid,sep=''))
base_aid <- file.path(dir_aid,paste('attr_',merge_aid,sep=''))
suffix <- c(as.character(1:119),NA)
idx <- seq_len(length(suffix))

r <- foreachX(idx,'merge_file')
