import pandas as pd
import json
import sys
import os

def convert_bidirectional_id(input_file, output_file):
    """
    输入2列ID文件，生成CRI↔N244双向转换的单JSON文件
    输入文件要求：2列无表头 → 列1=CRI ID，列2=N244 ID（自动以第二列N244为唯一键）
    输出JSON结构：{N244_ID: {"cri": CRI_ID, "n244": N244_ID}}，支持双向查询
    适配格式：CSV/TSV/XLS/XLSX（tsv/xls自动用\t分隔，csv用,分隔）
    """
    # 1. 校验输入文件是否存在
    if not os.path.exists(input_file):
        print(f"❌ 错误：输入文件 {input_file} 不存在，请检查路径！")
        sys.exit(1)
    
    # 2. 解析文件后缀，定义分隔符和读取方式（严格按要求：tsv/xls=\t，csv=,，xlsx默认）
    file_suffix = input_file.split(".")[-1].lower()
    sep = None
    read_func = None
    if file_suffix == "csv":
        sep = ","
        read_func = pd.read_csv
    elif file_suffix == "tsv":
        sep = "\t"
        read_func = pd.read_csv
    elif file_suffix == "xls":
        sep = "\t"
        read_func = pd.read_excel
    elif file_suffix == "xlsx":
        read_func = pd.read_excel
    else:
        print(f"❌ 错误：不支持的文件格式 {file_suffix}，仅支持CSV/TSV/XLS/XLSX！")
        sys.exit(1)
    
    # 3. 读取2列数据（核心：列1=cri，列2=n244，不再需要第三列）
    try:
        if read_func == pd.read_csv:
            df = read_func(input_file, sep=sep, header=None, names=["cri", "n244"])
        else:
            df = read_func(input_file, sep=sep, header=None, names=["cri", "n244"])
    except Exception as e:
        print(f"❌ 读取文件失败：{str(e)}")
        print(f"💡 排查提示：1.文件是否为纯2列无表头格式 2.分隔符是否匹配（tsv/xls=\\t，csv=,）")
        sys.exit(1)
    
    # 4. 严格数据清洗（过滤空值、去空格、转字符串，避免ID匹配失败）
    # 过滤任意一列空值（CRI和N244都不能为空）
    df = df.dropna(subset=["cri", "n244"])
    # 所有列转字符串+去首尾空格（解决数字型ID、空格导致的匹配失败问题）
    for col in ["cri", "n244"]:
        df[col] = df[col].astype(str).str.strip()
    # 核心：以第二列n244为唯一键去重（重复保留最后一行，避免JSON键冲突）
    df = df.drop_duplicates(subset=["n244"], keep="last")
    
    # 5. 转换为双向JSON结构（核心：以n244为键，包含cri和n244双字段，支持双向查询）
    bidirectional_dict = {}
    for _, row in df.iterrows():
        n244_id = row["n244"]
        bidirectional_dict[n244_id] = {
            "cri": row["cri"],
            "n244": n244_id
        }
    
    # 6. 写入压缩版JSON（无空格换行，适配GitHub Pages快速加载）
    try:
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(bidirectional_dict, f, ensure_ascii=False, indent=None)
        # 打印成功信息，修复f-string反斜杠问题
        tab_char = "\t"
        sep_show = "制表符(\\t)" if sep == tab_char else sep
        print(f"✅ 双向JSON生成成功！")
        print(f"📂 输入文件：{input_file}（格式：{file_suffix}，原始有效行{len(df)}）")
        print(f"📂 输出文件：{output_file}（双向映射{len(bidirectional_dict)}条，唯一键=N244 ID）")
        if sep:
            print(f"🔍 读取分隔符：{sep_show}")
    except Exception as e:
        print(f"❌ 写入JSON失败：{str(e)}（请检查输出路径是否有写入权限）")
        sys.exit(1)

if __name__ == "__main__":
    # 校验命令行参数：必须传入「输入2列文件」「输出JSON文件」两个参数
    if len(sys.argv) != 3:
        print("📚 双向ID转换脚本使用方法：python id2json_bidirectional.py [输入2列ID文件] [输出双向JSON文件]")
        print("💡 示例1（CSV，逗号分隔）：python id2json_bidirectional.py cri-n244.csv cri-n244-bidirectional.json")
        print("💡 示例2（TSV，制表符分隔）：python id2json_bidirectional.py cri-n244.tsv cri-n244-bidirectional.json")
        print("💡 示例3（XLS，制表符分隔）：python id2json_bidirectional.py cri-n244.xls cri-n244-bidirectional.json")
        print("💡 示例4（XLSX，默认读取）：python id2json_bidirectional.py cri-n244.xlsx cri-n244-bidirectional.json")
        print("📌 核心要求：输入为「2列无表头」→ 列1=CRI ID，列2=N244 ID（自动以N244为唯一键）")
        sys.exit(1)
    
    # 从命令行获取输入/输出文件路径
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    # 执行双向JSON生成
    convert_bidirectional_id(input_path, output_path)