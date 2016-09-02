# LOAD DATA
rm(list = ls())
source('head.R')

# L1. cmdb数据
load(file.path(dir_data,'disk_number_label.Rda'))
load(file.path(dir_data,'mcf_all_age_rsv2014.Rda')) # I have not generate this Rda file in this process
data.config$bs1 <- cmdb_dev$bs1[match(data.config$ip,cmdb_dev$ip)]
data.config <- subset(data.config,use_time > as.POSIXct('2010-01-01'))
data.config$dev_class_id <- factor(data.config$dev_class_id)

# L2. 提取故障数据,filter failed servers whose f_time less than use_time in cmdb
data.flist$dev_class_id <- cmdb$dev_class_id[match(data.flist$svr_id,cmdb$svr_asset_id)]
data.flist$use_time <- cmdb$use_time[match(data.flist$svr_id,cmdb$svr_asset_id)]
data.flist <- subset(data.flist,use_time < f_time)

# data.f: 201406-201408 for failed disks of C and TS servers 
data.f <- subset(data.flist,f_time > as.POSIXct('2014/06/01') & 
                   f_time < as.POSIXct('2014/08/01') &
                   dev_class_id %in% c('C1','TS1','TS3','TS4','TS5','TS6'))

# data.fAllDev: 201406-201408 for all failed disks
data.fAllDev <- subset(data.flist,f_time > as.POSIXct('2014/06/01') & f_time < as.POSIXct('2014/08/01'))

# data.fMore: 201301- for all failed disks
data.fMore <- subset(data.flist,f_time > as.POSIXct('2013/01/01') & f_time < as.POSIXct('2014/08/01'))

# L3. 硬盘用量与强度: 求每台机器902.mean,903.mean,999.mean的均值,均值/使用时间百分比得强度.
# load(file = file.path(dir_data,'attr.Rda')) # I have not generate this Rda file in this process
# k131 <- subset(cmdb,svr_asset_id %in% k131_902$svrid)
# tmp.902 <- k131_902
# tmp.903 <- k131_903
# tmp.999 <- k131_999
# tmp1 <- data.frame(svrid = levels(tmp.902$svrid),
#                    mean = as.numeric(tapply(tmp.902$mean,tmp.902$svrid,mean)))
# tmp2 <- data.frame(svrid = levels(tmp.903$svrid),
#                    mean = as.numeric(tapply(tmp.903$mean,tmp.903$svrid,mean)))
# tmp3 <- data.frame(svrid = levels(tmp.999$svrid),
#                    mean = as.numeric(tapply(tmp.999$mean,tmp.999$svrid,mean)))
# mean_io <- tmp1
# mean_io$mean_903 <- tmp2$mean[match(mean_io$svrid,tmp2$svrid)]
# mean_io$mean_999 <- tmp3$mean[match(mean_io$svrid,tmp3$svrid)]
# mean_io <- subset(mean_io,svrid %in% tmp.999$svrid)
# names(mean_io) <- c('svrid','mean_902','mean_903','mean_999')
# # mean_io$use_perc <- 100 - use_999$use_perc[match(use_999$svrid,mean_io$svrid)]
# mean_io$class <- 'Normal'
# mean_io$class[mean_io$svrid %in% data.f$svr_id] <- 'Failure'
# mean_io$size <- 1
# mean_io$size[mean_io$class == 'Failure'] <- 10
# save(mean_io,file = file.path(dir_data,'mean_io.Rda'))
load(file = file.path(dir_data,'mean_io.Rda')) # I have not generate this Rda file in this process

# L4. 处理disk_ip,生成sata2/sata3数量及有model数小于3时的model及数量，model已排序。
disk_ip$SATA2 <- 0
disk_ip$SATA3 <- 0
disk_ip$modelA <- ''
disk_ip$modelB <- ''
disk_ip$modelAC <- 0
disk_ip$modelBC <- 0
cur_inter <- strsplit(as.character(disk_ip$disk_inter),'_')
cur_num <- strsplit(as.character(disk_ip$disk_model_c),'_')
cur_model <- strsplit(as.character(disk_ip$disk_model),'_')

for (i in seq(1,nrow(disk_ip))){
  print(i)
  if (disk_ip$disk_model_c1[i] == 1){
    disk_ip[[cur_inter[[i]]]][i] <- disk_ip$disk_c[i]
    disk_ip$modelA[i] <- cur_model[[i]][1]
    disk_ip$modelAC[i] <- disk_ip$disk_c[i]
  }else{
    for (j in seq(1,length(cur_num[[i]]))){
      disk_ip[[cur_inter[[i]][j]]][i] <- disk_ip[[cur_inter[[i]][j]]][i] + as.numeric(cur_num[[i]][j])
      if (disk_ip$disk_model_c1[i] == 2){
        disk_ip$modelA[i] <- cur_model[[i]][1]
        disk_ip$modelB[i] <- cur_model[[i]][2]
        disk_ip$modelAC[i] <- cur_num[[i]][1]
        disk_ip$modelBC[i] <- cur_num[[i]][2]
      }
    }
  }
}

# L5. SAVE
save(mean_io,cmdb,data.f,data.fMore,data.fAllDev,disk_ip,file = file.path(dir_data,'load_ftr_attrid.Rda'))
