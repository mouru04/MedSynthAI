#!/bin/bash

# 描述：
# 该脚本用于自动化执行以下任务：
# 1. 接收三种模式的原始数据目录作为参数。
# 2. 清洗原始数据，生成清洗后的数据文件。
# 3. 绘制多种图表，包括学习曲线、T2/T3 分布柱状图、T2/T3 散点图和评分分布箱线图以及最终的三角图。
# 4. 运行该脚本命令示例：bash research/Draw/draw_all.sh --normal-raw-dir normal_raw_data_dir --sequence-raw-dir sequence_raw_data_dir --score-raw-dir score_raw_data_dir
# # 激活 Conda 环境
# # 确保脚本有执行权限
# # # chmod +x research/Draw/draw_all.sh

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

# 检查是否所有必需的目录都已提供
if [ -z "$NORMAL_RAW_DATA_DIR" ] || [ -z "$SEQUENCE_RAW_DATA_DIR" ] || [ -z "$SCORE_RAW_DATA_DIR" ]; then
    echo "❌ 错误: 必须提供 --normal-raw-dir, --sequence-raw-dir, 和 --score-raw-dir 参数。"
    exit 1
fi

# --- 配置输出目录 ---
# 清洗数据的输出目录
NORMAL_CLEANED_DATA_DIR="research/Draw/clean_workflow_valid/normal_cleaned_data"
SEQUENCE_CLEANED_DATA_DIR="research/Draw/clean_workflow_valid/sequence_cleaned_data"
SCORE_CLEANED_DATA_DIR="research/Draw/clean_workflow_valid/score_cleaned_data"

# 图片输出目录 (可以根据需要为不同模式设置不同目录)
FIGURES_DIR="research/Draw/Figures/combined_figures_$(date +"%m%d")"

# --- 配置画图参数 ---
MAX_ROUNDS=30
T2T3_OUTPUT_FILE="t2t3_combined_distribution.png"
T2T3_SCATTER_OUTPUT_FILE="t2_vs_t3_scatter.png"
LEARNING_CURVE_OUTPUT_FILE="learning_curve.png"
SCORE_DISTRIBUTIONS_OUTPUT_FILE="score_distributions.png"
TRIANGLE_OUTPUT_FILE="medical_history_quality_triangle.png"

# --- 设置环境 ---
echo "🔧 设置输出目录..."
mkdir -p "$NORMAL_CLEANED_DATA_DIR" "$SEQUENCE_CLEANED_DATA_DIR" "$SCORE_CLEANED_DATA_DIR" "$FIGURES_DIR"

# --- 数据清洗 ---
echo "🔄 正在清洗 'Normal' 模式数据..."
/home/pci/nas/miniconda3/envs/chy/bin/python research/Draw/clean_workflow_valid/clean.py --data_dir "$NORMAL_RAW_DATA_DIR" --output_dir "$NORMAL_CLEANED_DATA_DIR"
echo "输出目录为 $NORMAL_CLEANED_DATA_DIR"

echo "🔄 正在清洗 'Sequence' 模式数据..."
/home/pci/nas/miniconda3/envs/chy/bin/python research/Draw/clean_workflow_valid/clean.py --data_dir "$SEQUENCE_RAW_DATA_DIR" --output_dir "$SEQUENCE_CLEANED_DATA_DIR"
echo "输出目录为 $SEQUENCE_CLEANED_DATA_DIR"

echo "🔄 正在清洗 'Score Driven' 模式数据..."
/home/pci/nas/miniconda3/envs/chy/bin/python research/Draw/clean_workflow_valid/clean.py --data_dir "$SCORE_RAW_DATA_DIR" --output_dir "$SCORE_CLEANED_DATA_DIR"
echo "输出目录为 $SCORE_CLEANED_DATA_DIR"

# --- 绘制图表 ---
# 注意：以下绘图脚本可能需要调整，以决定是分别绘制还是合并绘制。
# 这里以 'Normal' 模式的清洗数据为例绘制前几个图表。
echo "📊 正在为 'Normal' 模式绘制基础图表..."
/home/pci/nas/miniconda3/envs/chy/bin/python research/Draw/draw_learning_curve.py --cleaned_data_dir "$NORMAL_CLEANED_DATA_DIR" --figures_dir "$FIGURES_DIR" --output_file "normal_${LEARNING_CURVE_OUTPUT_FILE}" --max_rounds "$MAX_ROUNDS"
/home/pci/nas/miniconda3/envs/chy/bin/python research/Draw/draw_t2t3_combined_distribution.py --cleaned_data_dir "$NORMAL_CLEANED_DATA_DIR" --figures_dir "$FIGURES_DIR" --output_file "normal_${T2T3_OUTPUT_FILE}"
/home/pci/nas/miniconda3/envs/chy/bin/python research/Draw/draw_t2_vs_t3_scatter.py --cleaned_data_dir "$NORMAL_CLEANED_DATA_DIR" --figures_dir "$FIGURES_DIR" --output_file "normal_${T2T3_SCATTER_OUTPUT_FILE}"
/home/pci/nas/miniconda3/envs/chy/bin/python research/Draw/draw_score_distributions.py --cleaned_data_dir "$NORMAL_CLEANED_DATA_DIR" --figures_dir "$FIGURES_DIR" --output_file "normal_${SCORE_DISTRIBUTIONS_OUTPUT_FILE}"

# 调用 draw_medical_history_quality_triangle.py (这个脚本需要所有模式的数据)
echo "📊 正在绘制综合医疗历史质量三角图..."
/home/pci/nas/miniconda3/envs/chy/bin/python research/Draw/draw_medical_history_quality_triangle.py \
    --normal_dir "$NORMAL_CLEANED_DATA_DIR" \
    --sequence_dir "$SEQUENCE_CLEANED_DATA_DIR" \
    --score_dir "$SCORE_CLEANED_DATA_DIR" \
    --figures_dir "$FIGURES_DIR" \
    --output_file "$TRIANGLE_OUTPUT_FILE"

echo "✅ 所有绘图任务完成！图表保存在 $FIGURES_DIR"