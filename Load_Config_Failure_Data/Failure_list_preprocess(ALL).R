#@@@ 合并故障单,计算上架时间
rm(list = ls())
source('head.R')

# 1. 读取uwork数据
load(file.path(dir_data,'flist(uwork[2012-2014]).Rda'))
data.flist_uwork <- data.flist[,c('ip','svr_id','f_time','class','ftype','group')]

# 2. 读取helper数据
load(file.path(dir_data,'flist(helper[2008-2013]).Rda'))
data.flist_helper <- data.flist[,c('ip','svr_id','f_time','class','ftype','group')]

# 3. 合并数据. We use class == -1 to determine read failure
data.flist <- rbind(data.flist_helper,data.flist_uwork)
data.flist$group <- factor(data.flist$group)
data.flist <- factorX(data.flist)

# 4. ip检验
# regexp.ip <- "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$"
# sum(grep(regexp.ip,data.flist$ip,value = T) == as.character(data.flist$ip)) == nrow(data.flist)

# 5. 去重(3天的去重时间)
dayDup <- 3
data.pretFlist <- subset(data.flist,class == -1)
data.flist <- subset(data.flist,class != -1)
data.flist <- dedupTime(data.flist,dayDup,'svr_id')
# data.pretFlist <- dedupTime(data.pretFlist,dayDup,'svr_id')

# 6.存储
save(data.flist,data.pretFlist,file = file.path(dir_data,'flist.Rda'))