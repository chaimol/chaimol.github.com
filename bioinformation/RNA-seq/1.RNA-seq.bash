#!/bin/bash

##处理RNA-seq的数据

#复制下机数据到新的文件夹data ,尽量避免操作原始文件~/disk/lyb/
find ./Cleandata -name '*fq.gz'|xargs -i cp {} ./data
 
#1.质控 ~/disk/lyb/data/

fastqc *.fq.gz -t 8 &

bg1='RNA_R1.fq.gz'
bg2='RNA_R2.fq.gz'
bef=(NS-1 NS-2 NS-3 WT-1 WT-2 WT-3)
for ((i=0;i<6;i++));
do

inA1=${bef[$i]}$bg1;
inA2=${bef[$i]}$bg2;
out1=${bef[$i]}"paired-R1.fq.gz";
out2=${bef[$i]}"paired-R2.fq.gz";
unpaired1=${bef[$i]}"unpaired-R1.fq.gz";
unpaired2=${bef[$i]}"unpaired-R2.fq.gz";
java -jar /home/guo/tool/Trimmomatic-0.38/trimmomatic-0.38.jar PE -threads 12 -phred33 $inA1 $inA2 $out1 $unpaired1 $out2 $unpaired2 ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 &
#echo $inA1,$inA2,$out1,$out2,$unpaired1,$unpaired2;




hisat2 -x /disks/backup/chaim/maize/genome_tran -p 16 -1 $out1 -2 $out2 -S ${bef[$i]}".map.sam" --dta-cufflinks --novel-splicesite-outfile ${bef[$i]}".nsplice" 2>${bef[$i]}"hisat2_out" &	

samtools sort -@ 8 -o ${bef[$i]}".map.bam" ${bef[$i]}".map.sam" 2>${bef[$i]}"samtool_out" &
stringtie ${bef[$i]}".map.bam" -G /disks/backup/chaim/maize/Zea_mays.B73_RefGen_v4.42.gtf -p 8 -o ${bef[$i]}".gtf" 2>${bef[$i]}"stringtie_first" &

stringtie --merge -G /disks/backup/chaim/maize/Zea_mays.B73_RefGen_v4.42.gtf -p 8 -o merged.gtf NS-1.gtf NS-2.gtf NS-3.gtf WT-1.gtf WT-2.gtf WT-3.gtf 2>stringtie_merge
mkdir ${bef[$i]}"_out"
stringtie ${bef[$i]}".map.bam" -G merged.gtf -p 8 -b ${bef[$i]}"_out" -e -o ${bef[$i]}"-st.gtf" &

done


