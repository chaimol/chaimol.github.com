
#说明：此文件是爬取NCBI的基因数据，获取对应的gid，是python3的爬虫。
#暂时在读取本地文件后数据处理有bug,等待修复。


#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests,random
import csv
from bs4 import BeautifulSoup
#https://www.ncbi.nlm.nih.gov/gene/?term=Zm00001d011037
#payload={'term':'Zm00001d011037'}
#genename='Zm00001d011037'

#反反爬虫部署，添加headers,random访问，增加代理，使用代理访问。
user_agents=['Mozilla/5.0 (Windows NT 6.1; rv:2.0.1) Gecko/20100101 Firefox/4.0.1','Mozilla/5.0 (Windows; U; Windows NT 6.1; en-us) AppleWebKit/534.50 (KHTML, like Gecko) Version/5.1 Safari/534.50','Opera/9.80 (Windows NT 6.1; U; en) Presto/2.8.131 Version/11.11']	
def getGid(genename): 
	#files={'file':open('deg.csv','rb')}
	payload={'term':genename}
	headers={'User-Agent':random.choice(user_agents)}
	proxies={'http':'74.59.132.126:49073','https':'74.59.132.126:49073'}
	url="https://www.ncbi.nlm.nih.gov/gene/"
	#req=requests.get(url,headers=headers,params=payload,proxies=proxies)
	req=requests.get(url,headers=headers,params=payload)
	html=req.text  
	bf=BeautifulSoup(html,"html5lib")
	h1=bf.find_all('h1',id='gene-name') 
	a_bf=BeautifulSoup(str(h1[0]))
	a=a_bf.find_all('span')
	#此处的gid就是我们要的基因的GID值
	gid = a[0].text.replace('\xa0'*8,'\n\n')  
	return gid	

	
genecount=csv.reader(open('deg.csv','r'))

gene_table=['gid']
locus=['genename']

for geneid in genecount:
	print(geneid[0])
	gid=getGid(geneid[0])
	gene_table.append(gid)
	locus.append(geneid)
	time.sleep(random.random()) #暂停[0,1)秒

with open('out.csv','w',newline='') as f:
	writer=csv.writer(f)
	for row in gene_table:
		writer.writerow(row)
		
		
		
	




