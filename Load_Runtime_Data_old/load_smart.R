#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Filename: load_smart.R
#
# Description: 
#
# Copyright (c) 2015, Yusheng Yi <yiyusheng.hust@gmail.com>
#
# Version 1.0
#
# Initial created: 2015-11-27 09:32:57
#
# Last   modified: 2015-12-07 20:53:23
#
#
#
rm(list = ls())
dir_code <- '/home/yiyusheng/Code/R'
dir_data <- '/home/yiyusheng/Data/'
smart <- read.csv(file.path(dir_data,'AllSMART'), header = F)
names(smart) <- c('class','sn','time','ftime','ip','device','modelNum','Raw_Read_Error_Rate_Value','Spin_Up_Time_Value','Reallocated_Sector_Ct_Value','Reallocated_Sector_Ct_Raw','Seek_Error_Rate_Value','Spin_Retry_Count_Value','Calibration_Retries_Value','Unsafe_Shutdown_Count_Value','Power_Cycle_Count_Value','PowerOnHours_Count_Value','Offline_Uncorrectable_Value','Temperature_Celsius_Value','Udma_CRC_Error_Count_Value','Current_Pending_Sector_Value','Current_Pending_Sector_Raw')
save(smart,file = file.path(dir_data,'AllSMART.Rda'))
