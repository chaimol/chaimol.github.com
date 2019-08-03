#!/bin/bash

###changeidV4toV3

import pandas as pd
df1=pd.read_csv('tf.csv',encoding='utf-8')
df2=pd.read_csv('maize_geneid_exchange.csv',encoding='utf-8')

#匹配相同内容的行，匹配到之后返回匹配到的行，未匹配到则不返回
#index=df1['V4'].isin(df2['V4'])
#outfile=df1[index]
#outfile.to_csv('outfile.csv',index=False,encoding='utf-8')



#匹配相同内容的行，匹配到之后添加内容到右侧文件。为匹配到返回的是NA。
outer=pd.merge(df2,df1,how='right')
outer.to_csv('key_genes_function.csv',index=False,encoding='utf-8')




