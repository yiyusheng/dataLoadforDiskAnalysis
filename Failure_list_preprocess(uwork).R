# failure list duplication, statistic failure times, extract first failure time
rm(list = ls())
source('head.R')

####################################
# 1. read data
data.flA <- read.csv(file.path(dir_data,'uwork_20120101-20131210.csv'))
data.flB <- read.csv(file.path(dir_data,'故障单精简_06-09.csv'))
data.flC <- read.csv(file.path(dir_data,'d_alarm_34_140701_141130.txt'),header = F,sep = '\t')

names(data.flA) <- c('id','svr_id','ip','ftype','ori_ftype',
                    'f_time','ftype_d1','ftype_d2','ftype_d')
names(data.flB) <- c('id','svr_id','ip','ftype',
                     'idc','dev_class_name','dev_class_id','dept_id',
                     'f_time','f_desc','ftype_d1','ftype_d2')
# names(data.flC) <- c('id','ip','fid','failureInfo','f_time','recov_time')

col_need <- c('svr_id','ip','ftype','f_time','ftype_d1','ftype_d2')
data.flA <- data.flA[,col_need]
data.flB <- data.flB[,col_need]
data.flA$group <- 'uworkA'
data.flB$group <- 'uworkB'

data.fl <- rbind(data.flA,data.flB)
data.fl$f_time <- as.POSIXct(data.fl$f_time,tz = 'UTC')

# 2. del space
data.fl$ftype <- as.character(data.fl$ftype)
data.fl$ftype[data.fl$ftype == '硬盘故障（有冗余） '] <- '硬盘故障（有冗余）'
data.fl$ftype <- factor(data.fl$ftype)

# 3. add class
data.fl$class <- -1
ftlist <- c('硬盘故障（有冗余）','硬盘故障（有冗余，槽位未知）',
            '硬盘故障（无冗余）','硬盘故障（无冗余，在线换盘）',
            '硬盘即将故障（有冗余）','操作系统硬盘故障（无冗余）')
data.fl$class[(data.fl$ftype_d1 == '硬盘故障;' | data.fl$ftype_d2 == '硬盘故障;')] <- 7


# 4. delete item without ip
data.fl_order <- data.fl[with(data.fl,order(ip,f_time)),]
data.fl_order <- data.fl_order[data.fl_order$ip!='',]           # delete item without ip
data.fl_order$ip <- factor(data.fl_order$ip)                    # reconstruct factor of ip

# 5. filter wrong ip
regexp.ip <- "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$"
idx.ip_reg <- grepl(regexp.ip,data.fl_order$ip)
data.fl_order <- data.fl_order[idx.ip_reg,]

# 6. save
data.flist <- data.fl_order
rownames(data.flist) <- NULL
data.bad <- subset(data.flist,class!=-1)
save(data.flist,data.bad,file = file.path(dir_data,'flist(uwork[2012-2014]).Rda'))