# Data load function
# Date: 2016-08-23 11:32
# Author: york

# F1. deduplicate failure list by time
# preserve the first failure in a time slide with more than one failures 
dedupTime <- function(data.flist,dayDup,attr){
  data.flist <- data.flist[order(data.flist[[attr]],data.flist$f_time),]
  data.flist[[attr]] <- as.character(data.flist[[attr]])
  delset <- numeric()
  
  pSvrid <- data.flist[[attr]][1]
  pFtime <- data.flist$f_time[1]
  for (i in 2:nrow(data.flist)){
    curSvrid <- data.flist[[attr]][i]
    curFtime <- data.flist$f_time[i]
    if (curSvrid == pSvrid & 
        as.numeric(difftime(curFtime,pFtime,tz = 'UTC',units = 'days')) > dayDup){
      pFtime <- curFtime
      next
    } else if(curSvrid == pSvrid & 
              as.numeric(difftime(curFtime,pFtime,tz = 'UTC',units = 'days')) <= dayDup){
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
