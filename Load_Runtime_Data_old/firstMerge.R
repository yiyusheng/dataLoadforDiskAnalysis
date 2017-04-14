#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Filename: firstMerge.R
#
# Description: 
#
# Copyright (c) 2015, Yusheng Yi <yiyusheng.hust@gmail.com>
#
# Version 1.0
#
# Initial created: 2015-11-27 09:32:57
#
# Last   modified: 2015-12-21 15:52:10
#
#
#
rm(list = ls())
dir_code <- '/home/yiyusheng/Code/R'
dir_Ldata <- '/home/yiyusheng/Data/RunTimeData/'
dir_Rdata <- '/home/yiyusheng/Data/attrid/attr_part/attr_'
attrid <- c(9,26,40,41,50,51,902,903,905,907,927,928,929,930,999)
for (id in attrid){
   # eval(parse(text = sprintf("dir_data%s <- paste(dir_data,'attr_%s',sep = '')",id,id)))
    eval(parse(text = sprintf("dir_Ldata%s <- paste(dir_Ldata,'attr%s',sep = '')",id,id)))
}
dir_dataout <- '/home/yiyusheng/Data/RunTimeData/Merge'
source(file.path(dir_code,'Rfun.R'))

remote <- 'yiyusheng@202.114.10.171'
fname <- paste('part-000',sprintf('%02i',seq(0,25)),sep = '')
#fname <- list.files(dir_Ldata902)
#fname <- fname[-length(fname)]

FunRead <- function(id){
    eval(parse(text = sprintf("data%s <- read.csv(file = file.path(dir_Ldata%s,fname[i]),header = F)",id,id)))
    eval(parse(text = sprintf("names(data%s) <- c('time','svrid','attr','timepoint','v%s')",id,id)))
    eval(parse(text = sprintf("data%s$attr <- NULL",id)))
    eval(parse(text = sprintf("data%s",id)))
}

for (i in seq(1,1)){
    print(i)
    dataList <- foreach(id = attrid) %dopar% FunRead(id)
    for (id in attrid){
        #eval(parse(text = sprintf("system('scp %s:%s%s/%s %s')",remote,dir_remotedata,id,fname[i],dir_data)))
        #eval(parse(text = sprintf("data%s <- read.csv(file = file.path(dir_Ldata%s,fname[i]),header = F)",id,id)))
        #eval(parse(text = sprintf("names(data%s) <- c('time','svrid','attr','timepoint','v%s')",id,id)))
        #eval(parse(text = sprintf("data%s$attr <- NULL",id)))

        if (id == attrid[1]){
            next
        }else if (id == attrid[2]){
            eval(parse(text = sprintf("data <- merge(data%s,data%s,by = c('svrid','time','timepoint'), all = True)",attr[1],attr[2])))
        }else{
            eval(parse(text = sprintf("data <- merge(data,data%s,by = c('svrid','time','timepoint'),all = T)",id)))
        }
    }
    eval(parse(text = sprintf("save(data,file = file.path(dir_dataout,'data%i.Rda'))",i)))
}
