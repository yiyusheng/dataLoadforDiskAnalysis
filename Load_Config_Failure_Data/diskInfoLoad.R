# Load disk information from two files
rm(list = ls())
source('head.R')

####################################
# 1. read ip and disk number from TABLE d_smart_1021.csv
diskA_ip <- read.csv(file.path(dir_data,'d_smart_1021.csv'),head = F)
diskA <- diskA_ip[,1:2]
names(diskA) <- c('ip','device')
diskA <- diskA[!duplicated(diskA[c('ip','device')]),]
diskAip <- melt(table(diskA$ip))
names(diskAip) <- c('ip','disknum')

# 2. read ip, disk number and model from TABLE smart_Tencent_disk.csv
diskB_ip <- read.csv(file.path(dir_data,'0303_smart_Tencent_disk.csv'),head = F)
diskB <- diskB_ip[,1:4]
names(diskB) <- c('sn','ip','device','model')
diskB <- diskB[!duplicated(diskB[c('ip','sn')]),]

ipNoModel <- fct2ori(diskB$ip[diskB$model == ''])
diskB <- factorX(subset(diskB,!(ip %in% ipNoModel)))

diskBip <- melt(table(diskB$ip))
names(diskBip) <- c('ip','disknum')

# merge two dataset into disk. 
# disk is a table including ip and number of disks.
diskAll <- rbind(diskAip,diskBip)
diskAll <- diskAll[!duplicated(diskAll['ip']),]

# 3. Add model_clear and capacity for diskB
info.model <- read.csv(file.path(dir_data,'num_model.csv'))

diskB$oriModel <- diskB$model
diskB$model <- info.model$Model_clear[match(diskB$oriModel,info.model$Model_ori)]
diskB$capacity <- info.model$capacity[match(diskB$model,info.model$Model_clear)]
ipNoModel <- fct2ori(diskB$ip[is.na(diskB$model)])
diskB <- factorX(subset(diskB,!(ip %in% ipNoModel)))

# 4.paste all model together
# detailModel = data.frame(ip = levels(diskB$ip),
#                          uniModel = tapply(diskB$model,diskB$ip,
#                                            function(x)paste(unique(x[x != 'NOMODEL']),collapse = '_')))
# detailModel$uniModel[detailModel$uniModel == ''] <- 'NOMODEL'
# detailModel$uniModel <- factor(detailModel$uniModel)
# save(detailModel,file = file.path(dir_data,'detailModel.Rda'))
load(file.path(dir_data,'detailModel.Rda'))

# 5. Generate disk_ip for diskB

# for server with only one disk
diskB1 <- factorX(subset(diskB,ip %in% diskBip$ip[diskBip$disknum == 1]))
disk_ip1 <- diskB1[,c('ip','capacity','model')]
disk_ip1$numDisk <- 1;disk_ip1$numModel <- 1;
disk_ip1$numMain <- 1;disk_ip1$mainModel <- disk_ip1$model
disk_ip1 <- disk_ip1[,c('ip','capacity','numDisk','numModel','mainModel','numMain')]

# for server with multiple disks
diskB2 <- factorX(subset(diskB,ip %in% diskBip$ip[diskBip$disknum != 1],c('ip','model','capacity')))
diskB2$ip <- fct2ori(diskB2$ip)
diskB2$model <- fct2ori(diskB2$model)
splitIP <- split(diskB2,diskB2$ip)

modelInfo <- function(df){
  cat(sprintf('[diskInfoLoad::modelInfo] svrid:%s\n',df$ip[1]))
  tmp <- sort(table(df$model),decreasing = T)
  list(ip = df$ip[1],
       capacity = sum(df$capacity),
       numDisk = sum(tmp),
       numModel = length(names(tmp)),
       mainModel = names(tmp)[1],
       numMain = as.numeric(tmp[1]))
}

disk_ip2 <- lapplyX(splitIP,modelInfo)
disk_ip2 <- data.frame(matrix(unlist(disk_ip2),byrow = T,nrow = length(disk_ip2)))
names(disk_ip2) <- names(disk_ip1)

# merge 
disk_ip <- factorX(rbind(disk_ip1,disk_ip2))
disk_ip$numDisk <- as.numeric(disk_ip$numDisk)
disk_ip$capacity <- as.numeric(disk_ip$capacity)
disk_ip$numModel <- as.numeric(disk_ip$numModel)
disk_ip$numMain <- as.numeric(disk_ip$numMain)
disk_ip <- disk_ip[,c('ip','capacity','numDisk','numModel','numMain','mainModel')]

# 5. save
# diskAll是一个ip一行 for all disk from two files
# diskB是一个disk一行 from one file
# disk_ip: one line for one ip with more infomation from the same file as diskB
save(diskAll,detailModel,diskB,disk_ip,file = file.path(dir_data,'disk_two_lists.Rda'))
