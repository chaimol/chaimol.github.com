import pandas as pd
import json
import sys
import os

def convert_id_to_json(input_file, output_file):
    """
    将基因ID映射的CSV/TSV/Excel文件转换为键值对JSON文件
    :param input_file: 输入文件路径（支持csv/tsv/xlsx/xls）
    :param output_file: 输出JSON文件路径
    """
    # 1. 校验输入文件是否存在
    if not os.path.exists(input_file):
        print(f"❌ 错误：输入文件 {input_file} 不存在，请检查文件路径！")
        sys.exit(1)
    
    # 2. 解析文件后缀，定义分隔符和读取方式
    file_suffix = input_file.split(".")[-1].lower()
    sep = None  # 分隔符，csv=,  tsv/xls=\t  xlsx=None
    read_func = None  # 读取函数，csv/tsv=read_csv  xls/xlsx=read_excel
    try:
        if file_suffix == "csv":
            sep = ","
            read_func = pd.read_csv
        elif file_suffix == "tsv":
            sep = "\t"  # tsv强制制表符分隔
            read_func = pd.read_csv
        elif file_suffix == "xls":
            sep = "\t"  # xls强制制表符分隔
            read_func = pd.read_excel
        elif file_suffix == "xlsx":
            read_func = pd.read_excel  # xlsx默认读取，无需指定分隔符
        else:
            print(f"❌ 错误：不支持的文件格式 {file_suffix}，仅支持CSV/TSV/Excel(xlsx/xls)！")
            sys.exit(1)
    except Exception as e:
        print(f"❌ 初始化文件读取失败：{str(e)}")
        sys.exit(1)
    
    # 3. 读取文件（根据格式传入对应分隔符）
    try:
        if read_func == pd.read_csv:
            # CSV/TSV文件，传入对应分隔符
            df = read_func(input_file, sep=sep, header=None, names=["source_id", "target_id"])
        else:
            # Excel文件（xls/xlsx），xls传入制表符分隔，xlsx默认
            df = read_func(input_file, sep=sep, header=None, names=["source_id", "target_id"])
    except Exception as e:
        print(f"❌ 读取文件失败：{str(e)}")
        print(f"💡 排查提示：1.检查文件是否为两列ID映射格式 2.确认分隔符是否匹配（tsv/xls已强制用\\t）")
        sys.exit(1)
    
    # 4. 数据清洗：过滤空值、ID转字符串并去空格（避免数字型ID匹配失败）
    df = df.dropna(subset=["source_id", "target_id"])  # 过滤源/目标ID为空的行
    df["source_id"] = df["source_id"].astype(str).str.strip()
    df["target_id"] = df["target_id"].astype(str).str.strip()
    
    # 5. 转换为源ID:目标ID的字典（重复源ID自动保留最后一个）
    id_dict = dict(zip(df["source_id"], df["target_id"]))
    
    # 6. 写入压缩版JSON（适配GitHub Pages快速加载）
    try:
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(id_dict, f, ensure_ascii=False, indent=None)
        # 修复f-string反斜杠问题：提前定义分隔符显示文本
        tab_char = "\t"
        sep_show = "制表符(\\t)" if sep == tab_char else sep
        print(f"✅ 转换成功！")
        print(f"📂 输入文件：{input_file}（格式：{file_suffix}，原始数据{len(df)}行）")
        print(f"📂 输出文件：{output_file}（有效ID映射{len(id_dict)}个）")
        if sep:
            print(f"🔍 读取分隔符：{sep_show}")
    except Exception as e:
        print(f"❌ 写入JSON失败：{str(e)}（检查输出路径是否有权限）")
        sys.exit(1)

if __name__ == "__main__":
    # 校验命令行参数：必须传入 输入文件 输出文件 两个参数
    if len(sys.argv) != 3:
        print("📚 正确使用方法：python id2json.py [输入ID文件路径] [输出JSON文件路径]")
        print("💡 示例1（CSV转JSON，逗号分隔）：python id2json.py tm1-zm24.csv tm1-zm24.json")
        print("💡 示例2（TSV转JSON，制表符分隔）：python id2json.py tm1-zm24.tsv tm1-zm24.json")
        print("💡 示例3（XLS转JSON，制表符分隔）：python id2json.py tm1-zm24.xls tm1-zm24.json")
        print("💡 示例4（XLSX转JSON，默认读取）：python id2json.py tm1-zm24.xlsx tm1-zm24.json")
        print("📌 说明：输入文件必须为「两列无表头」格式，第一列源ID，第二列目标ID")
        sys.exit(1)
    
    # 从命令行获取输入/输出路径
    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]
    
    # 执行转换
    convert_id_to_json(input_file_path, output_file_path)