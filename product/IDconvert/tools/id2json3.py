import pandas as pd
import json
import argparse
import os

def convert_to_bidirectional_json(input_file, output_file, col1_key, col2_key, unique_col=None):
    """
    输入2列表格文件，生成支持双向转换的单JSON文件
    :param input_file: 输入文件路径（csv/tsv/xls/xlsx）
    :param output_file: 输出JSON文件路径
    :param col1_key: 第一列对应的JSON字典键名（自定义字符串）
    :param col2_key: 第二列对应的JSON字典键名（自定义字符串）
    :param unique_col: 指定作为唯一键的列（1/2，缺省时自动生成自然数索引（从1开始））
    """
    # 1. 校验输入文件是否存在
    if not os.path.exists(input_file):
        print(f"❌ 错误：输入文件 {input_file} 不存在，请检查路径！")
        exit(1)
    
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
        exit(1)
    
    # 3. 读取2列数据（使用自定义列名）
    try:
        if read_func == pd.read_csv:
            df = read_func(input_file, sep=sep, header=None, names=[col1_key, col2_key])
        else:
            df = read_func(input_file, sep=sep, header=None, names=[col1_key, col2_key])
    except Exception as e:
        print(f"❌ 读取文件失败：{str(e)}")
        print(f"💡 排查：1.文件是否为纯2列无表头 2.分隔符是否匹配（tsv/xls=\\t，csv=,）")
        exit(1)
    
    # 4. 严格数据清洗（过滤空值、去空格、转字符串，避免ID匹配失败）
    df = df.dropna(subset=[col1_key, col2_key])  # 过滤任意一列空值
    for col in [col1_key, col2_key]:
        df[col] = df[col].astype(str).str.strip()  # 转字符串+去首尾空格
    
    # 5. 处理唯一键：指定列/缺省自动生成自然数索引（从1开始）
    if unique_col:
        # 校验指定的唯一列是否合法（仅支持1/2）
        if unique_col not in [1, 2]:
            print(f"❌ 错误：唯一列仅支持指定1或2，你传入了{unique_col}！")
            exit(1)
        # 映射1/2到自定义列名
        unique_col_name = col1_key if unique_col == 1 else col2_key
        # 按指定列去重（保留最后一行，避免JSON键冲突）
        df = df.drop_duplicates(subset=[unique_col_name], keep="last")
        # 将指定列设为索引列
        df["unique_key"] = df[unique_col_name]
    else:
        # 缺省情况：自动生成自然数索引作为唯一键（从1开始，步长1）
        df["unique_key"] = range(1, len(df) + 1)
        # 索引转字符串（避免JSON键为数字，前端匹配更友好）
        df["unique_key"] = df["unique_key"].astype(str)
        unique_col_name = "自然数索引"
    
    # 6. 构建双向JSON核心结构：{唯一键: {自定义键1: 列1值, 自定义键2: 列2值}}
    bidirectional_dict = {}
    for _, row in df.iterrows():
        bidirectional_dict[row["unique_key"]] = {
            col1_key: row[col1_key],
            col2_key: row[col2_key]
        }
    
    # 7. 写入压缩版JSON（无空格换行，适配GitHub Pages快速加载）
    try:
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(bidirectional_dict, f, ensure_ascii=False, indent=None)
        # 修复f-string反斜杠问题，打印成功信息
        tab_char = "\t"
        sep_show = "制表符(\\t)" if sep == tab_char else sep
        print(f"✅ 双向JSON生成成功！")
        print(f"📂 输入文件：{input_file}（格式：{file_suffix}，有效行{len(df)}）")
        print(f"📂 输出文件：{output_file}（双向映射{len(bidirectional_dict)}条）")
        print(f"🔑 自定义列键：列1={col1_key}，列2={col2_key}")
        print(f"🔑 唯一键列：{unique_col_name}（{f'指定第{unique_col}列' if unique_col else '自动生成自然数索引'}）")
        if sep:
            print(f"🔍 读取分隔符：{sep_show}")
    except Exception as e:
        print(f"❌ 写入JSON失败：{str(e)}（检查输出路径是否有写入权限）")
        exit(1)

if __name__ == "__main__":
    # 构建命令行参数解析器（支持指定参数名传参，-i/-o为必选，其余为必选，第五个为可选）
    parser = argparse.ArgumentParser(description="2列ID文件转双向JSON工具（支持CRI/N244/TM-1等任意基因组互转）")
    # 必选参数1：-i 输入文件
    parser.add_argument("-i", "--input", required=True, help="输入2列文件路径（支持csv/tsv/xls/xlsx），无表头")
    # 必选参数2：-o 输出文件
    parser.add_argument("-o", "--output", required=True, help="输出双向JSON文件路径")
    # 必选参数3：第一列的字典键名字符串
    parser.add_argument("col1_key", help="指定第一列对应的JSON字典键名（如cri/tm1）")
    # 必选参数4：第二列的字典键名字符串
    parser.add_argument("col2_key", help="指定第二列对应的JSON字典键名（如n244/zm24）")
    # 可选参数5：指定唯一列（1/2），缺省时自动生成自然数索引
    parser.add_argument("unique_col", nargs='?', type=int, help="【可选】指定作为唯一键的列（1/2），缺省时自动生成从1开始的自然数索引")
    
    # 解析命令行参数
    args = parser.parse_args()
    
    # 执行转换（传入解析后的参数）
    convert_to_bidirectional_json(
        input_file=args.input,
        output_file=args.output,
        col1_key=args.col1_key,
        col2_key=args.col2_key,
        unique_col=args.unique_col
    )