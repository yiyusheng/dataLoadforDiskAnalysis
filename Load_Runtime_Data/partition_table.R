#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Filename: partition_table.R
#
# Description: build the partition table for svrid partition for attr_*
#
# Copyright (c) 2017, Yusheng Yi <yiyusheng.hust@gmail.com>
#
# Version 1.0
#
# Initial created: 2017-04-06 20:50:40
#
# Last   modified: 2017-04-06 20:50:42
#
#
#

rm(list = ls());source('~/rhead')
load(file.path(dir_data,'cmdb_allattr.Rda'))
svrid_all <- data.frame(svrid = sort(levels(cmdb_allattr$svr_asset_id)),
                    id = ceiling((1:(nrow(cmdb_allattr)-1))/3000))
svrid_all$svrid <- fct2ori(svrid_all$svrid)
partition_table <- split(svrid_all,svrid_all$id)
save(partition_table,svrid_all,file = file.path(dir_data,'partition_table.Rda'))
