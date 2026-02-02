##这个程序是生成棉花的基因组对应id关系时使用的原始命令
cd /share/home/chaimao1/database/Zeamays

#B73V4 V5转换
bsub -q normal -n 24 -o r.out -e r.err IDconvert.bash -q B73V4 -r B73V5 --query-protein B73V4.pep --ref-protein B73V5.pep -n 2 -m 80

#删除每个基因的后面的转录本的符号，只保留基因id
awk '{
    # 处理第一列：按_分割，取第一个字段
    split($1, a, "_"); col1 = a[1];
    # 处理第二列：按_分割，取第一个字段
    split($2, b, "_"); col2 = b[1];
    # 输出处理后的两列（用制表符分隔，也可改空格）
    print col1 "\t" col2
}' B73V4.B73V5.xls >B73V4_V5.xls
#把输出的基因对转为json,用于数据库读取
python3 ~/soft/IDconvert/id2json.py B73V4_V5.xls B73V4_V5.json B73V4 B73V5

