#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Filename: firstMergeTest.R
#
# Description: 
#
# Copyright (c) 2015, Yusheng Yi <yiyusheng.hust@gmail.com>
#
# Version 1.0
#
# Initial created: 2015-11-27 09:32:57
#
# Last   modified: 2015-12-22 20:13:08
#
#
#
rm(list = ls())
library('doParallel')
dir_code <- '/home/yiyusheng/Code/R'
dir_Ldata <- '/home/yiyusheng/Data/RunTimeData/'
dir_Rdata <- '/home/yiyusheng/Data/attrid/attr_part/attr_'
attrid <- c(9,26,40,41,50,51,902,903,905,907,927,928,929,930,999)
for (id in attrid){
    eval(parse(text = sprintf("dir_Ldata%s <- paste(dir_Ldata,'attr%s',sep = '')",id,id)))
}
dir_dataout <- '/home/yiyusheng/Data/RunTimeData/Merge'
source(file.path(dir_code,'Rfun.R'))
ck <- makeCluster(17, type = 'FORK')
registerDoParallel(ck)

remote <- 'yiyusheng@202.114.10.171'
fname <- paste('part-000',sprintf('%02i',seq(0,25)),'A',sep = '')

FunRead <- function(id,fn){
    eval(parse(text = sprintf("tmp <- read.csv(file = file.path(dir_Ldata%s,'%s'),header = F)",id,fn)))
    eval(parse(text = sprintf("names(tmp) <- c('time','svrid','attr','timepoint','v%s')",id)))
    tmp$time <- tmp$time + tmp$timepoint/288
    tmp$attr <- NULL
    tmp$timepoint <- NULL
    print(sprintf('Reading attr%s complete! %s',id,date()))
    eval(parse(text = sprintf("data%s <- tmp",id)))
}
FunMerge <- function(dataList,id){
    if (id + 1 <= length(dataList)){
        data <- merge(dataList[[id]],dataList[[id+1]],by = c('svrid','time'),all = TRUE)
    }else{
        data <- dataList[[id]]
    }
    print(sprintf('Merging id:%i complete! %s',id,date()))
    data
}
for(i in seq(1,1)){
    print(sprintf('Read file %s[%s]',fname[i],date()))
    dataList <- foreach(id = attrid) %dopar% FunRead(id,fname[i])

    print(sprintf('Iterate Round 1 %s[%s]',fname[i],date()))
    dataListA <- foreach(id = seq(1,15,2)) %dopar% FunMerge(dataList,id)
    rm(dataList)
    print(sprintf('Iterate Round 2 %s[%s]',fname[i],date()))
    dataList <- foreach(id = seq(1,7,2)) %dopar% FunMerge(dataListA,id)
    rm(dataListA)
    print(sprintf('Iterate Round 3 %s[%s]',fname[i],date()))
    dataListA <- foreach(id = seq(1,3,2)) %dopar% FunMerge(dataList,id)
    rm(dataList)
    print(sprintf('Iterate Round 4 %s[%s]',fname[i],date()))
    dataList <- foreach(id = seq(1,1,2)) %dopar% FunMerge(dataListA,id)
    rm(dataListA)
    data <- dataList[[1]]
    print(sprintf('Saving data [%s]',date()))
    eval(parse(text = sprintf("save(data,file = file.path(dir_dataout,'data%i.Rda'))",i)))
}

stopCluster(ck)
