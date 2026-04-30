# convert_csv_to_js.py
import csv
import json

def convert_csv_to_js(csv_file, js_file):
    coords_data = {}
    
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            area = row['Area'].strip()
            lng = float(row['lng'])
            lat = float(row['lat'])
            
            if area:  # 只添加有地区名的记录
                coords_data[area] = {
                    'lng': lng,
                    'lat': lat
                }
    
    # 生成 JS 文件
    with open(js_file, 'w', encoding='utf-8') as f:
        f.write('// 中国县区经纬度数据 - 从 China_country.csv 转换而来\n')
        f.write('// 自动生成，请勿手动修改\n\n')
        f.write('const ChinaCountiesCoords = ')
        f.write(json.dumps(coords_data, ensure_ascii=False, indent=2))
        f.write(';\n\n')
        
        # 添加查找函数
        f.write('''// 查找地点坐标的函数
function findLocationCoords(locationName) {
    // 直接匹配
    if (ChinaCountiesCoords[locationName]) {
        return ChinaCountiesCoords[locationName];
    }
    
    // 模糊匹配：尝试匹配包含关系
    for (const key in ChinaCountiesCoords) {
        if (key.includes(locationName) || locationName.includes(key)) {
            console.log(`模糊匹配: "${locationName}" -> "${key}"`);
            return ChinaCountiesCoords[key];
        }
    }
    
    // 如果都没找到，返回默认值（北京）
    console.warn(`未找到地点 "${locationName}" 的坐标，使用默认北京坐标`);
    return { lng: 116.397, lat: 39.908 };
}
''')
    
    print(f'转换完成！共 {len(coords_data)} 条记录')
    print(f'输出文件: {js_file}')

if __name__ == '__main__':
    convert_csv_to_js('China_country.csv', 'china_counties_coords.js')