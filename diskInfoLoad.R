# Load disk information from two files
rm(list = ls())
source('head.R')

####################################
# 1. read ip and disk number from TABLE d_smart_1021.csv
diskA_ip <- read.csv(file.path(dir_data,'d_smart_1021.csv'),head = F)
diskA <- diskA_ip[,1:2]
names(diskA) <- c('ip','device')
diskA <- diskA[!duplicated(diskA[c('ip','device')]),]
diskA <- melt(table(diskA$ip))

# 2. read ip, disk number and model from TABLE smart_Tencent_disk.csv
diskB_ip <- read.csv(file.path(dir_data,'0303_smart_Tencent_disk.csv'),head = F)
diskBModel <- diskB_ip[,1:4]
names(diskBModel) <- c('sn','ip','device','model')
diskBModel <- diskBModel[!duplicated(diskBModel[c('ip','sn')]),]
diskBModel$model <- as.character(diskBModel$model)
diskBModel$model[diskBModel$model==''] <- 'NOMODEL'
diskBModel$model <- as.factor(diskBModel$model)
diskB <- melt(table(diskBModel$ip))

# merge two dataset
disk <- rbind(diskA,diskB)
names(disk) <- c('ip','disknum')
disk <- disk[!duplicated(disk['ip']),]

# 3. merge diskBmodel and num_info
info.model <- read.csv(file.path(dir_data,'num_model.csv'))
diskBModel <- merge(diskBModel,info.model[,1:2],by.x = 'model',by.y = 'Model_ori',all.x = T)
diskBModel$Model_clear <- as.character(diskBModel$Model_clear)
diskBModel$Model_clear[is.na(diskBModel$Model_clear)] <- 'NOMODEL'
diskBModel$Model_clear <- factor(diskBModel$Model_clear)

# 4. export disk model to search capacity of them
diskBModel$ipm <- paste(diskBModel$ip,diskBModel$model,sep='_')
table.ipm <- table(diskBModel$ipm)
disk_model <- strsplit(as.character(names(table.ipm)),'_')
disk_model <- data.frame(t(sapply(disk_model,c)))
disk_model$count <- as.numeric(table.ipm)
names(disk_model) <- c('ip','model','number')

# 5. read model info
disk_model$model_ori <- disk_model$model
disk_model$model <- info.model$Model_clear[match(disk_model$model_ori,info.model$Model_ori)]
disk_model$model <- as.character(disk_model$model)
disk_model$model[!is.element(disk_model$model,info.model$Model_clear)] <- 'NOMODEL'
disk_model$model <- as.factor(disk_model$model)

# 6. 给disk model添加容量,数量等信息
model_info <- read.csv(file.path(dir_data,'num_model.csv'))
model_info <- model_info[!duplicated(model_info$Model_clear),]
disk_model <- subset(disk_model,model!='NOMODEL')
disk_model <- merge(disk_model,model_info,by.x = 'model',by.y = 'Model_clear',all.x = T)
disk_model$total <- disk_model$capacity*disk_model$number
disk_model$Count <- NULL
disk_model$Model_ori <- NULL
disk_model$Discs <- disk_model$Discs*disk_model$number
disk_model$Heads <- disk_model$Heads*disk_model$number

# 7. 为有disk model的ip建立的表
disk_model$interface <- as.character(disk_model$interface)
disk_model$interface[disk_model$interface == 'SATA 3Gb/s'] <- 'SATA2'
disk_model$interface[disk_model$interface == 'SATA 6Gb/s'] <- 'SATA3'
disk_ip <- data.frame(ip = levels(disk_model$ip),
                      total = as.numeric(tapply(disk_model$total,disk_model$ip,sum)),
                      disk_c = as.numeric(tapply(disk_model$number,disk_model$ip,sum)),
                      disc_c = as.numeric(tapply(disk_model$Discs,disk_model$ip,sum)),
                      head_c = as.numeric(tapply(disk_model$Heads,disk_model$ip,sum)),
                      disk_model = factor(tapply(as.character(disk_model$model),disk_model$ip,
                                                 function(x)paste(x,collapse='_'))),
                      disk_cache = factor(tapply(as.character(disk_model$Cache.MB.), disk_model$ip,
                                                 function(x)paste(x,collapse='_'))),
                      disk_inter = factor(tapply(as.character(disk_model$interface),disk_model$ip,
                                                 function(x)paste(x,collapse='_'))),
                      disk_model_c = factor(tapply(disk_model$number,disk_model$ip,
                                                   function(x)paste(x,collapse='_'))),
                      disk_model_c1 = as.numeric(tapply(disk_model$number,disk_model$ip,length)))      
disk_ip <- disk_ip[!is.na(disk_ip$total),]
row.names(disk_ip) <- NULL

# 8. save
# disk_ip是一个ip一行,diskBmodel是一个disk一行.
save(disk,diskBModel,disk_model,disk_ip,file = file.path(dir_data,'disk_two_lists.Rda'))