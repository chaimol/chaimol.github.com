# IDconvert.bash是一个用于自动查找不同版本参考基因组的同源基因的流程

# 依赖软件

+ getLongproteins.py 可以下载[getLongerSequences.py](https://github.com/chaimol/KK4D/blob/main/getLongerSequences.py)重命名为getLongProteins.py即可
+ diamond 直接安装或conda安装都行

默认依赖软件的安装地址是在~/soft/getLongproteins.py和~/soft/diamond/diamond,注意修改IDconvert.bash里这2个文件地址为正确地址。

# 输入参数说明

|参数|参数的内容|
|---|---|
|`-r`或`--ref-abbr`			|参考的物种基因组版本缩写|
|`-q`或`--query-abbr`		|查询的物种的基因组版本缩写|
|`--ref-protein`			|参考蛋白文件|
|`--query-protein`			|查询蛋白文件|
|`--ref-str`        |参考物种的默认的不同转录本的区分的分割字符串，默认是`.`|
|`--query-str`      |查询物种的默认的不同转录本的区分的分割字符串，默认是`.`|
|`-t`或`--threads`    |线程数量，默认是24|
|`-n`或`--target-num` |输出的最佳匹配数量，默认是1|
|`-m`或`--mate` |序列匹配最低相似度，默认是90，即最低相似度是90%|
|`-w`或`--workpath` |工作路径，默认是当前路径|
|`-h`或`--help` |输出帮助信息|

# 用法
- 直接使用默认参数运行
`bash IDconvert.bash -r N244 -q TM_1.CRI --ref-protein N244.proteins --query-protein TM_1.CRI.protein`

- 手动指定输出的匹配数量为2个
`bash IDconvert.bash -r N244 -q TM_1.CRI --ref-protein N244.pep.fa --query-protein TM_1.CRI.pep.fa -n 2`

- 指定使用的线程数量
`bash IDconvert.bash -r N244 -q TM_1.CRI --ref-protein N244.pep.fa --query-protein TM_1.CRI.pep.fa -n 2 -t 16`

- 指定最低匹配度
`bash IDconvert.bash -r N244 -q TM_1.CRI --ref-protein N244.pep.fa --query-protein TM_1.CRI.pep.fa -m 85 -t 16`

- 指定参考物种的不同转录本的分割字符串
`bash IDconvert.bash -r N244 -q TM_1.CRI --ref-protein N244.pep.fa --query-protein TM_1.CRI.pep.fa -n 2 -t 16 --ref-str .`

# 注意

- 如果输入的蛋白文件格式是`${abbr}.pep`,那么就不再检查基因序列获取每个基因的最长转录本了。
比如输入是 `-r N244 -q TM_1.CRI --ref-protein N244.pep --query-protein TM_1.CRI.pep`，这种情况下，就之间使用输入的蛋白文件进行比对了，不会再去找每个基因最长转录本。

- 如果存在对应`${ref_abbr}.dmnd`这个数据库文件，就不会再重新创建了。

- 如果物种之间亲缘关系远或某个版本组装比较差，可以适当降低-m的参数值，否则输出的匹配的基因数量会很少。

# 输出文件
- `${query_abbr}.${ref_abbr}.tsv` 这个是基因对之间的对应关系，用户指定最多匹配n个，就是n个。这是最全的结果。
- `${query_abbr}.${ref_abbr}.xls` 这是基因对之间的1对1的关系。
- `${query_abbr}.${ref_abbr}.json` 这是根据1对1生成的json文件，把这个文件放置到`../data/genome/`目录里，再修改`../index.html`页面里新增这个json的option即可在线使用搜索。