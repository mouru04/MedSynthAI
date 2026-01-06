#!/bin/bash

# 描述：
# 该脚本用于自动化执行数据清洗和图表绘制：
# 1. 接收三种模式的原始数据目录作为参数。
# 2. 清洗数据，并为每种模式生成独立的图表。
# 3. 绘制一个综合所有模式的对比图。
#
# 使用方法：
# 1. 激活您的 Python 环境 (例如: conda activate my_env)
# 2. 确保脚本有执行权限: chmod +x research/Draw/draw_all_example.sh
# 3. 运行脚本: bash research/Draw/draw_all_example.sh --normal-raw-dir path1 --sequence-raw-dir path2 --score-raw-dir path3

# --- 解析输入参数 ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --normal-raw-dir) NORMAL_RAW_DATA_DIR="$2"; shift ;;
        --sequence-raw-dir) SEQUENCE_RAW_DATA_DIR="$2"; shift ;;
        --score-raw-dir) SCORE_RAW_DATA_DIR="$2"; shift ;;
        *) echo "未知参数: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$NORMAL_RAW_DATA_DIR" ] || [ -z "$SEQUENCE_RAW_DATA_DIR" ] || [ -z "$SCORE_RAW_DATA_DIR" ]; then
    echo "❌ 错误: 必须提供 --normal-raw-dir, --sequence-raw-dir, 和 --score-raw-dir 参数。"
    exit 1
fi

# --- 配置目录 ---
BASE_CLEANED_DIR="research/Draw/cleaned_data"
NORMAL_CLEANED_DATA_DIR="$BASE_CLEANED_DIR/normal"
SEQUENCE_CLEANED_DATA_DIR="$BASE_CLEANED_DIR/sequence"
SCORE_CLEANED_DATA_DIR="$BASE_CLEANED_DIR/score_driven"
FIGURES_DIR="research/Draw/Figures/figures_$(date +"%Y%m%d")"

# --- 配置画图参数 ---
MAX_ROUNDS=30
LEARNING_CURVE_OUTPUT_FILE="learning_curve.png"
SCORE_DISTRIBUTIONS_OUTPUT_FILE="score_distributions.png"
TRIANGLE_OUTPUT_FILE="medical_history_quality_triangle.png"

# --- 设置环境 ---
echo "🔧 设置输出目录..."
mkdir -p "$NORMAL_CLEANED_DATA_DIR" "$SEQUENCE_CLEANED_DATA_DIR" "$SCORE_CLEANED_DATA_DIR" "$FIGURES_DIR"

# --- 数据清洗 ---
echo "🔄 正在清洗 'Normal' 模式数据..."
python research/Draw/clean_workflow_valid/clean.py --data_dir "$NORMAL_RAW_DATA_DIR" --output_dir "$NORMAL_CLEANED_DATA_DIR"

echo "🔄 正在清洗 'Sequence' 模式数据..."
python research/Draw/clean_workflow_valid/clean.py --data_dir "$SEQUENCE_RAW_DATA_DIR" --output_dir "$SEQUENCE_CLEANED_DATA_DIR"

echo "🔄 正在清洗 'Score Driven' 模式数据..."
python research/Draw/clean_workflow_valid/clean.py --data_dir "$SCORE_RAW_DATA_DIR" --output_dir "$SCORE_CLEANED_DATA_DIR"

# --- 绘制各模式图表 ---
MODES=("normal" "sequence" "score_driven")
CLEANED_DIRS=("$NORMAL_CLEANED_DATA_DIR" "$SEQUENCE_CLEANED_DATA_DIR" "$SCORE_CLEANED_DATA_DIR")

for i in "${!MODES[@]}"; do
    MODE=${MODES[$i]}
    DATA_DIR=${CLEANED_DIRS[$i]}
    echo "📊 正在为 '$MODE' 模式绘制图表..."
    
    python research/Draw/draw_learning_curve.py --cleaned_data_dir "$DATA_DIR" --figures_dir "$FIGURES_DIR" --output_file "${MODE}_${LEARNING_CURVE_OUTPUT_FILE}" --max_rounds "$MAX_ROUNDS"
    python research/Draw/draw_score_distributions.py --cleaned_data_dir "$DATA_DIR" --figures_dir "$FIGURES_DIR" --output_file "${MODE}_${SCORE_DISTRIBUTIONS_OUTPUT_FILE}"
done

# --- 绘制综合对比图表 ---
echo "📊 正在绘制综合医疗历史质量三角图..."
python research/Draw/draw_medical_history_quality_triangle.py \
    --normal_dir "$NORMAL_CLEANED_DATA_DIR" \
    --sequence_dir "$SEQUENCE_CLEANED_DATA_DIR" \
    --score_dir "$SCORE_CLEANED_DATA_DIR" \
    --figures_dir "$FIGURES_DIR" \
    --output_file "$TRIANGLE_OUTPUT_FILE"

echo "✅ 所有绘图任务完成！图表保存在 $FIGURES_DIR"