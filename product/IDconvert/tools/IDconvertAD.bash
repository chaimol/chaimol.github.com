#!/bin/bash
set -euo pipefail
# set选项说明：
# -e 命令执行失败则脚本立即退出
# -u 引用未定义变量则脚本立即退出
# -o pipefail 管道中任一命令失败则整个管道返回失败

# ===================== 颜色日志函数（可选，提升可读性）=====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 恢复默认颜色
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ===================== 核心参数校验（必加，保证脚本健壮性）=====================
# 检查传入参数数量是否为4个
if [ $# -ne 4 ]; then
    error "参数数量错误！请按以下格式执行脚本：
    bash 本脚本名.sh <基因前缀(如N244)> <pep文件路径(如N244.pep)> <A亚组前缀(如GhN244A)> <D亚组前缀(如GhN244D)>
    示例：bash script.sh N244 N244.pep GhN244A GhN244D"
fi

# 接收传入参数并赋值（增加变量注释，提升可读性）
abbr="$1"          # 基因核心前缀，如N244
abbr_pep="$2"      # 输入的pep文件路径/名称，如N244.pep
A_str="$3"         # A亚组行首匹配串，如GhN244A
D_str="$4"         # D亚组行首匹配串，如GhN244D

# 检查输入的pep文件是否存在且非空
if [ ! -f "$abbr_pep" ]; then
    error "输入的pep文件不存在！路径：$abbr_pep"
fi
if [ ! -s "$abbr_pep" ]; then
    error "输入的pep文件为空！路径：$abbr_pep"
fi

# ===================== 主流程执行（增加日志提示）=====================
info "开始执行脚本，基因前缀：$abbr，输入pep文件：$abbr_pep"
info "第一步：从pep文件提取geneid，生成${abbr}.geneid"
seqkit seq -i -n "$abbr_pep" >"${abbr}.geneid"

info "第二步：按行首匹配拆分A/D亚组geneid"
# 字符串匹配：index($0,匹配串)==1 严格匹配行首（非正则，无特殊字符问题）
awk -v a="$A_str" 'index($0,a)==1' "${abbr}.geneid" >"${abbr}.A.geneid"
awk -v d="$D_str" 'index($0,d)==1' "${abbr}.geneid" >"${abbr}.D.geneid"
# 过滤非A/D亚组的scaffold geneid
awk -v a="$A_str" -v d="$D_str" 'index($0,a)!=1 && index($0,d)!=1' "${abbr}.geneid" >"${abbr}.scaffold.geneid"

# 检查拆分后的geneid文件是否为空（可选，给出警告）
for file in "${abbr}.A.geneid" "${abbr}.D.geneid" "${abbr}.scaffold.geneid"; do
    if [ ! -s "$file" ]; then
        warn "文件$file为空，可能是匹配串$A_str/$D_str无匹配结果"
    fi
done

info "第三步：合并亚组并提取对应pep序列"
# 合并A亚组+scaffold，提取对应pep
seqkit grep -f <(cat "${abbr}.A.geneid" "${abbr}.scaffold.geneid") "$abbr_pep" >"${abbr}.A.pep"
# 合并D亚组+scaffold，提取对应pep
seqkit grep -f <(cat "${abbr}.D.geneid" "${abbr}.scaffold.geneid") "$abbr_pep" >"${abbr}.D.pep"

# ===================== 执行完成提示 =====================
info "脚本执行完成！生成的文件如下：
1. 基础geneid文件：${abbr}.geneid
2. 亚组拆分geneid：${abbr}.A.geneid、${abbr}.D.geneid、${abbr}.scaffold.geneid
3. 最终pep文件：${abbr}.A.pep、${abbr}.D.pep"