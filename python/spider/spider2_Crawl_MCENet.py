##spider_MCENet.py
##目的：爬取http://bioinformatics.cau.edu.cn/MCENet/search_result.php?gene=GRMZM2G021617%0D%0A&query=Zm_Oth_Ara
##为了获取相关的同源基因
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#依赖 模块讲解 requests是请求网页 random随机函数  csv csv数据读写  re 正则表达式  time 定时操作  BeautifulSoup 解析html的包

import requests,random
import csv,re
import time
from bs4 import BeautifulSoup

#反反爬虫部署，添加headers,random访问，增加代理，使用代理访问。
user_agents=['Mozilla/5.0 (Windows NT 6.1; rv:2.0.1) Gecko/20100101 Firefox/4.0.1','Mozilla/5.0 (Windows; U; Windows NT 6.1; en-us) AppleWebKit/534.50 (KHTML, like Gecko) Version/5.1 Safari/534.50','Opera/9.80 (Windows NT 6.1; U; en) Presto/2.8.131 Version/11.11']

gene_name=["origin_V3"]
Atr_name=["ATR"]
annotation=["description"]
p_value=["0.5"]

# 判断内容是否存在
#参数htmlcontent 抓的html  ， content_selector 是要判断是否存在的字符串
#用法示例 judge=chargecontent(html,"not available")
def chargecontent(htmlcontent, content_selector):
	soup = BeautifulSoup(htmlcontent, "html.parser")
	# 去除script
	s=soup.get_text("/",strip=True)
	hascontent = False
	li=re.findall(content_selector,s)
	hascontent = len(li) > 0
	return hascontent


##定义主爬取函数，需要传入参数为genename  V3版本
def getGid(genename):
	#payload={'gene':'GRMZM2G147279','query':'Zm_Oth_Ara'}
	payload={'gene':genename,'query':'Zm_Oth_Ara'}
	headers={'User-Agent':random.choice(user_agents)}
	proxies={'http':'74.59.132.126:49073','https':'74.59.132.126:49073'}
	url="http://bioinformatics.cau.edu.cn/MCENet/search_result.php"
	#req=requests.get(url,headers=headers,params=payload,proxies=proxies)
	req=requests.get(url,headers=headers,params=payload)
	html=req.text
	##预先判断是否存在页面是否被返回正常值，否，则不解析文本
	judge=chargecontent(html,"not available")
	if judge:
		out_data=[genename,"","",""]
	else:
		bf=BeautifulSoup(html,"html5lib")
		thread=bf.find('tbody')
		gene1=thread.select_one('tr >td:nth-of-type(1)').text
		gene2=thread.select_one('tr >td:nth-of-type(2)').get_text()
		gene3=thread.select_one('tr >td:nth-of-type(3)').text
		gene4=thread.select_one('tr >td:nth-of-type(4)').text
		out_data=[gene1,gene2,gene3,gene4]
	return out_data


genecount=csv.reader(open('spider.csv','r'))
gene_table=['gene_name','Atr_name','annotation','p_value']
for geneid in genecount:
	print(geneid[0])
	getdata=getGid(geneid[0])
	gene_table.append(getdata)
	time.sleep(random.random()) #暂停[0,1)秒

#gene_table=[gene_name,Atr_name,annotation,p_value]
headers=['V3','Atr','description','pvalue']
with open('out_spider.csv','w',newline='') as f:
	writer=csv.writer(f)
	writer.writerow(headers)
	#for row in gene_table:
	#	writer.writerow(row)
	writer.writerows(gene_table)