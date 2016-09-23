# LOAD DATA
rm(list = ls())
source('head.R')

# L1. Failure record: filter failed servers whose f_time is younger than use_time in cmdb
load(file.path(dir_data,'flist.Rda'))
load(file.path(dir_data,'serverInfo.Rda'))
data.flist$dev_class_id <- cmdb$dev_class_id[match(data.flist$svr_id,cmdb$svr_asset_id)]
data.flist$use_time <- cmdb$use_time[match(data.flist$svr_id,cmdb$svr_asset_id)]

data.flist <- subset(data.flist,use_time < f_time & svr_id %in% cmdb$svr_asset_id)
data.flist$ip <- factor(data.flist$ip)
data.flist$svr_id <- factor(data.flist$svr_id)
data.flist <- factorX(data.flist)

# L2. IO: Add id and filter io information who is not in cmdb
load(file = file.path(dir_data,'mean_io.Rda')) 
mean_io$ip <- cmdb$ip[match(mean_io$svrid,cmdb$svr_asset_id)]
mean_io <- factorX(subset(mean_io,svrid %in% cmdb$svr_asset_id))

# L3. DiskInfo: Add svr_id 
load(file.path(dir_data,'disk_two_lists.Rda'))
disk_ip$svr_id <- cmdb$svr_asset_id[match(disk_ip$ip,cmdb$ip)]
disk_ip <- factorX(subset(disk_ip,svr_id %in% cmdb$svr_asset_id))

# L2. SAVE(IO,cmdb,failure record,diskInfo)
save(mean_io,cmdb,data.flist,disk_ip,file = file.path(dir_data,'load_ftr_attrid.Rda'))
# save(mean_io,cmdb,data.f,data.fMore,data.fAllDev,disk_ip,file = file.path(dir_data,'load_ftr_attrid.Rda'))

