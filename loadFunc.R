# Data load function
# Date: 2016-08-23 11:32
# Author: york

# F1. deduplicate failure list by time
# preserve the first failure in a time slide with more than one failures 
dedupTime <- function(data.flist,dayDup){
  data.flist <- data.flist[order(data.flist$ip,data.flist$f_time),]
  data.flist$svr_id <- as.character(data.flist$svr_id)
  delset <- numeric()
  
  pSvrid <- data.flist$svr_id[1]
  pFtime <- data.flist$f_time[1]
  for (i in 2:nrow(data.flist)){
    curSvrid <- data.flist$svr_id[i]
    curFtime <- data.flist$f_time[i]
    if (curSvrid == pSvrid & 
        difftime(curFtime,pFtime,tz = 'UTC',units = 'days') > dayDup){
      pFtime <- curFtime
      next
    } else if(curSvrid == pSvrid & (curFtime - pFtime) <= dayDup){
      delset <- c(delset,i)
    } else if(curSvrid != pSvrid){
      pFtime <- curFtime
      pSvrid <- curSvrid
      next
    }
  }
  data.flist <- data.flist[-delset,]
  data.flist <- factorX(data.flist)
  data.flist
}