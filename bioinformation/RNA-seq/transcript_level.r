
install.packages("export")
source("https://bioconductor.org/biocLite.R")
biocLite("DESeq2")
install.packages("pheatmap")
install.packages("tidyverse")
#安装clusterProfiler 用于GO/KEGG分析及GSEA
source("https://bioconductor.org/biocLite.R")
biocLite("clusterProfiler")
biocLite("DOSE")

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("S4Vectors", version = "3.8")
if(!requireNamespace("BiocManager",quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("AnnotationHub", version = "3.8")

library(DO.db)
require(DOSE)
library(clusterProfiler)
library(AnnotationHub)
library(readr)
library("genefilter")
library(pheatmap)

#输入数据
library(tidyverse)
library(DESeq2)
library(ggplot2)
library(export)
library(enrichplot)
library(Rgraphviz)
#import data
#setwd("/home/chaim/disk/lyb/data/")
#setwd("/mnt/d/RNA-seq/")
setwd("D:/RNA-seq/transcript_level/")

#构造图片输出函数，need input filename width height
#函数依赖export包
out_img <- function(filename,pic_width=5,pic_height=7){
  graph2png(file=filename,width=pic_width,height=pic_height)
  graph2ppt(file=filename,width=pic_width,height=pic_height)
  graph2tif(file=filename,width=pic_width,height=pic_height)
}

countData <- as.matrix(read.csv("transcript_count_matrix.csv",row.names="transcript_id"))

condition <- factor(c(rep("ELS5",3),rep("WT",3)),levels = c("WT","ELS5"))
colData <- data.frame(row.names=colnames(countData),condition)
dds <- DESeqDataSetFromMatrix(countData = countData,colData = colData, design = ~ condition)

#预先过滤总count<10的行
keep10 <- rowSums(counts(dds)) >= 10
dds <- dds[keep10,]

dds$condition <- relevel(dds$condition,ref="WT")
dds <- DESeq(dds)

#总体结果查看
res = results(dds,pAdjustMethod = "fdr",alpha = 0.05)
res = res[order(res$pvalue),]

###修改临时目录2019.07.06
setwd("D:/RNA-seq/transcript_levelV2/")
summary(res)
write.csv(res,file="trans_All_results.csv")

res_sig <- subset(res,padj<0.05)
write.csv(res_sig,file = "trans_DEG_significant.csv")


#提取差异基因（DEGs）并进行gene Symbol 过滤后有10732个转录本

diff_gene_deseq2 <- subset(res,padj<0.05 & abs(log2FoldChange)>1)
dim(diff_gene_deseq2)
write.csv(diff_gene_deseq2,file = "2trans_DEG_treat_vs_control.csv")
#上调基因   转录本5972个
up_gene <- subset(res,padj<0.05&log2FoldChange>1)
write.csv(up_gene,file ="2up_gene.csv")
summary(up_gene)

#下调基因  转录本4760个
down_gene <-subset(res,padj<0.05&log2FoldChange<(-1))
write.csv(down_gene,file="2down_gene.csv")
summary(down_gene)




#Principal Component Analysis(PCA)主成分分析
ddsMartlog <- vst(dds,blind=FALSE)
write.csv(assay(ddsMartlog),file = "trans_PCA.csv")
plotPCA(ddsMartlog,intgroup=c("condition"))+geom_point(size=5)+ggtitle(label = "Principal Component Analysis (PCA)")
out_img(filename = "PCA")
select <- order(rowMeans(counts(dds,normalized=TRUE)),decreasing = TRUE)[1:20]
df <- as.data.frame(colData(dds)[,c("condition","sizeFactor")])

#生成数据矩阵的热图
pheatmap(assay(ddsMartlog)[select,], cluster_rows=FALSE, show_rownames=FALSE,cluster_cols=FALSE, annotation_col=df)
out_img(filename="PCA_heatmap")

#样本到样本距离的热图
sampleDists <- dist(t(assay(ddsMartlog)))
library("RColorBrewer")
sampleDistMatrix <- as.matrix(sampleDists)
rownames(sampleDistMatrix) <- paste(ddsMartlog$condition,ddsMartlog$sizeFactor,sep="-")
colnames(sampleDistMatrix) <- NULL
colors <- colorRampPalette(rev(brewer.pal(9,"Blues")))(255)
pheatmap(sampleDistMatrix,clustering_distance_rows = sampleDists,cluster_cols = sampleDists,col=colors)
out_img(filename = "Heatmap of the sample-to-sample distances",pic_height = 6,pic_width = 8)

#使用Shrinkage of effect size (LFC estimates) is useful for visualization and ranking of genes. To shrink the LFC, we pass the dds object to the function  lfcShrink. Below we specify to use the apeglm method for effect size shrinkage (Zhu, Ibrahim, and Love 2018), which improves on the previous estimator.
# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install("apeglm", version = "3.8")
###引用文章Zhu, A., Ibrahim, J.G., Love, M.I. (2018) Heavy-tailed prior distributions for sequence count data: removing the noise and preserving large differences. Bioinformatics. https://doi.org/10.1093/bioinformatics/bty895

library("apeglm")
resultsNames(dds)
resLFC <- lfcShrink(dds,coef = "condition_ELS5_vs_WT",type="apeglm")
plotMA(resLFC,xlim=c(1,1e5),ylim=c(-5,5),xlab="mean of normalized counts",ylab=expression(log[2]~fold~change),main="apeglm")

#idx <- identify(resLFC$baseMean,resLFC$log2FoldChange)
#rownames(res)[idx]

resOrdered <- res[order(resLFC$pvalue),]
summary(resOrdered)
resSig <- subset(resOrdered,padj < 0.05&abs(log2FoldChange)>1)

summary(resSig)
# write.csv(as.data.frame(resOrdered),file="Trans_trans_filter_condition_treat_result.csv")
write.csv(as.data.frame(resSig),file="2Trans_apeglm_filter_significamt_result.csv")




plotMA(res,ylim=c(-5,5))
out_img(filename="MA plot")
plotMA(diff_gene_deseq2,ylim=c(-10,10))

#生成对应的散点火山图（需要使用ggplot2和ggrepel）
install.packages("ggrepel")
library("ggplot2")
library("ggrepel")
resdata1 <- read.csv("trans_All_results.csv",header = TRUE)
resdata <- na.omit(resdata1)  ##此处是删除掉包含NA的行，这些行的结果不应纳入后续结果
threshold <- as.factor(ifelse(resdata$pvalue < 0.05 & abs(resdata$log2FoldChange) >= 1 ,ifelse(resdata$log2FoldChange >= 1 ,'Up','Down'),'Not'))
deg_img <- ggplot(resdata,aes(x=resdata$log2FoldChange,y=-log10(resdata$padj),colour=threshold,label=label)) + xlab("log2(Fold Change)")+ylab("-log10(qvalue)") + geom_point(size = 0.5,alpha=1) + ylim(0,82) + xlim(-18,18) + scale_color_manual(values=c("green","grey", "red"))+theme(plot.title = element_text(hjust = 0.5),legend.position = "right")

##添加阈值线
line_valcao <- deg_img+geom_hline(yintercept = 40,linetype="dotted")+geom_vline(xintercept=c(-1,1),linetype="dotted")

##使用ggrepel包给阈值范围以上的点添加标签
##注意此处是手动修改原始文件trans_All_result.csv,添加一列名称是label,内容是你选择显示的基因名称，只用写想显示的，不想显示的不用写，留空。
#threshold$label[1:20] <- resdata$X[1:20]
#threshold$label[21:length(resdata$X)] <- ""

valcano <- line_valcao+geom_text_repel(aes(label=resdata$label),point.padding = unit(0.25,"lines"),arrow = arrow(length=unit(0.01,"npc")),nudge_y = 0.1,show.legend = TRUE)+theme_classic(base_size = 14)
print(valcano)
out_img(filename="4trans_deg_valcano",pic_width = 7,pic_height = 6)

#箱线图，分析是否有某个样本异常，看看一个样本是否始终高于其他样本（本样本无异常）
boxplot(log10(assays(dds)[["cooks"]]), range=0, las=2)
out_img(filename = "PCA_boxplot",pic_width = 6,pic_height = 5 )

#聚类热图(前40个基因的热图)
rld <- ddsMartlog
topVarGene <- head(order(rowVars(assay(rld)),decreasing = TRUE),2000)
mat <- assay(rld)[topVarGene,]
mat <- mat - rowMeans(mat) #减去一个平均值，让数值更加集中
anno <- as.data.frame(colData(rld)[,c("condition","sizeFactor")])
pheat <- pheatmap(mat,scale = "row",annotation_col=anno,fontsize_row =5,show_rownames = FALSE,border=FALSE,color = colorRampPalette(c("blue","white","red"))(50))
out_img(filename="2pheatmap_20000",pic_width = 8,pic_height = 8)

#############test pheatmap##
# ddsMat_rlog <- rlog(ddsMatlog, blind = FALSE)
# 
# # Gather 30 significant genes and make matrix
# mat <- assay(ddsMat_rlog[row.names(results_sig)])[1:40, ]
# 
# 
# 
# # Specify colors you want to annotate the columns by.
# ann_colors = list(
#   Group = c(LoGlu = "lightblue", HiGlu = "darkorange"),
#   Replicate = c(Rep1 = "darkred", Rep2 = "forestgreen")
# )
# 
# # Make Heatmap with pheatmap function.
# ## See more in documentation for customization
# pheatmap(mat = mat, 
#          color = colorRampPalette(brewer.pal(9, "YlOrBr"))(255), 
#          scale = "row", # Scale genes to Z-score (how many standard deviations)
#          fontsize = 6.5, # Make fonts smaller
#          cellwidth = 55, # Make the cells wider
#          show_colnames = TRUE)
##############test end####
# #安装biomaRt包
# source("http://bioconductor.org/biocLite.R")
# biocLite("biomaRt")
# install.packages('DT')
#用bioMart对差异表达基因进行注释
# library("biomaRt")
# listMarts()
# 
# ensembl=useMart("ENSEMBL_MART_ENSEMBL")
# all_datasets <- listDatasets(ensembl)
# library(DT)
# datatable(all_datasets,options = list(searching=FALSE,pageLength=10,lengthMenu=c(10,15,20)))

#在本地使用python进行基因注释和ID转换。
#通过使用ensembl的数据库中的原始文件，进行比对。进行基因注释
#通过使用ensembl的tsv文件，转换maizegdb格式为entrez格式。



require(AnnotationHub)
hub <- AnnotationHub()
unique(hub$dataprovider)
query(hub,"zea mays")
maize <- hub[['AH66225']]
length(keys(maize))

#显示maize支持的所有的数据
columns(maize)

require(clusterProfiler)
library(clusterProfiler)
bitr(keys(maize)[1],'GID',c("ONTOLOGY","UNIGENE","REFSEQ"),maize)

###maize 数据格式说明
##ALIAS 别名，  GID=ENTREZID=NCBI_id=ensemlID, ONTOLOGY=CC/BP/MF  

#此处需要手动将基因的编号从maizegdb ID格式Zm00001d012566 转换为Entrez格式的ID。

#GO富集分析
#使用enrichGO

geneid <- read.csv('deg2entrez.csv')
target_gene_id <- geneid$xref

#target_gene_id <- unique(read.delim("geneid2GO",header = TRUE)$GO_term_accession)

#此处有三种模式可供选择，分别是BP，CC，MF

#设置总的条形图中展示的每一种的数据条目数量
display_number = c(1,6,6)

############################## MF模式start###############################
setwd("D:/RNA-seq/transcript_level/GO/MF/")
#MF 模式
MF_GO=enrichGO(target_gene_id,OrgDb=maize,keyType = 'ENTREZID',ont="MF",pvalueCutoff=0.05,qvalueCutoff=0.10)
write.csv(as.data.frame(MF_GO@result),"tran_GO_result_MF.csv")
write.csv(as.data.frame(MF_GO),"tran_GO_MF.csv",row.names = F)
ego_MF_GO <- as.data.frame(MF_GO)[1:display_number[1],]
head(as.data.frame(MF_GO))

#barplot(MF_GO,drop=TRUE,showCategory = 20,title = "GO Molecular Function")
#out_img(filename = "barplot_MF",pic_width = 12,pic_height = 12)
#气泡图
#dotplot(MF_GO,font.size=16,showCategory=20)
#out_img(filename = "dot_MF",pic_width = 12,pic_height = 12)
#浓缩图
#emapplot(MF_GO,font.size=16,showCategory=20)
#out_img(filename = "emapplot_MF",pic_width = 12,pic_height = 12)


res_GO <- setReadable(MF_GO,OrgDb = maize,keyType = "ENTREZID")
write.csv(res_GO,file="rMF_GO.csv")
plotGOgraph(res_GO)
out_img(filename = "plotgraph_MF",pic_width = 12,pic_height = 12)

cnetplot(res_GO,categorySize="pvalue",foldChange=target_gene_id,font.size=18)
out_img(filename = "cnet_MF",pic_width = 12,pic_height = 12)
#生成圆形的网络图
cnetplot(res_GO,foldChange = target_gene_id,circular=TRUE,colorEdge=TRUE)
out_img(filename = "circularnet_MF",pic_width = 12,pic_height = 12)
#生成热图，GO的聚类，马赛克式样的图
# heatplot(res_GO)
# out_img(filename = "heatplot_CC",pic_width = 12,pic_height = 12)
#goplot(res_GO)
#out_img(filename = "goplot_MF",pic_width = 12,pic_height = 12)

############################### MF模式end#####################################


#BP 模式
BP_GO=enrichGO(target_gene_id,OrgDb=maize,keyType = 'ENTREZID',ont="BP",pvalueCutoff=0.05,qvalueCutoff=0.10)
write.csv(as.data.frame(res_GO@result),"tran_GO_result_BP.csv")
write.csv(as.data.frame(res_GO),"tran_GO_BP.csv",row.names = F)
ego_BP_GO <- as.data.frame(BP_GO)[1:display_number[2],]
head(as.data.frame(BP_GO))

#CC模式
CC_GO=enrichGO(target_gene_id,OrgDb=maize,keyType = 'ENTREZID',ont="CC",pvalueCutoff=0.05,qvalueCutoff=0.10)
write.csv(as.data.frame(CC_GO@result),"tran_GO_result_CC.csv")
write.csv(as.data.frame(CC_GO),"tran_GO_CC.csv",row.names = F)
ego_CC_GO <- as.data.frame(CC_GO)[1:display_number[3],]
head(as.data.frame(CC_GO))

###################CC模式开始######################################################################
setwd("D:/RNA-seq/transcript_level/GO/CC/")
#柱形图
barplot(CC_GO,drop=TRUE,showCategory = 20,title = "GO Cellular Component")
out_img(filename = "barplot_CC",pic_width = 12,pic_height = 12)
#气泡图
dotplot(CC_GO,font.size=16,showCategory=20)
out_img(filename = "dot_CC",pic_width = 12,pic_height = 12)
#浓缩图
emapplot(CC_GO,font.size=16,showCategory=20)
out_img(filename = "emapplot_CC",pic_width = 12,pic_height = 12)

#转换结果中的ID为ncbi id,输出便于后期验证
res_GO <- setReadable(CC_GO,OrgDb = maize)
write.csv(res_GO,file="rCC_GO.csv")

plotGOgraph(res_GO)
out_img(filename = "plotgraph_CC",pic_width = 12,pic_height = 12)

cnetplot(res_GO,categorySize="pvalue",foldChange=target_gene_id,font.size=18)
out_img(filename = "cnet_CC",pic_width = 12,pic_height = 12)
#生成圆形的网络图
cnetplot(res_GO,foldChange = target_gene_id,circular=TRUE,colorEdge=TRUE)
out_img(filename = "circularnet_CC",pic_width = 12,pic_height = 12)
#生成热图，GO的聚类，马赛克式样的图
# heatplot(res_GO)
# out_img(filename = "heatplot_CC",pic_width = 12,pic_height = 12)
goplot(res_GO)
out_img(filename = "goplot_CC",pic_width = 12,pic_height = 12)
##############CC 模式结束###########################################

###########BP模式start#####
setwd("D:/RNA-seq/transcript_level/GO/BP/")
barplot(BP_GO,drop=TRUE,showCategory = 20,title = "GO Biological Process",cex.axis = 1.5)
out_img(filename = "barplot_BP",pic_width = 12,pic_height = 12)
#气泡图
dotplot(BP_GO,font.size=16,showCategory=20)
out_img(filename = "dot_BP",pic_width = 12,pic_height = 12)
#浓缩图
emapplot(BP_GO,font.size=16,showCategory=20)
out_img(filename = "emapplot_BP",pic_width = 12,pic_height = 12)
#网络图
enrichMap(BP_GO,vertex.label.cex=1.2,layout=igraph::layout.kamada.kawai)

rBP_GO <- setReadable(BP_GO,OrgDb = maize)
write.csv(rBP_GO,file = "rBP_GO.csv")
plotGOgraph(rBP_GO)
out_img(filename = "plotgraph_BP",pic_width = 12,pic_height = 12)

cnetplot(rBP_GO,categorySize="pvalue",foldChange=target_gene_id,font.size=18)
out_img(filename = "cnet_BP",pic_width = 12,pic_height = 12)
#生成圆形的网络图

#####如果报错，请调整R-studio的画图界面到尽可能大，再重新运行代码
cnetplot(rBP_GO,foldChange = target_gene_id,circular=TRUE,colorEdge=TRUE)
out_img(filename = "circularnet_BP",pic_width = 14,pic_height = 12)
#生成热图，GO的聚类，马赛克式样的图
# heatplot(rBP_GO)
# out_img(filename = "heatplot_CC",pic_width = 12,pic_height = 12)
goplot(rBP_GO, geom = "text")
out_img(filename = "3goplot_BP",pic_width = 10,pic_height = 9)
#############################BP模式end#################################






# install.packages("ggThemeAssist")
# 
# 
# #此处的ggThemeAssist是一个可视化的编辑图的工具
# p + theme(plot.caption = element_text(family = "mono"), 
#           panel.grid.major = element_line(colour = "gray99"), 
#           plot.background = element_rect(linetype = "dashed"))
# 
# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install("topGO", version = "3.8")
# 
# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install("Rgraphviz", version = "3.8")

############合并三种GO模式到一种#########
#ALLGO=enrichGO(target_gene_id,OrgDb=maize,keyType = 'ENTREZID',ont="ALL",pvalueCutoff=0.05,qvalueCutoff=0.10)
####此时可以同时输出三种的 模式的结果，之后使用上面同样的方法可视化######


setwd("D:/RNA-seq/transcript_level/GO/")

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
  theme(axis.text=element_text(size=16, face="plain",color="black"),axis.title = element_text(size = 16)) +
  labs(title = "The Most Enriched GO Terms",vjust=0.5,hjust=0.5)+theme(plot.title = element_text(size = 18),legend.title=element_text(size=16),legend.text = element_text(size=16))+theme(panel.grid=element_blank())  #删去网格线
p
out_img(filename = "2most GO term",pic_width = 10,pic_height = 8)
write.csv(go_enrich_df,"all_GO_result.csv")

#########################  GO  end###########################

###################################id 转换已无必要##########################################
#转换entrezid id 到 gid，其实gid就是ncbi-geneid，kegg可以直接使用entrezid，即ncbi-geneid
# entrezid2gid <- bitr(target_gene_id,fromType = 'ENTREZID',toType = 'GID',OrgDb = 'maize')
# gid2kegg <- bitr_kegg(entrezid2gid[,2],fromType = 'ncbi-geneid',toType = 'ncbi-proteinid',organism = 'zma')
# g2kegg <- bitr_kegg(entrezid2gid[,2],fromType = 'ncbi-geneid',toType = 'uniprot',organism = 'zma')
# head(gid2kegg,100)
###################################id 转换结束##############################################


########kegg start  ##################
setwd("D:/RNA-seq/transcript_level/KEGG/")
kk <- enrichKEGG(gene = target_gene_id,organism ="zma",keyType = 'ncbi-geneid',pvalueCutoff = 0.1)
##kk2 <- bitr_kegg(kk$geneID,fromType = 'ncbi_proteinid',toType = 'ncbi-geneid',organism = 'zma')
write.csv(as.data.frame(kk@result),file="2kegg_all_result.csv")
write.csv(as.data.frame(kk),file = "2kegg_result.csv")
barplot(kk,title = "Enrichment KEGG",cex.axis=2,cex.lab=2,cex.main=2)#cex.axis设置坐标轴刻度字体大小，lab坐标轴名称字体大小，main标题大小
out_img(filename = "barplot_kegg",pic_width = 9,pic_height = 9)
dotplot(kk,showCategory=30,title="Enrichment KEGG",font.size=15)
out_img(filename = "2dot_kegg",pic_width = 8,pic_height = 7)
browseKEGG(kk,'zma00195')
browseKEGG(kk,'zma00196')
browseKEGG(kk,'zma04141')
browseKEGG(kk,'zma00640')

#转换id为entrezid即ncbi id，输出结果。
res_kk <- setReadable(kk,OrgDb = maize,keyType="ENTREZID")
write.csv(res_kk,file="rkk.csv")

###生成调控网络图
cnetplot(res_kk,categorySize="pvalue",foldChange = target_gene_id,font.size=17)
out_img(filename = "cnet_KK",pic_width = 12,pic_height = 12)
#生成圆形的网络图
cnetplot(res_kk,circular=TRUE,colorEdge=TRUE)
out_img(filename = "circularnet_KK",pic_width = 14,pic_height = 12)
write.csv(res_kk,file="kk_result.csv")





setwd("D:/RNA-seq/transcript_level/GSEA/")
#gsea需要单独做数据格式
d <- read.csv("all2entrez.csv")
geneList <- d[,2]
names(geneList)=as.factor(d[,1])
geneList <- sort(geneList,decreasing = TRUE)

#gseGO进行GSEA分析
#参考连接https://yulab-smu.github.io/clusterProfiler-book/chapter12.html
###gseBP <- gseGO(geneList=geneList,ont="BP",OrgDb=maize,keyType = 'ENTREZID',nPerm = 50000,minGSSize = 100,maxGSSize = 6000,pvalueCutoff = 0.05,verbose = FALSE)

############# GSEA CC 模式 start
setwd("D:/RNA-seq/transcript_level/GSEA/GO/CC/")
ego3 <- gseGO(geneList = geneList,OrgDb = maize,ont = "CC",nPerm = 1000,minGSSize = 15,maxGSSize = 500,pvalueCutoff = 0.05,verbose = FALSE)
write.csv(ego3,file = "GESA-GO_CC.csv")

rego3 <- setReadable(ego3,OrgDb = maize,keyType="ENTREZID")
write.csv(rego3,file="GSEA_rGO_cc.csv")
#ridgeline plot for expression distribution of GSEA result
ridgeplot(ego3)
out_img(filename = "2ridgeplot_CC",pic_width = 8,pic_height = 7)

####统计对应的生物学途径在pubmed的文章数量 start####
# terms <- ego3$Description[1:5]
# p2 <- pmcplot(terms,2015:2019,proportion = FALSE)
# p2
#out_img(filename = "vacuolar near 5 years ariticles",pic_width = 6,pic_height = 5)
# term2 <- ego3$Description[9:20]
# p3 <- pmcplot(term2,2015:2019,proportion = FALSE)
# p3
out_img(filename="Articles on Photosynthesis in the near 5 years",pic_width = 6,pic_height = 5)
########统计PubMed相关文章数量 end############

#显示所有的基因集富集的通路的基因的分布
heatplot(rego3,foldChange = geneList)
out_img(filename = "Allheatplot",pic_width = 18,pic_height = 8)

#显示前5条基因集分布
heatplot(rego3,foldChange = geneList,showCategory = 5)
out_img(file="vacuole",pic_width = 14,pic_height = 5)

#只显示值最高的一组的信息
#gseaplot(ego3,geneSetID = 1,by="runningScore",title=ego3$Description[1])
#gseaplot(ego3,geneSetID = 1,by="preranked",title=ego3$Description[1])
#gseaplot(ego3,geneSetID = 1,title=ego3$Description[1])

#生成GSEA的基因调控网络图
cnetplot(rego3,categorySize="pvalue",foldChange=geneList,font.size=18)
out_img(filename = "cnet_GSEA_CC",pic_width = 12,pic_height = 12)

#生成圆形的网络图
cnetplot(rego3,foldChange = geneList,layout = "kk",circular=TRUE,colorEdge=TRUE,node_label=TRUE)
out_img(filename = "circle_GSEA_CC",pic_width = 14,pic_height = 12)

#气泡图
dotplot(rego3,font.size=16,showCategory=20)
out_img(filename = "GSEA_dot_CC",pic_width = 12,pic_height = 12)
#浓缩图
emapplot(rego3,font.size=16,showCategory=30,color="pvalue")
out_img(filename = "2GSEA_emapplot_CC",pic_width = 8,pic_height = 8)



#显示前5组信息
gseaplot2(rego3,geneSetID = 1:5, ES_geom = "dot",pvalue_table = TRUE)
out_img(filename = "gseaplot_dot_CC",pic_width=8,pic_height = 7)


#显示第9-11组信息
gseaplot2(rego3,geneSetID = 8:11, ES_geom = "dot",pvalue_table = TRUE)
out_img(filename = "8-11gseaplot_dot_CC",pic_width=12,pic_height = 9)

#gseaplot2(ego3,geneSetID = 1:4,pvalue_table=TRUE)
#out_img(filename = "gseaplot_CC",pic_width=12,pic_height = 10)

#gsearank(ego3,1,title=ego3[1,"Description"])
############GSEA CC 模式end

############# GSEA BP 模式 start
setwd("D:/RNA-seq/transcript_level/GSEA/GO/BP/")
ego2 <- gseGO(geneList = geneList,OrgDb = maize,ont = "BP",nPerm = 1000,minGSSize = 15,maxGSSize = 500,pvalueCutoff = 0.05,verbose = FALSE)
write.csv(ego2,file = "GESA-GO_BP.csv")
rego2 <- setReadable(ego2,OrgDb = maize,keyType="ENTREZID")
write.csv(rego2,file="GSEA_rGO_BP.csv")
#ridgeline plot for expression distribution of GSEA result
ridgeplot(ego2)
out_img(filename = "ridgeplot_BP",pic_width = 12,pic_height = 12)
#只显示值最高的一组的信息
#gseaplot(ego3,geneSetID = 1,by="runningScore",title=ego3$Description[1])
#gseaplot(ego3,geneSetID = 1,by="preranked",title=ego3$Description[1])
#gseaplot(ego3,geneSetID = 1,title=ego3$Description[1])

#显示前4组信息
gseaplot2(ego2,geneSetID = 1:4, ES_geom = "dot",pvalue_table = TRUE)
out_img(filename = "gseaplot_BP",pic_width=12,pic_height = 10)

#gsearank(ego3,1,title=ego3[1,"Description"])
############GSEA BP 模式end

############# GSEA MF 模式 start
setwd("D:/RNA-seq/transcript_level/GSEA/GO/MF/")
ego4 <- gseGO(geneList = geneList,OrgDb = maize,ont = "MF",pvalueCutoff = 0.05,nPerm = 1000,minGSSize = 15,maxGSSize = 500,verbose = FALSE)
write.csv(ego4,file = "GESA-GO_MF.csv")
rego4 <- setReadable(ego4,OrgDb = maize,keyType="ENTREZID")
write.csv(rego4,file="GSEA_rGO_MF.csv")
#ridgeline plot for expression distribution of GSEA result
ridgeplot(ego4)
out_img(filename = "ridgeplot_MF",pic_width = 12,pic_height = 12)
#只显示值最高的一组的信息
#gseaplot(ego3,geneSetID = 1,by="runningScore",title=ego3$Description[1])
#gseaplot(ego3,geneSetID = 1,by="preranked",title=ego3$Description[1])
#gseaplot(ego3,geneSetID = 1,title=ego3$Description[1])

#显示前4组信息
gseaplot2(ego4,geneSetID = 1:4, ES_geom = "dot",pvalue_table = TRUE)
out_img(filename = "gseaplot_MF",pic_width=12,pic_height = 10)

#gsearank(ego3,1,title=ego3[1,"Description"])
############GSEA MF 模式end
##################GSEA GO 汇总 start
setwd("D:/RNA-seq/transcript_level/GSEA/")
go_GSEA <- read.csv("GO-GSEA.csv",header = TRUE)
MF_GO <- ego4
BP_GO <- ego2
CC_GO <- ego3

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
write.csv(go_enrich_df,"GSEA_all_GO_result.csv")

#################GSEA GO 汇总 end
#gsaKEGG基因富集分析
setwd("D:/RNA-seq/transcript_level/GSEA/KEGG/")
kk2 <- gseKEGG(geneList = geneList,keyType = 'ncbi-geneid',organism = 'zma',pvalueCutoff = 0.05,verbose = FALSE)
write.csv(kk2,file="GSEA_KEGG.csv")

gseaplot2(kk2,geneSetID = 1:4,ES_geom = "dot",pvalue_table = TRUE)
out_img(filename="GSEA_KEGG",pic_width = 12,pic_height = 10)
ridgeplot(kk2)
out_img(filename="ridgeplot_GSEA_KEGG",pic_width = 12,pic_height = 12)

browseKEGG(kk,'zma04120')



unique(hub$species[which(hub$species=="zea mays")])








#########测试从本地读取生成柱形图 start###############################

gseacount <- data.frame(genenumber=c(go_GSEA$ID),genecount=c(go_GSEA$Count),godescription=c(go_GSEA$Description),type=factor(c(rep("molecular function",display_number[1]),rep("biological process",display_number[2]),rep("cellular component",display_number[3])),levels = c("molecular function","biological process","cellular component")))
gseacount$number <- factor(rev(1:nrow(gseacount)))
###colors for bar // green, blue, orange
CPCOLS <- c("#43c3a4", "#f88f61", "#85a1cf")
gseacount$levels <-factor("molecular function","biological process","cellular component")
labels=(sapply(
  levels(gseacount$Description)[as.numeric(gseacount$Description)],
  shorten_names))
names(labels) = rev(1:nrow(gseacount))

ggplot(gseacount,aes(x=number,y=genenumber,fill=type))+geom_bar(stat="identity" , width=0.8, position = "dodge")+coord_flip() +
  scale_color_manual(values= CPCOLS) + theme_bw() +
  scale_x_discrete(labels=labels)+
  xlab("GO term") + 
  theme(axis.text=element_text(size=12, face="plain",color="black")) +
  labs(title = "GSEA Enriched GO Terms",vjust=0.5,hjust=0.5)+theme(panel.grid=element_blank()) 
  
    
ggplot(data=gseacount, aes(x=number, y=genenumber, fill=type)) +
  geom_bar(stat="identity", width=0.8) + coord_flip() + 
  scale_fill_manual(values= CPCOLS) + theme_bw() + 
  scale_x_discrete(labels=labels) +
  xlab("GO term") + 
  theme(axis.text=element_text(size=12, face="plain",color="black")) +
  labs(title = "The Most Enriched GO Terms",vjust=0.5,hjust=0.5)+theme(panel.grid=element_blank())  #删去网格线

go_enrich_df <- data.frame(ID=c(MF_GO$ID,BP_GO$ID,CC_GO$ID),Description=c(MF_GO$Description,BP_GO$Description,CC_GO$Description),GeneNumber=c(MF_GO$Count,BP_GO$Count,CC_GO$Count),type=factor(c(rep("molecular function",display_number[1]),rep("biological process",display_number[2]),rep("cellular component",display_number[3])),levels = c("molecular function","biological process","cellular component")))
#x轴数据


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

##测试从本地生成柱形图  end############

##########################转录因子富集分析start
setwd("D:/RNA-seq/transcript_level/TF/TF/")
#读取差异表达的基因id
#degs1 <- read.csv("deg_geneid.csv")
#degs1 <- as.factor(degs[,1])
degs1 <- read.csv("degs2fc2.csv")
degs1 <- as.factor(degs[,1])


degs <- read.csv("degs2fc2.csv")
geneList = degs[,2]
names(geneList)=as.character(degs[,1])
geneList <- sort(geneList,decreasing = TRUE)

#读取所有在样本中表达的基因的转录因子ID和基因id
term2gene <- read.csv("expressionidTF2geneid.csv",header = FALSE)

#获取转录因子ID和名字对应的文件
term2name <- read.csv("zeamaysTFID2TF.csv",header = FALSE)


tf <- enricher(degs1,TERM2GENE=term2gene,TERM2NAME=term2name,minGSSize = 1)
tf_gsea <- GSEA(geneList,TERM2GENE =term2gene,TERM2NAME = term2name,verbose = FALSE)
head(tf_gsea)
dotplot(tf_gsea,showCategory=20)
write.csv(tf,"enricher TF results.csv")





##########################转录因子富集分析end



#####wikiPathways分析start####
####wikipathways分析在玉米中的数据库并不完善，本次分析的数据在数据库中没有合适的pathway，故不进行分析。
####zea mays.gmt需要从https://www.wikipathways.org/index.php/Download_Pathways选择对应的物种下载数据库
# if(!"rWikiPathways" %in% installed.packages()){
#        if (!requireNamespace("BiocManager", quietly = TRUE))
#            install.packages("BiocManager")
#        BiocManager::install("rWikiPathways", update = FALSE)
#    }
# library(rWikiPathways)
# library(magrittr)
# 
# #wpgmtfile <- downloadPathwayArchive(organism ="Zea mays",format ='gmt')
# 
# 
# gene <- names(geneList)[abs(geneList)>2]
# wpgmtfile <- system.file("extdata/zea mays.gmt", package="clusterProfiler")
# wp2gene <- read.gmt(wpgmtfile)
# wp2gene <- wp2gene %>% tidyr::separate(ont, c("name","version","wpid","org"), "%")
# wpid2gene <- wp2gene %>% dplyr::select(wpid, gene) #TERM2GENE
# wpid2name <- wp2gene %>% dplyr::select(wpid, name) #TERM2NAME
# 
# ewp <- enricher(gene, TERM2GENE = wpid2gene, TERM2NAME = wpid2name)
# head(ewp)
# 
# ewp2 <- GSEA(geneList, TERM2GENE = wpid2gene, TERM2NAME = wpid2name, verbose=FALSE)
# head(ewp2)
# 
# ###将geneid从ncbi ID转换回maizegdb ID
# library(org.Hs.eg.db)
# ewp <- setReadable(ewp, org.Hs.eg.db, keyType = "ENTREZID")
# ewp2 <- setReadable(ewp2, org.Hs.eg.db, keyType = "ENTREZID")
# head(ewp)


########wikipathways分析end############


########转录因子聚类分析########
# 安装包并加载包
# 使用k-means聚类所需的包：factoextra和cluster 
site="https://mirrors.tuna.tsinghua.edu.cn/CRAN"
package_list = c("factoextra","cluster")
for(p in package_list){
  if(!suppressWarnings(suppressMessages(require(p, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)))){
    install.packages(p, repos=site)
    suppressWarnings(suppressMessages(library(p, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)))
  }
}
# 数据准备
# 使用内置的R数据集USArrests
data("USArrests")
# remove any missing value (i.e, NA values for not available)
USArrests = na.omit(USArrests) #view the first 6 rows of the data
head(USArrests, n=6) 
# 显示测试数据示例如下
# 在聚类之前我们可以先进行一些必要的数据检查即数据描述性统计，如平均值、标准差等
desc_stats = data.frame( Min=apply(USArrests, 2, min),#minimum
                         Med=apply(USArrests, 2, median),#median
                         Mean=apply(USArrests, 2, mean),#mean
                         SD=apply(USArrests, 2, sd),#Standard deviation
                         Max=apply(USArrests, 2, max)#maximum
)
desc_stats = round(desc_stats, 1)#保留小数点后一位head(desc_stats)
desc_stats
# 变量有很大的方差及均值时需进行标准化
df = scale(USArrests)

# 数据集群性评估，使用get_clust_tendency()计算Hopkins统计量
res = get_clust_tendency(df, 40, graph = TRUE)
res$hopkins_stat
set.seed(123)
## Compute the gap statistic
gap_stat = clusGap(df, FUN = kmeans, nstart = 25, K.max = 10, B = 500)
# Plot the result
fviz_gap_stat(gap_stat)

在线分析结果
#http://bioinformatics.cau.edu.cn/MCENet/GSEA/GSEAresult.php?session=gsea2019Jul23100955
#http://bioinformatics.cau.edu.cn/MCENet/GSEA/GSEAresult.php?session=gsea2019Jul23100529

##############转录因子聚类分析############



###转录因子数据出图#######
setwd("D:/RNA-seq/transcript_level/TF/")
tf <- read.csv("TF_enrichresult.csv")
library(dplyr)
library(ggplot2)
df <- data.frame(value = tf$Overlap.k.,Group = tf$Gene.Set.Name)

blank_theme <- theme_minimal()+
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    panel.border = element_blank(),
    panel.grid=element_blank(),
    axis.ticks = element_blank(),
    plot.title=element_text(size=14, face="bold")
  )

ggplot(data=df, mapping=aes(x="Group",y=value,fill=Group))+
  geom_bar(stat="identity",width=0.8,size=5)+
  coord_polar("y", start=0)+
  #scale_fill_manual(values = c("#999999", "#E69F00", "#56B4E9"))
  blank_theme +
   geom_text(stat="identity",aes(y=value,x=1,label = scales::percent(value/100)),size=3,position=position_stack(vjust = 0.5))


# B <- tf$Gene.Set.Name
# A <- tf$Overlap.k.
# dt <- data.frame(A,B)
# dt = dt[order(dt$A, decreasing = TRUE),]
# myLabel = as.vector(dt$B)   
# myLabel = paste(myLabel, "(", round(dt$A / sum(dt$A) * 100, 2), "%)", sep = "")   
# 
# ggplot(dt, aes(x = "", y = A, fill = B)) +
#   geom_bar(stat = "identity", width = 1) +    
#   coord_polar(theta = "y") + 
#   labs(x = "", y = "", title = "") + 
#   theme(axis.ticks = element_blank()) + 
#   theme(legend.title = element_blank(), legend.position = "top") + 
#   scale_fill_discrete(breaks = dt$B, labels = myLabel) + 
#   theme(axis.text.x = element_blank()) + 
#   geom_text(aes(y = A/2 + c(0, cumsum(A)[-length(A)]), x = sum(A)/20, label = myLabel), size = 5)



          

######转录因子数据出图##########


