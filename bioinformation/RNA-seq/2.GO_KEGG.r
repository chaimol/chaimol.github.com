
install.packages("export")
source("https://bioconductor.org/biocLite.R")
biocLite("DESeq2")

install.packages("tidyverse")
#输入数据
library(tidyverse)
library(DESeq2)
library(ggplot2)
library(export)
#import data
#setwd("/home/chaim/disk/lyb/data/")
#setwd("/mnt/d/RNA-seq/")
setwd("D:/RNA-seq/")

countData <- as.matrix(read.csv("transcript_count_matrix.csv",row.names="transcript_id"))

condition <- factor(c(rep("NS",3),rep("WT",3)),levels = c("NS","WT"))
colData <- data.frame(row.names=colnames(countData),condition)
dds <- DESeqDataSetFromMatrix(countData = countData,colData = colData, design = ~ condition)
dds <- DESeq(dds)

#总体结果查看
res = results(dds)
res = res[order(res$pvalue),]

summary(res)
write.csv(res,file="trans_All_results.csv")
table(res$padj<0.05)






#提取差异基因（DEGs）并进行gene Symbol注释

diff_gene_deseq2 <- subset(res,padj<0.05 & abs(log2FoldChange)>1)
dim(diff_gene_deseq2)
write.csv(diff_gene_deseq2,file = "trans_DEG_treat_vs_control.csv")
#上调基因   转录本4577个
up_gene <- subset(res,padj<0.05&log2FoldChange>1)
write.csv(up_gene,file ="up_gene.csv")
summary(up_gene)

#下调基因  转录本5837个
down_gene <-subset(res,padj<0.05&log2FoldChange<(-1))
write.csv(down_gene,file="down_gene.csv")
summary(down_gene)
#统计counts分布
plotMA(res,ylim=c(-2,2))
plotMA(diff_gene_deseq2,ylim=c(-2,2))


#构造图片输出函数，need input filename width height
#函数依赖export包
out_img <- function(filename,pic_width=5,pic_height=7){
  graph2png(file=filename,width=pic_width,height=pic_height)
  graph2ppt(file=filename,width=pic_width,height=pic_height)
  graph2tif(file=filename,width=pic_width,height=pic_height)
}
out_img(filename="depseq2_filter_count")

#使用Shrinkage of effect size (LFC estimates) is useful for visualization and ranking of genes. To shrink the LFC, we pass the dds object to the function  lfcShrink. Below we specify to use the apeglm method for effect size shrinkage (Zhu, Ibrahim, and Love 2018), which improves on the previous estimator.
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("apeglm", version = "3.8")
library("apeglm")
resultsNames(dds)
resLFC <- lfcShrink(dds,coef = "condition_WT_vs_NS",type="apeglm")
plotMA(resLFC,ylim=c(-2,2))

resOrdered <- res[order(resLFC$pvalue),]
summary(resOrdered)
resSig <- subset(resOrdered,padj < 0.1)
summary(resSig)
write.csv(as.data.frame(resOrdered),file="Trans_trans_filter_condition_treat_result.csv")
write.csv(as.data.frame(resSig),file="Trans_trans_filter_treat_result.csv")

#生成对应的散点火山图
  resdata <- read.csv("trans_All_results.csv",header = TRUE)
  threshold <- as.factor(ifelse(resdata$padj < 0.05 & abs(resdata$log2FoldChange) >= 1 ,ifelse(resdata$log2FoldChange >= 1 ,'Up','Down'),'Not'))
  deg_img <- ggplot(resdata,aes(x=resdata$log2FoldChange,y=-log10(resdata$padj),colour=threshold)) + xlab("log2(Fold Change)")+ylab("-log10(qvalue)") + geom_point(size = 0.5,alpha=1) + ylim(0,200) + xlim(-12,12) + scale_color_manual(values=c("green","grey", "red"))
  #ggsave("tran_deg.pdf",deg_img)
  deg_img
  out_img(filename="trans_deg")
 
  #聚类热图
  ##此处生成的是所有的结果的热图
  install.packages("pheatmap")
  if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
  BiocManager::install("genefilter", version = "3.8")
  #out.csv 是DEG_treat_vs_control.csv中过滤掉未被注释的基因，out.csv是已经注释的基因
  #resgene <- read.csv("out.csv",header = TRUE) 
  library(readr)
  library("genefilter")
  library(pheatmap)
  #rld <- rlogTransformation(dds,blind=F)   #根据系统提示，建议更换方差稳定转换算法即varianceStabilizingTransformation
  rld <- varianceStabilizingTransformation(dds,blind = TRUE)
  write.csv(assay(rld),file="trans_mm.DeSeq2.pseudo.counts.csv")
  topVarGene <- head(order(rowVars(assay(rld)),decreasing = TRUE),50)
  mat <- assay(rld)[topVarGene,]
  mat <- mat - rowMeans(mat) #减去一个平均值，让数值更加集中
  anno <- as.data.frame(colData(rld)[,c("condition","sizeFactor")])
  pheat <- pheatmap(mat,annotation_col=anno)
  #ggsave("pheatmap.png",pheat,width=12,height=12)
  out_img(filename="pheatmap",pic_width = 12,pic_height = 12)
  


# #安装biomaRt包
# source("http://bioconductor.org/biocLite.R")
# biocLite("biomaRt")
# install.packages('DT')
# #用bioMart对差异表达基因进行注释
# library("biomaRt")
# listMarts()
# 
# ensembl=useMart("ENSEMBL_MART_ENSEMBL")
# all_datasets <- listDatasets(ensembl)
# library(DT)
# datatable(all_datasets,options = list(searching=FALSE,pageLength=5,lengthMenu=c(5,10,15,20)))



#安装clusterProfiler 用于GO/KEGG分析及GSEA
source("https://bioconductor.org/biocLite.R")
biocLite("clusterProfiler")
biocLite("DOSE")
library(DO.db)
require(DOSE)
library(clusterProfiler)


 if (!requireNamespace("BiocManager", quietly = TRUE))
   install.packages("BiocManager")
 BiocManager::install("S4Vectors", version = "3.8")
 
 
 

#安装annotationhub
if(!requireNamespace("BiocManager",quietly = TRUE))
install.packages("BiocManager")
BiocManager::install("AnnotationHub", version = "3.8")

library(AnnotationHub)
require(AnnotationHub)
hub <- AnnotationHub()



unique(hub$dataprovider)

query(hub,"zea mays")

maize <- hub[['AH66226']]
length(keys(maize))

#显示maize支持的所有的数据
columns(maize)

require(clusterProfiler)
library(clusterProfiler)
bitr(keys(maize)[1],'GID',c("GO","ENTREZID","UNIGENE"),maize)


#GO富集分析
#使用enrichGO

geneid <- read.csv('tran_deg_entrze.csv')
target_gene_id <- geneid[,1]

#target_gene_id <- unique(read.delim("geneid2GO",header = TRUE)$GO_term_accession)

#此处有三种模式可供选择，分别是BP，CC，MF

#设置总的条形图中展示的每一种的数据条目数量
display_number = c(1,6,6)

#MF 模式
MF_GO=enrichGO(target_gene_id,OrgDb=maize,keyType = 'ENTREZID',ont="MF",pvalueCutoff=0.05,qvalueCutoff=0.05)
#write.csv(as.data.frame(MF_GO@result),"tran_GO_result_MF.csv")
#write.csv(as.data.frame(MF_GO),"tran_GO_MF.csv",row.names = F)
ego_MF_GO <- as.data.frame(MF_GO)[1:display_number[1],]
head(as.data.frame(MF_GO))

#BP 模式
BP_GO=enrichGO(target_gene_id,OrgDb=maize,keyType = 'ENTREZID',ont="BP",pvalueCutoff=0.05,qvalueCutoff=0.05)
#write.csv(as.data.frame(res_GO@result),"tran_GO_result_BP.csv")
#write.csv(as.data.frame(res_GO),"tran_GO_MF.csv",row.names = F)
ego_BP_GO <- as.data.frame(BP_GO)[1:display_number[2],]
head(as.data.frame(BP_GO))

#CC模式
CC_GO=enrichGO(target_gene_id,OrgDb=maize,keyType = 'ENTREZID',ont="CC",pvalueCutoff=0.05,qvalueCutoff=0.05)
#write.csv(as.data.frame(CC_GO@result),"tran_GO_result_CC.csv")
#write.csv(as.data.frame(CC_GO),"tran_GO_CC.csv",row.names = F)
ego_CC_GO <- as.data.frame(CC_GO)[1:display_number[3],]
head(as.data.frame(CC_GO))

MF_GO <- ego_MF_GO
BP_GO <- ego_BP_GO
CC_GO <- ego_CC_GO

##合并三种模式的结果，输出到一张图上
go_enrich_df <- data.frame(ID=c(MF_GO$ID,BP_GO$ID,CC_GO$ID),Description=c(MF_GO$Description,BP_GO$Description,CC_GO$Description),GeneNumber=c(MF_GO$Count,BP_GO$Count,CC_GO$Count),type=factor(c(rep("molecular function",display_number[1]),rep("biological process",display_number[2]),rep("cellular component",display_number[3])),levels = c("molecular function","biological process","cellular component")))

#x轴数据
go_enrich_df$number <- factor(rev(1:nrow(go_enrich_df)))

## shorten the names of GO terms
shorten_names <- function(x, n_word=4, n_char=40){
  if (length(strsplit(x, " ")[[1]]) > n_word || (nchar(x) > 40))
  {
    if (nchar(x) > 40) x <- substr(x, 1, 40)
    x <- paste(paste(strsplit(x, " ")[[1]][1:min(length(strsplit(x," ")[[1]]), n_word)],
                     collapse=" "), "...", sep="")
    return(x)
  } 
  else
  {
    return(x)
  }
}

labels=(sapply(
  levels(go_enrich_df$Description)[as.numeric(go_enrich_df$Description)],
  shorten_names))
names(labels) = rev(1:nrow(go_enrich_df))

## colors for bar // green, blue, orange
CPCOLS <- c("#43c3a4", "#f88f61", "#85a1cf")
library(ggplot2)
p <- ggplot(data=go_enrich_df, aes(x=number, y=GeneNumber, fill=type)) +
  geom_bar(stat="identity", width=0.8) + coord_flip() + 
  scale_fill_manual(values = CPCOLS) + theme_bw() + 
  scale_x_discrete(labels=labels) +
  xlab("GO term") + 
  theme(axis.text=element_text(size=12, face="plain",color="black")) +
  labs(title = "The Most Enriched GO Terms",vjust=0.5,hjust=0.5)+theme(panel.grid=element_blank())  #删去网格线
p
out_img(filename = "most GO term",pic_width = 12,pic_height = 10)
write.csv(go_enrich_df,"all_GO_result.csv")


###################需要修改文件数据源######################################################################
#柱形图
barplot(MF_GO,showCategory = 30,title = "EnrichmentGO")
out_img(filename = "barplot_MF",pic_width = 12,pic_height = 12)
#气泡图
dotplot(res_GO,font.size=18,showCategory=30)
out_img(filename = "dot_MF",pic_width = 12,pic_height = 12)
#浓缩图
emapplot(res_GO,font.size=16)
out_img(filename = "emapplot_MF",pic_width = 12,pic_height = 12)
#网络图
enrichMap(res_GO,vertex.label.cex=1.2,layout=igraph::layout.kamada.kawai)



res_GO <- setReadable(res_GO,OrgDb = maize)
plotGOgraph(res_GO)
out_img(filename = "plotgraph_MF",pic_width = 12,pic_height = 12)

cnetplot(res_GO,categorySize="pvalue",foldChange=target_gene_id,font.size=18)

#生成圆形的网络图
cnetplot(res_GO,foldChange = target_gene_id,circular=TRUE,colorEdgr=TRUE)

#生成热图，GO的聚类，马赛克式样的图
heatplot(res_GO,foldChange = target_gene_id)

goplot(res_GO)
out_img(filename = "cnetplot_MF",pic_width = 12,pic_height = 12)



install.packages("ggThemeAssist")


#此处的ggThemeAssist是一个可视化的编辑图的工具
p + theme(plot.caption = element_text(family = "mono"), 
    panel.grid.major = element_line(colour = "gray99"), 
    plot.background = element_rect(linetype = "dashed"))

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("topGO", version = "3.8")

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("Rgraphviz", version = "3.8")


library(Rgraphviz)

#转换GO id 到 gid，其实gid就是ncbi-geneid
GO2gid <- bitr(target_gene_id,fromType = 'ENTREZID',toType = 'GID',OrgDb = 'maize')
gid2kegg <- bitr_kegg(GO2gid[,2],fromType = 'ncbi-geneid',toType = 'ncbi-proteinid',organism = 'zma')
head(gid2kegg,100)

#kegg
kk <- enrichKEGG(gene = gid2kegg[,2],organism ="zma",keyType = 'ncbi-proteinid',pvalueCutoff = 0.01,qvalueCutoff = 0.01)
##kk2 <- bitr_kegg(kk$geneID,fromType = 'ncbi_proteinid',toType = 'ncbi-geneid',organism = 'zma')
write.csv(as.data.frame(kk@result),file="kegg_all_result.csv")
write.csv(as.data.frame(kk),file = "kegg_result.csv")
barplot(kk,title = "Enrichment KEGG")
out_img(filename = "barplot_kegg",pic_width = 12,pic_height = 12)
dotplot(kk,showCategory=50,title="Enrichment KEGG")
out_img(filename = "dot_kegg",pic_width = 12,pic_height = 12)
emapplot(kk)
browseKEGG(kk,'zma00195')
browseKEGG(kk,'zma00196')
browseKEGG(kk,'zma04141')









#gse需要单独做数据格式
d <- read.csv("gsea_gene2entre.csv")
geneList <- d[,2]
names(geneList)=as.factor(d[,1])
geneList <- sort(geneList,decreasing = TRUE)

#gseGO进行GSEA分析


gseBP <- gseGO(geneList=geneList,ont="BP",OrgDb=maize,keyType = 'ENTREZID',nPerm = 50000,minGSSize = 100,maxGSSize = 6000,pvalueCutoff = 0.1,verbose = FALSE)


#gsaKEGG基因富集分析
kk2 <- gseKEGG(geneList = geneList,organism = 'zma',pvalueCutoff = 0.05,verbose = FALSE)

kk2 <- gseKEGG(gene = gid2kegg[,2],organism ="zma",keyType = 'ncbi-proteinid',pvalueCutoff = 0.01,verbose = FALSE)
gseaplot(kk2,geneSetID = "zma03010")






unique(hub$species[which(hub$species=="zea mays")])






