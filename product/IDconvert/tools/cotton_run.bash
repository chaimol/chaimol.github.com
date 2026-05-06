##这个程序是生成棉花的基因组对应id关系时使用的原始命令
cd /share/home/chaimao1/cotton/GeneIDconvert
IDconvertAD.bash N244 N244.pep GhN244A GhN244D
IDconvertAD.bash TM_1_CRI TM_1_CRI.pep Gh_A Gh_D
IDconvertAD.bash TM_1.ZJUV_2.1 TM_1.ZJUV_2.1.pep GH_A GH_D
IDconvertAD.bash ZM113T2T ZM113T2T.pep Ghir_A Ghir_D
IDconvertAD.bash TM-1.HAU_V1.1 TM-1.HAU_V1.1.pep Ghir_A Ghir_D
IDconvertAD.bash Ghicr24 ZM24.pep Ghicr24_A Ghicr24_D
IDconvertAD.bash 3-79.HAU_V2 AD2_HAUV2.pep Gbar_A Gbar_D
IDconvertAD.bash Pima90 Pima90.pep GbM_A GbM_D

# 


#以N244为参考
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q TM_1_CRI.A -r N244.A --query-protein TM_1_CRI.A.pep --ref-protein N244.A.pep -n 2 -m 85
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q TM_1_CRI.D -r N244.D --query-protein TM_1_CRI.D.pep --ref-protein N244.D.pep -n 2 -m 85
cat TM_1_CRI.A.N244.A.xls TM_1_CRI.D.N244.D.xls >TM_1_CRI_N244.xls
python3 id2json.py TM_1_CRI_N244.xls TM_1_CRI_N244.json CRI N244

bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q TM_1.ZJUV_2.1.A -r N244.A --query-protein TM_1.ZJUV_2.1.A.pep --ref-protein N244.A.pep -n 2 -m 85
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q TM_1.ZJUV_2.1.D -r N244.D --query-protein TM_1.ZJUV_2.1.D.pep --ref-protein N244.D.pep -n 2 -m 85
cat TM_1.ZJUV_2.1.A.N244.A.xls TM_1.ZJUV_2.1.D.N244.D.xls >TM_1.ZJUV_2.1_N244.xls
python3 id2json.py TM_1.ZJUV_2.1_N244.xls TM_1_ZJUV_2_N244.json ZJUV2 N244

bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q ZM113T2T.A -r N244.A --query-protein ZM113T2T.A.pep --ref-protein N244.A.pep -n 2 -m 85
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q ZM113T2T.D -r N244.D --query-protein ZM113T2T.D.pep --ref-protein N244.D.pep -n 2 -m 85
cat ZM113T2T.A.N244.A.xls ZM113T2T.D.N244.D.xls >ZM113T2T_N244.xls
python3 id2json.py ZM113T2T_N244.xls ZM113T2T_N244.json ZM113T2T N244


####以TM-1 CRI为参考
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q Ghicr24.A -r TM_1_CRI.A --query-protein Ghicr24.A.pep --ref-protein TM_1_CRI.A.pep -n 2 -m 85
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q Ghicr24.D -r TM_1_CRI.D --query-protein Ghicr24.D.pep --ref-protein TM_1_CRI.D.pep -n 2 -m 85
cat Ghicr24.A.TM_1_CRI.A.xls Ghicr24.D.TM_1_CRI.D.xls >Ghicr24.TM_1_CRI.xls
python3 id2json.py Ghicr24.TM_1_CRI.xls ZM24_TM_1_CRI.json ZM24 CRI


bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q TM_1.ZJUV_2.1.A -r TM_1_CRI.A --query-protein TM_1.ZJUV_2.1.A.pep --ref-protein TM_1_CRI.A.pep -n 2 -m 85
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q TM_1.ZJUV_2.1.D -r TM_1_CRI.D --query-protein TM_1.ZJUV_2.1.D.pep --ref-protein TM_1_CRI.D.pep -n 2 -m 85
cat TM_1.ZJUV_2.1.A.TM_1_CRI.A.xls TM_1.ZJUV_2.1.D.TM_1_CRI.D.xls >TM_1.ZJUV_2.1_TM_1_CRI.xls
python3 id2json.py TM_1.ZJUV_2.1_TM_1_CRI.xls TM_1_ZJUV_2_TM_1_CRI.json ZJUV2 CRI

bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q ZM113T2T.A -r TM_1_CRI.A --query-protein ZM113T2T.A.pep --ref-protein TM_1_CRI.A.pep -n 2 -m 85
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q ZM113T2T.D -r TM_1_CRI.D --query-protein ZM113T2T.D.pep --ref-protein TM_1_CRI.D.pep -n 2 -m 85
cat ZM113T2T.A.TM_1_CRI.A.xls ZM113T2T.D.TM_1_CRI.D.xls >ZM113T2T_TM_1_CRI.xls
python3 id2json.py ZM113T2T_TM_1_CRI.xls ZM113T2T_TM_1_CRI.json ZM113T2T CRI

bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q TM-1.HAU_V1.1.A -r TM_1_CRI.A --query-protein TM-1.HAU_V1.1.A.pep --ref-protein TM_1_CRI.A.pep -n 2 -m 85
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q TM-1.HAU_V1.1.D -r TM_1_CRI.D --query-protein TM-1.HAU_V1.1.D.pep --ref-protein TM_1_CRI.D.pep -n 2 -m 85
cat TM-1.HAU_V1.1.A.TM_1_CRI.A.xls TM-1.HAU_V1.1.D.TM_1_CRI.D.xls >TM-1.HAU_V1.1_TM_1_CRI.xls
python3 id2json.py TM-1.HAU_V1.1_TM_1_CRI.xls TM-1.HAU_V1.1_TM_1_CRI.json HAU_V1 CRI


#Jin668_T2T 和N244, ZM113T2T相互转换
IDconvertAD.bash Jin668_T2T Jin668_T2T.pep Ghjin_A Ghjin_D

bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q Jin668_T2T.A -r N244.A --query-protein Jin668_T2T.A.pep --ref-protein N244.A.pep -n 2 -m 85
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q Jin668_T2T.D -r N244.D --query-protein Jin668_T2T.D.pep --ref-protein N244.D.pep -n 2 -m 85
cat Jin668_T2T.A.N244.A.xls Jin668_T2T.D.N244.D.xls >Jin668_T2T_N244.xls
python3 id2json.py Jin668_T2T_N244.xls Jin668_T2T_N244.json Jin668_T2T N244

bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q Jin668_T2T.A -r ZM113T2T.A --query-protein Jin668_T2T.A.pep --ref-protein ZM113T2T.A.pep -n 2 -m 85
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q Jin668_T2T.D -r ZM113T2T.D --query-protein ZM113T2T.D.pep --ref-protein ZM113T2T.D.pep -n 2 -m 85
cat Jin668_T2T.A.ZM113T2T.A.xls Jin668_T2T.D.ZM113T2T.D.xls >Jin668_T2T_ZM113T2T.xls
python3 id2json.py Jin668_T2T_ZM113T2T.xls Jin668_T2T_ZM113.json Jin668_T2T ZM113T2T


IDconvertAD.bash TM-1_T2T TM-1-T2T.pep GhChrA GhChrD
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q TM-1_T2T.A -r N244.A --query-protein TM-1_T2T.A.pep --ref-protein N244.A.pep -n 2 -m 85
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q TM-1_T2T.D -r N244.D --query-protein TM-1_T2T.D.pep --ref-protein N244.D.pep -n 2 -m 85
cat TM-1_T2T.A.N244.A.xls TM-1_T2T.D.N244.D.xls >TM-1_T2T_N244.xls
python3 id2json.py TM-1_T2T_N244.xls TM-1_T2T_N244.json TM-1_T2T N244


bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q D5_T2T -r N244.D --query-protein D5_T2T.pep --ref-protein N244.D.pep -n 2 -m 85
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q D5_T2T -r N244.A --query-protein D5_T2T.pep --ref-protein N244.A.pep -n 2 -m 85

##TM-1 T2T ZJU 和3-79 HAU V2之间进行转换
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q TM-1_T2T.A -r 3-79.HAU_V2.A --query-protein TM-1_T2T.A.pep --ref-protein 3-79.HAU_V2.A.pep -n 2 -m 85
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q TM-1_T2T.D -r 3-79.HAU_V2.D --query-protein TM-1_T2T.D.pep --ref-protein 3-79.HAU_V2.D.pep -n 2 -m 85
cat TM-1_T2T.A.3-79.HAU_V2.A.xls TM-1_T2T.D.3-79.HAU_V2.D.xls >TM-1_T2T_3-79.HAU_V2.xls
python3 id2json.py TM-1_T2T_3-79.HAU_V2.xls TM-1_T2T_3-79.HAU_V2.json TM-1_T2T 3-79.HAU_V2

##2个海岛棉之间转换
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q Pima90.A -r 3-79.HAU_V2.A --query-protein Pima90.A.pep --ref-protein 3-79.HAU_V2.A.pep -n 2 -m 85
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q Pima90.D -r 3-79.HAU_V2.D --query-protein Pima90.D.pep --ref-protein 3-79.HAU_V2.D.pep -n 2 -m 85
cat Pima90.A.3-79.HAU_V2.A.xls Pima90.D.3-79.HAU_V2.D.xls >Pima90_3-79.HAU_V2.xls
python3 id2json.py Pima90_3-79.HAU_V2.xls Pima90_3-79.HAU_V2.json Pima90 3-79.HAU_V2

