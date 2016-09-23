#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Filename: na.R
#
# Description: 
#
# Copyright (c) 2016, Yusheng Yi <yiyusheng.hust@gmail.com>
#
# Version 1.0
#
# Initial created: 2016-09-20 10:09:33
#
# Last   modified: 2016-09-20 10:09:43

# load(file.path(dir_data,'mcf_all_age_rsv2014.Rda')) # I have not generate this Rda file in this process
# data.config$bs1 <- cmdb_dev$bs1[match(data.config$ip,cmdb_dev$ip)]
# data.config <- subset(data.config,use_time > as.POSIXct('2010-01-01'))
# data.config$dev_class_id <- factor(data.config$dev_class_id)

# k131 <- subset(cmdb,svr_asset_id %in% k131_902$svrid)
# mean_io$use_perc <- 100 - use_999$use_perc[match(use_999$svrid,mean_io$svrid)]
# mean_io$class <- 'Normal'
# mean_io$class[mean_io$svrid %in% data.f$svr_id] <- 'Failure'
# mean_io$size <- 1
# mean_io$size[mean_io$class == 'Failure'] <- 10

# data.f: 201406-201408 for failed disks of C and TS servers 
# data.f <- subset(data.flist,f_time > as.POSIXct('2014/06/01') & 
#                    f_time < as.POSIXct('2014/08/01') &
#                    dev_class_id %in% c('C1','TS1','TS3','TS4','TS5','TS6'))

# data.fAllDev: 201406-201408 for all failed disks
# data.fAllDev <- subset(data.flist,f_time > as.POSIXct('2014/06/01') & f_time < as.POSIXct('2014/08/01'))

# data.fMore: 201301- for all failed disks
# data.fMore <- subset(data.flist,f_time > as.POSIXct('2013/01/01') & f_time < as.POSIXct('2014/08/01'))

# L4. 处理disk_ip,生成sata2/sata3数量及有model数小于3时的model及数量，model已排序。
# disk_ip$SATA2 <- 0
# disk_ip$SATA3 <- 0
# disk_ip$modelA <- ''
# disk_ip$modelB <- ''
# disk_ip$modelAC <- 0
# disk_ip$modelBC <- 0
# cur_inter <- strsplit(as.character(disk_ip$disk_inter),'_')
# cur_num <- strsplit(as.character(disk_ip$disk_model_c),'_')
# cur_model <- strsplit(as.character(disk_ip$disk_model),'_')
# 
# for (i in seq(1,nrow(disk_ip))){
#   print(i)
#   if (disk_ip$disk_model_c1[i] == 1){
#     disk_ip[[cur_inter[[i]]]][i] <- disk_ip$disk_c[i]
#     disk_ip$modelA[i] <- cur_model[[i]][1]
#     disk_ip$modelAC[i] <- disk_ip$disk_c[i]
#   }else{
#     for (j in seq(1,length(cur_num[[i]]))){
#       disk_ip[[cur_inter[[i]][j]]][i] <- disk_ip[[cur_inter[[i]][j]]][i] + as.numeric(cur_num[[i]][j])
#       if (disk_ip$disk_model_c1[i] == 2){
#         disk_ip$modelA[i] <- cur_model[[i]][1]
#         disk_ip$modelB[i] <- cur_model[[i]][2]
#         disk_ip$modelAC[i] <- cur_num[[i]][1]
#         disk_ip$modelBC[i] <- cur_num[[i]][2]
#       }
#     }
#   }
# }

# numModel = as.numeric(tapply(diskB$model,diskB$ip,function(x)length(unique(x[x != 'NOMODEL'])))),
# mainDisk = as.numeric(tapply(diskB$model,diskB$ip,
#                              function(x){tmp <- sort(table(x));names(tmp)[1]})))

# diskB <- merge(diskB,info.model[,1:2],by.x = 'model',by.y = 'Model_ori',all.x = T)
# diskB$Model_clear <- as.character(diskB$Model_clear)
# diskB$Model_clear[is.na(diskB$Model_clear)] <- 'NOMODEL'
# diskB$Model_clear <- factor(diskB$Model_clear)

# disk_model <- melt(table(diskB[,c('ip','model')]))
# disk_model <- subset(disk_model,value != 0)
# names(disk_model) <- c('ip','model','number')
# diskB$ipm <- paste(diskB$ip,diskB$model,sep='_')
# table.ipm <- table(diskB$ipm)
# disk_model <- strsplit(as.character(names(table.ipm)),'_')
# disk_model <- data.frame(t(sapply(disk_model,c)))
# disk_model$count <- as.numeric(table.ipm)
# names(disk_model) <- c('ip','model','number')

# 5. read model info
# disk_model$model_ori <- disk_model$model
# disk_model$model <- info.model$Model_clear[match(disk_model$model_ori,info.model$Model_ori)]
# disk_model$model <- as.character(disk_model$model)
# disk_model$model[!is.element(disk_model$model,info.model$Model_clear)] <- 'NOMODEL'
# disk_model$model <- as.factor(disk_model$model)

# 6. 给disk model添加容量,数量等信息
# model_info <- read.csv(file.path(dir_data,'num_model.csv'))
# model_info <- model_info[!duplicated(model_info$Model_clear),]
# disk_model <- subset(disk_model,model!='NOMODEL')
# disk_model <- merge(disk_model,model_info,by.x = 'model',by.y = 'Model_clear',all.x = T)
# disk_model$total <- disk_model$capacity*disk_model$number
# disk_model$Count <- NULL
# disk_model$Model_ori <- NULL
# disk_model$Discs <- disk_model$Discs*disk_model$number
# disk_model$Heads <- disk_model$Heads*disk_model$number

# 7. 为有disk model的ip建立的表
# disk_model$interface <- as.character(disk_model$interface)
# disk_model$interface[disk_model$interface == 'SATA 3Gb/s'] <- 'SATA2'
# disk_model$interface[disk_model$interface == 'SATA 6Gb/s'] <- 'SATA3'
# disk_ip <- data.frame(ip = levels(disk_model$ip),
#                       total = as.numeric(tapply(disk_model$total,disk_model$ip,sum)),
#                       disk_c = as.numeric(tapply(disk_model$number,disk_model$ip,sum)),
#                       disc_c = as.numeric(tapply(disk_model$Discs,disk_model$ip,sum)),
#                       head_c = as.numeric(tapply(disk_model$Heads,disk_model$ip,sum)),
#                       disk_model = factor(tapply(as.character(disk_model$model),disk_model$ip,
#                                                  function(x)paste(x,collapse='_'))),
#                       disk_cache = factor(tapply(as.character(disk_model$Cache.MB.), disk_model$ip,
#                                                  function(x)paste(x,collapse='_'))),
#                       disk_inter = factor(tapply(as.character(disk_model$interface),disk_model$ip,
#                                                  function(x)paste(x,collapse='_'))),
#                       disk_model_c = factor(tapply(disk_model$number,disk_model$ip,
#                                                    function(x)paste(x,collapse='_'))),
#                       disk_model_c1 = as.numeric(tapply(disk_model$number,disk_model$ip,length)))      
# disk_ip <- disk_ip[!is.na(disk_ip$total),]
# row.names(disk_ip) <- NULL