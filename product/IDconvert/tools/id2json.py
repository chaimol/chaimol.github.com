import pandas as pd
import json
import sys
import os

def convert_to_array_json(input_file, output_file, col1_key, col2_key, unique_col=None):
    """
    输入2列表格文件，生成数组对象格式的JSON文件（适配基因组ID双向转换）
    :param input_file: 输入文件路径（csv/tsv/xls/xlsx），无表头
    :param output_file: 输出JSON文件路径
    :param col1_key: 第一列对应的JSON对象键名（自定义字符串，如CRI/N244/TM1）
    :param col2_key: 第二列对应的JSON对象键名（自定义字符串，如CRI/N244/TM1）
    :param unique_col: 指定作为唯一键的列（1/2，缺省时自动按整行去重，无重复风险）
    """
    # 1. 校验输入文件是否存在
    if not os.path.exists(input_file):
        print(f"❌ 错误：输入文件 {input_file} 不存在，请检查文件路径！")
        sys.exit(1)
    
    # 2. 解析文件后缀，自动定义分隔符和读取函数（tsv/xls=\t，csv=,，xlsx默认）
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
        read_func = pd.read_csv
    elif file_suffix == "xlsx":
        read_func = pd.read_excel
    else:
        print(f"❌ 错误：不支持的文件格式 {file_suffix}，仅支持CSV/TSV/XLS/XLSX！")
        sys.exit(1)
    
    # 3. 读取2列数据（使用用户自定义的列键名）
    try:
        if read_func == pd.read_csv:
            df = read_func(input_file, sep=sep, header=None, names=[col1_key, col2_key])
        else:
            df = read_func(input_file, sep=sep, header=None, names=[col1_key, col2_key])
    except Exception as e:
        print(f"❌ 读取文件失败：{str(e)}")
        print(f"💡 排查提示：1.文件是否为纯2列无表头格式 2.分隔符是否匹配（tsv/xls=\\t，csv=,）")
        sys.exit(1)
    
    # 4. 严格数据清洗（过滤空值、去空格、转字符串，避免ID匹配/显示异常）
    df = df.dropna(subset=[col1_key, col2_key])  # 过滤任意一列空值
    for col in [col1_key, col2_key]:
        df[col] = df[col].astype(str).str.strip()  # 转字符串+去首尾空格
    
    # 5. 处理唯一键去重（指定列/缺省按整行去重）
    if unique_col:
        if unique_col not in [1, 2]:
            print(f"❌ 错误：唯一列仅支持指定1或2，你传入了{unique_col}！")
            sys.exit(1)
        unique_col_name = col1_key if unique_col == 1 else col2_key
        df = df.drop_duplicates(subset=[unique_col_name], keep="last")
        unique_tip = f"指定第{unique_col}列（{unique_col_name}）"
    else:
        df = df.drop_duplicates(keep="last")  # 缺省按整行去重
        unique_tip = "自动按整行去重（未指定唯一列）"
    
    # 6. 构建要求的【数组对象】JSON格式（核心：[{col1:值, col2:值}, ...]）
    result_array = df[[col1_key, col2_key]].to_dict(orient="records")
    
    # 7. 写入压缩版JSON（适配GitHub Pages快速加载）
    try:
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(result_array, f, ensure_ascii=False, indent=None)
        # 修复f-string反斜杠问题，打印成功信息
        tab_char = "\t"
        sep_show = "制表符(\\t)" if sep == tab_char else sep
        print(f"✅ 数组对象格式JSON生成成功！")
        print(f"📂 输入文件：{input_file}（格式：{file_suffix}，有效行{len(df)}）")
        print(f"📂 输出文件：{output_file}（最终数据{len(result_array)}条）")
        print(f"🔑 JSON对象键名：{col1_key}、{col2_key}")
        print(f"🔍 去重规则：{unique_tip}")
        if sep:
            print(f"🔍 读取分隔符：{sep_show}")
    except Exception as e:
        print(f"❌ 写入JSON失败：{str(e)}（检查输出路径是否有写入权限）")
        sys.exit(1)

if __name__ == "__main__":
    # 校验传参数量：必传4个（输入/输出/列1键/列2键），可选第5个（唯一列）
    if len(sys.argv) not in [5, 6]:
        print("📚 脚本使用方法（纯位置顺序传参，无指定名参数）：")
        print("python id2json_bidirectional.py 输入2列文件 输出JSON文件 列1键名 列2键名 [可选唯一列1/2]")
        print("="*80)
        print("💡 必传4个参数：输入文件 → 输出JSON → 列1键名 → 列2键名")
        print("💡 可选第5个参数：1/2（指定去重的唯一列，缺省时自动按整行去重）")
        print("="*80)
        print("示例1（指定第2列去重，CRI/N244）：")
        print("python id2json_bidirectional.py cri-n244.tsv cri-n244.json CRI N244 2")
        print("示例2（指定第1列去重，TM1/CRI）：")
        print("python id2json_bidirectional.py tm1-cri.csv tm1-cri.json TM1 CRI 1")
        print("示例3（不指定唯一列，自动整行去重）：")
        print("python id2json_bidirectional.py cri-n244.xlsx cri-n244.json CRI N244")
        print("📌 说明：输入文件为2列无表头，支持csv/tsv/xls/xlsx，tsv/xls自动用\\t分隔")
        sys.exit(1)
    
    # 按顺序提取位置参数（取消-i/-o，直接顺序取值）
    input_file_path = sys.argv[1]   # 第1个参数：输入文件
    output_file_path = sys.argv[2]  # 第2个参数：输出JSON文件
    col1_key = sys.argv[3]          # 第3个参数：列1的JSON键名
    col2_key = sys.argv[4]          # 第4个参数：列2的JSON键名
    # 第5个参数为可选，存在则转为整数，不存在则为None
    unique_col = int(sys.argv[5]) if len(sys.argv) == 6 else None
    
    # 执行核心转换函数
    convert_to_array_json(
        input_file=input_file_path,
        output_file=output_file_path,
        col1_key=col1_key,
        col2_key=col2_key,
        unique_col=unique_col
    )