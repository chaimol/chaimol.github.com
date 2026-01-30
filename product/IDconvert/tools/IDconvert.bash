#!/bin/bash
#用于获取脚本所在的路径，保存为变量path1,调用其他脚本都依赖这个路径。
path1="$(cd "$(dirname ${BASH_SOURCE[0]})";pwd)"
#此程序是主程序，运行此程序会调用其他脚本。

# 用法说明
usage() {
    echo "Usage:  $0 [OPTIONS]"
    echo "作用是找到不同版本基因组之间的对应同源基因，使用diamond比对。"
    echo "Options:"
    echo "  -r, --ref-abbr        Reference species abbreviation (e.g., N244)"
    echo "  -q, --query-abbr      Query species abbreviation (e.g., TM_1.CRI)"
    echo "  --ref-protein         Reference protein file (default: <ref_abbr>.pep)"
    echo "  --query-protein       Query protein file (default: <query_abbr>.pep)"
    echo "  --ref-str             Separator for reference transcript IDs (default: '.')"
    echo "  --query-str           Separator for query transcript IDs (default: '.')"
    echo "  -t, --threads         Number of threads (default: 24)"
    echo "  -n, --target-num      Number of best matches to output (default: 1)"
    echo "  -m, --mate            Minimum identity percentage (default: 90)"
    echo "  -w, --workpath        Working directory (default: current directory)"
    echo "  -h, --help            Show this help message"
    echo
    echo "Example:"
    echo "   $0 -r N244 -q TM_1.CRI --ref-protein N244.pep --query-protein TM_1.CRI.pep"
    exit 1
}

# 默认参数
ref_abbr=""
query_abbr=""
ref_protein=""
query_protein=""
ref_str="."
query_str="."
threads=24
target_num=1
mate=90
workpath="."

# 解析命令行参数
while [[  $# -gt 0 ]]; do
    case  $1 in
        -r|--ref-abbr)
            ref_abbr="$2"; shift 2 ;;
        -q|--query-abbr)
            query_abbr="$2"; shift 2 ;;
        --ref-protein)
            ref_protein="$2"; shift 2 ;;
        --query-protein)
            query_protein="$2"; shift 2 ;;
        --ref-str)
            ref_str="$2"; shift 2 ;;
        --query-str)
            query_str="$2"; shift 2 ;;
        -t|--threads)
            threads="$2"; shift 2 ;;
        -n|--target-num)
            target_num="$2"; shift 2 ;;
        -m|--mate)
            mate="$2"; shift 2 ;;
        -w|--workpath)
            workpath="$2"; shift 2 ;;
        -h|--help)
            usage ;;
        *)
            echo "Unknown option: $1" >&2
            usage ;;
    esac
done

# 必填参数检查
if [[ -z "$ref_abbr" ]] || [[ -z "$query_abbr" ]]; then
    echo "Error: --ref-abbr and --query-abbr are required." >&2
    usage
fi

# 设置默认蛋白文件名（如果未提供）
[[ -z "$ref_protein" ]] && ref_protein="${ref_abbr}.pep"
[[ -z "$query_protein" ]] && query_protein="${query_abbr}.pep"

# 切换工作目录
cd "$workpath" || { echo "Error: Cannot change to workpath '$workpath'"; exit 1; }

# 软件路径（请根据实际情况修改或通过环境变量配置）
seqkit="/share/home/chaimao1/soft/LTRfind/LTRfind/seqkit"
getLongProteins="/share/home/chaimao1/soft/Dupfind/getLongProteins.py"
diamond="/share/home/chaimao1/soft/diamond/diamond"

# 函数：准备最长转录本蛋白文件
prepare_pep() {
    local abbr="$1"
    local pep="$2"
    local str="$3"
    ${seqkit} seq -i "$pep" > "${abbr}.pep.fa" || { echo "Error running seqkit"; exit 1; }
    python3 ${getLongProteins} "${abbr}.pep.fa" "${abbr}.pep" "$str" || { echo "Error running getLongProteins.py"; exit 1; }
    sed -i 's/\.$//g' "${abbr}.pep"
    rm -f "${abbr}.pep.fa"
}

# 函数：构建 DIAMOND 数据库
makedatabase() {
    local abbr="$1"
    local pep="$2"
    if [[ -e "${abbr}.dmnd" ]]; then
        echo "Database index ${abbr}.dmnd already exists. Skipping."
    else
        ${diamond} makedb --db "$abbr" --in "$pep" || { echo "Error building DIAMOND database"; exit 1; }
    fi
}

# 函数：DIAMOND 比对
blastpep() {
    local abbr1="$1"
    local abbr2="$2"
    local pep2="$3"
    local target_num="$4"
    local threads="$5"
    local mate="$6"
    ${diamond} blastp \
        --query "$pep2" \
        --db "$abbr1" \
        --out "${abbr2}.${abbr1}.tsv" \
        --threads "$threads" \
        --outfmt 6 qseqid sseqid pident evalue bitscore \
        --max-target-seqs "$target_num" \
        --id "$mate" 
#        --evalue 1e-50 \ 此处不使用evalue过滤
}

# 主流程
# 处理参考蛋白
if [[ -e "${ref_abbr}.pep" ]]; then
    echo "Found existing ${ref_abbr}.pep, skipping preparation."
else
    prepare_pep "$ref_abbr" "$ref_protein" "$ref_str"
fi
#删除序列中的不是氨基酸的字符
sed -i '/^>/! s/[^ACDEFGHIKLMNPQRSTVWY*]//g' ${ref_abbr}.pep


# 处理查询蛋白
if [[ -e "${query_abbr}.pep" ]]; then
    echo "Found existing ${query_abbr}.pep, skipping preparation."
else
    prepare_pep "$query_abbr" "$query_protein" "$query_str"
fi
#删除序列中的不是氨基酸的字符
sed -i '/^>/! s/[^ACDEFGHIKLMNPQRSTVWY*]//g' ${query_abbr}.pep

# 构建数据库
makedatabase "$ref_abbr" "${ref_abbr}.pep"

# 执行比对
blastpep "$ref_abbr" "$query_abbr" "${query_abbr}.pep" "$target_num" "$threads" "$mate"

echo "Analysis completed. Output: ${query_abbr}.${ref_abbr}.tsv"

# 输出1对1的匹配结果
awk '
{
    query = $1
    subject = $2
    bitscore = $5

    # 从 query 提取染色体 (如 Gh_A01G... -> A01)
    if (query ~ /_([AD][0-9]{2})G/) {
        q_chr = substr(query, RSTART+1, RLENGTH-2)
    } else {
        q_chr = "UNKNOWN"
    }

    # 从 subject 提取染色体 (如 GhN244A01G... -> A01)
    if (subject ~ /([AD][0-9]{2})G/) {
        s_chr = substr(subject, RSTART, RLENGTH-1)
    } else {
        s_chr = "UNKNOWN"
    }

    is_same_chr = (q_chr == s_chr)

    # 初始化或更新：优先同染色体，其次高 bitscore
    if (!(query in best_bitscore)) {
        best_bitscore[query] = bitscore
        best_line[query] = $0
        best_is_same[query] = is_same_chr
    } else {
        current_is_same = best_is_same[query]
        current_bitscore = best_bitscore[query]

        # 决策逻辑：
        # 1. 如果当前是同染色体，而已有不是 → 替换
        # 2. 如果都是同染色体（或都不是），则比 bitscore
        if ( (is_same_chr && !current_is_same) ||
             (is_same_chr == current_is_same && bitscore > current_bitscore) ) {
            best_bitscore[query] = bitscore
            best_line[query] = $0
            best_is_same[query] = is_same_chr
        }
    }
}
END {
    for (q in best_line) print best_line[q]
}' "${query_abbr}.${ref_abbr}.tsv" | sort -k1|cut -f1-2 > "${query_abbr}.${ref_abbr}.xls"
echo "1对1的匹配结果文件是${query_abbr}.${ref_abbr}.xls"

#把输出的结果转为json格式 用法说明：参数1是2列基因id对应文件 参数2是输出json 参数3是第1列缩写字符串 参数4是第2列的缩写字符串
python3 ${path1}/id2json.py ${query_abbr}.${ref_abbr}.xls ${query_abbr}_${ref_abbr}.json ${query_abbr} ${ref_abbr}