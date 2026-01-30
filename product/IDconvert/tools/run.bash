IDconvertAD.bash N244 N244.pep GhN244A GhN244D
IDconvertAD.bash TM_1_CRI TM_1_CRI.pep Gh_A Gh_D
IDconvertAD.bash TM_1.ZJUV_2.1 TM_1.ZJUV_2.1.pep GH_A GH_D
IDconvertAD.bash ZM113T2T ZM113T2T.pep Ghir_A Ghir_D
IDconvertAD.bash TM-1.HAU_V1.1 TM-1.HAU_V1.1.pep Ghir_A Ghir_D


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
