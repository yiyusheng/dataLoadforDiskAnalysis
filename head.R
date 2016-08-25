#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Filename: head.R
#
# Description: 
#
# Copyright (c) 2016, Yusheng Yi <yiyusheng.hust@gmail.com>
#
# Version 1.0
#
# Initial created: 2016-05-27 15:36:07
#
# Last   modified: 2016-07-26 10:37:17
#
#
#
osFlag = Sys.info()[1] == 'Windows' 
dirName <- 'dataLoadforDiskAnalysis'
if (osFlag){
  dir_code <- paste('D:/Git/',dirName,sep='')
  dir_data <- paste('D:/Data/',dirName,sep='')
  setwd(dir_code)
  source(file.path(dir_code,'loadFunc.R'))
  source('D:/Git/R_Function/Rfun.R')
}else{
  dir_code <- paste('/home/yiyusheng/Code/R/',dirName,sep='')
  setwd(dir_code)
  dir_data <- paste('/home/yiyusheng/Data/',dirName,sep='')
  source('/home/yiyusheng/Code/R/R_Function/Rfun.R')
  source(file.path(dir_code,'loadFunc.R'))
  # options('width' = 150)
}

# require('caret')
# require('e1071')
# require('ggplot2')
require('scales')
require('reshape2')
require('grid')
