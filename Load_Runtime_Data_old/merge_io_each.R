rm(list = ls())
source('/home/yiyusheng/Code/R/Rfun.R')
dir_data <- '/home/yiyusheng/Data/allIOMerge'

fname <- paste('data',seq(1,25),'.Rda',sep = '')
allIO <- data.frame()

for(i in seq(1:length(fname))){
  sprintf('File:%s  length:%d',fname[i],nrow(data))
  print(i)
  load(file.path(dir_data,fname[i]))
  allIO <- rbind(allIO,data)
}
save(allIO,file = file.path(dir_data,'allIO.Rda'))
