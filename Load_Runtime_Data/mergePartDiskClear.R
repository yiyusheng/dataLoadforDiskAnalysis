#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Filename: mergePartDiskClear.R
#
# Description: clear data in mergepartDiskdcast, merge iops of each disk to iopsw/r and generate xps = rps + wps and iops = iopsr + iopsw
# Rules of removing item:
# a. any lines with rps/wps larger than 1e6 or iopsr/iopsw(sum of iopsr_i) larger than 1e6 or util > 110
# 1. any lines with only NA and zero indicating no valid data in this line.
# 2. any svrid with 0 wps indicating a error recording(use sta_dcastClear_result.Rda)
# 3. set iopsr/iopsw/iops of a svrid to zero when any iopsw of this svrid is zero(use sta_dcastClear_result.Rda)
# 4. set util of lines to NA when xps of there lines are larger than 100.
############################## NOTE ############################## 
# it is a copy from  ~/Code/R/tencProcess/Load_Partition/mergePartDiskClear.R in order to clear IO data collected in 2014
############################## NOTE ############################## 
#
# Copyright (c) 2017, Yusheng Yi <yiyusheng.hust@gmail.com>
#
# Version 1.0
#
# Initial created: 2017-03-15 17:10:01
#
# Last   modified: 2017-03-15 17:10:03
#
#
#

rm(list = ls());setwd('~/Code/R/Load_Data_2014/Load_Runtime_Data/');source('~/rhead')

filter_invalid <- function(DT,fn,attrName){
  
  # R1. remove line with any value equals to NA
  NA_check <- rowSums(is.na(DT[,attrName]))
  idx_NA <- which(NA_check > 0)
  cat(sprintf('REMOVE %d[%.8f] lines is remove when doing NA_check\tfile:%s\n',length(idx_NA),length(idx_NA)/length(NA_check),fn))
  if(length(idx_NA) != 0)DT <- DT[-idx_NA,]
  
  # R2. Radical Filter: remove all anomaly line
  invalid_check <- DT$rps > 1e6 | DT$wps > 1e6 | DT$util > 110| DT$rps < 0 | DT$wps < 0 | DT$util < 0 #a
  idx_invalid <- which(invalid_check > 0)
  cat(sprintf('REMOVE %d[%.8f] lines is removed when doing invalid_check\tfile:%s\n',length(idx_invalid),length(idx_invalid)/length(invalid_check),fn))
  if(length(idx_invalid) != 0)DT <- DT[-idx_invalid,]
  DT$util[DT$util > 100] <- 100
  
  return(DT)
}

attr_clear <- function(DT,fn,attrName){
  
  # R1. invalid wps check: remove line which any wps equals to 0
  invalid_wps_check <- DT$wps == 0
  idx_iw <- which(invalid_wps_check > 0)
  if(length(idx_iw) != 0)DT <- DT[-idx_iw,]
  cat(sprintf('REMOVE %d[%.8f] lines is remove when doing invalid_wps_check\tfile:%s\n',length(idx_iw),length(idx_iw)/length(invalid_wps_check),fn))
  
  # R2. invalid relationship check: remove lines which util is equals to 0 but the xps is large than 300
  invalid_relationship_check <- DT$xps > 300 & DT$util == 0
  idx_irc <- which(invalid_relationship_check > 0)
  if(length(idx_irc) != 0)DT <- DT[-idx_irc,]
  cat(sprintf('REMOVE %d[%.8f] lines is remove when doing invalid_relationship_check\tfile:%s\n',length(idx_irc),length(idx_irc)/length(invalid_relationship_check),fn))
  
  DT
}

clear_dcast <- function(i){
  fn <- fname[i]
  cat(sprintf('[%s]\t%s SATRT!!!\n',date(),fn))
  load(file.path(sDir,fn))
  DT <- data
  # DT <- factorX(subset(DT,svrid %in% levels(DT$svrid)[1:10]))
  names(DT) <- c('svrid','time','timepoint',attrName)
  DT$time <- as.POSIXct(as.character(DT$time),format = '%Y%m%d',tz = 'UTC') + DT$timepoint*300
  DT <- DT[,c('svrid','time',attrName)]
  DT$xps <- DT$rps + DT$wps
  
  DT <- filter_invalid(DT,fn,attrName)
  DT <- attr_clear(DT,fn,attrName)
  
  DT <- factorX(DT[,c('svrid','time',attrName)])
  save(DT,file = file.path(tDir,fn))
  
  # if(fn == 'data26.Rda'){
  #   DT_ori <- DT
  #   len <- length(levels(DT_ori$svrid))
  #   sid100 <- levels(DT_ori$svrid)[1:(len-100)]
  #   sidrest <- setdiff(levels(DT_ori$svrid),sid100)
  #   
  #   DT <- factorX(subset(DT_ori,svrid %in% sid100,c('svrid','time',attrName)))
  #   save(DT,file = file.path(tDir,fn))
  #   
  #   DT <- factorX(subset(DT_ori,svrid %in% sidrest,c('svrid','time',attrName)))
  #   save(DT,file = file.path(tDir,'data27.Rda'))
  # }else{
  #   DT <- factorX(DT[,c('svrid','time',attrName)])
  #   save(DT,file = file.path(tDir,fn))
  # }
  cat(sprintf('[%s]\t%s END!!!\n',date(),fn))
  return(0)
}

###### MAIN ######
sDir <- dir_data14D
tDir <- dir_data14DC
attrName <- attrNameDis
if(!dir.exists(tDir))dir.create(tDir)
fname <- list.files(sDir)
#object.size(data);object.size(DT)
idx <- seq_len(length(fname))
r <- foreachX(idx,'clear_dcast')

