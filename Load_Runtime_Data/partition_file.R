#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Filename: partition_file.R
#
# Description: partition attr_902, attr_903 and attr_999 into small Rda files with id. 
# File with the same id contains the same svrid. We will merge Rda files with the same id together latter.
#
# Copyright (c) 2017, Yusheng Yi <yiyusheng.hust@gmail.com>
#
# Version 1.0
#
# Initial created: 2017-04-06 21:27:28
#
# Last   modified: 2017-04-06 21:27:45
#
#
#

rm(list = ls());setwd('~/Code/R/dataLoadforDiskAnalysis/');source('~/rhead')

read_split_file <- function(i){
  dt <- fread(file.path(dir_split,splitname[i]),header = F,showProgress = F)
  cat(sprintf('[%s]Read file %s Done!!!\n',date(),i))
  names(dt) <- c('date','svrid','attrid','timestamp','value')
  
  dt$id <- svrid_all$id[match(dt$svrid,svrid_all$svrid)]
  df.idx <- data.frame(idx = seq_len(nrow(dt)),id = dt$id)
  splitID <- split(df.idx,df.idx$id)
  r <- lapply(splitID,function(df)dt[df$idx,])
}

merge_save <- function(i,MSaid){
  tmp <- lapplyX(r1,'[[',i)
  eval(parse(text = sprintf('data%d <- tmp',MSaid)))
  eval(parse(text = sprintf('save(data%d,file = file.path(dir_pdattrid,"attr_%d_%d.Rda"))',MSaid,MSaid,i)))
  cat(sprintf('[%s]ID %d done!!!\n',date(),i))
  return(nrow(tmp))
}

###### MAIN ######
require(data.table)
load(file.path(dir_data,'partition_table.Rda'))
dir_pd <- file.path(dir_data,'partition_dir')
aid <- 999
fn <- paste('attr_',aid,sep='')
dir_pdattrid <- file.path(dir_pd,paste('pd',aid,sep=''))
if(!dir.exists(dir_pdattrid))dir.create(dir_pdattrid)
dir_split <- file.path(dir_pd,'split')
svrid_all$id <- factor(svrid_all$id)

splitname <- list.files(dir_split)
r1 <- foreachX(seq_len(length(splitname)),'read_split_file')
r2 <- foreachX(seq_len(length(partition_table)),'merge_save',MSaid = aid)
