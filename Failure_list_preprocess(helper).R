#@@@ Load data of failure records from helper recording system
rm(list = ls())
source('head.R')

# read data and save
# data <- rbind(read.csv(file.path(dir_data,'2009.csv')),
#               read.csv(file.path(dir_data,'2010.csv')),
#               read.csv(file.path(dir_data,'2011.csv')),
#               read.csv(file.path(dir_data,'2012.csv')),
#               read.csv(file.path(dir_data,'2013.csv')))
# save(data,file = file.path(dir_data,'helper[09-13].Rda'))
load(file.path(dir_data,'helper[09-13].Rda'))

# 1. extract some columns and filter replica list
col_need <- c('创建时间','故障原因','当前状态','故障发生部门','部门','服务恢复时间','结单时间',
              '解决方法','固资编号','故障机固资号','主机IP','告警级别','设备型号','设备类型',
              'SN','上架时间','服务恢复耗时.小时.','事件类型','硬盘故障类型','硬盘故障数量',
              '硬盘容量','硬盘生产厂商','硬盘品牌厂商','备机固资号')
data <- data[,col_need]
names(data) <- c('f_time','reason','state','fail_dept','dept','recover_time','close_time',
                 'solution','svr_id','svr_id_failure','ip','level','model_name','dev_class_id',
                 'SN','use_time','recover_interval','type','disk_failure_type','disk_failure_count',
                 'disk_capacity','disk_vendor','disk_band_vendor','svr_id_backup')
data <- subset(data,as.numeric(state) != 1 & as.numeric(state) != 4)

# 2.filter IP
data.filter <- data[with(data,order(ip,f_time)),]
# 2.1 replace wrong string
data.filter$ip <- gsub("无", "", data.filter$ip)
data.filter$ip <- gsub("\n", "", data.filter$ip)
# 2.2 delete item without ip
data.filter <- data.filter[data.filter$ip!='',] 
# 2.3 remove item with more than one ip
idx.ip_res <- nchar(as.character(data.filter$ip)) <= 15
data.filter <- data.filter[idx.ip_res,]
# 2.4 remove item with ip blocked by regexp
regexp.ip <- "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$"
idx.ip_reg <- grepl(regexp.ip,data.filter$ip)
data.filter <- data.filter[idx.ip_reg,]
data.filter <- factorX(data.filter)

# 3. 过滤f_time,use_time,close_time
data.filter$use_time <- gsub("无", "", data.filter$use_time)
data.filter$use_time <- gsub("\n", "", data.filter$use_time)
data.filter$use_time <- as.POSIXct(data.filter$use_time,tz = 'UTC')
data.filter$f_time <- as.POSIXct(data.filter$f_time,tz = 'UTC')

# 4.add class (-1 for non disk failure;13 for single disk failure and 14 for multiple disk failure)
data.filter$class <- -1
data.filter$class[as.character(data.filter$disk_failure_type) == '单硬盘故障'] <- 13
data.filter$class[as.character(data.filter$disk_failure_type) == '多硬盘故障'] <- 14

# 5.save
data.flist <- data.filter
data.bad <- subset(data.flist,class!=-1)
save(data.flist,data.bad,file = file.path(dir_data,'flist(helper[2008-2013]).Rda'))
