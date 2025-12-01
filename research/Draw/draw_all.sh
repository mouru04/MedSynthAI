#!/bin/bash

# 描述：
# 该脚本用于自动化执行以下任务：
# 1. 清洗原始数据，生成清洗后的数据文件。
# 2. 绘制多种图表，包括学习曲线、T2/T3 分布柱状图、T2/T3 散点图和评分分布箱线图。
# 3. 所有输出文件将保存在指定的目录中。

# 注意：
# - 请确保 Conda 环境已正确配置，并安装了所需的依赖。
# - 请确保原始数据目录和输出目录的路径正确。

# 运行脚本
# ./research/Draw/draw_all.sh


# 激活 Conda 环境
source ~/nas/miniconda3/etc/profile.d/conda.sh
conda activate chy

# 配置参数
CLEANED_DATA_DIR="research/Draw/clean_workflow_valid/cleaned_data"
RAW_DATA_DIR="results_11_30/results_11_30_Agent_Driven"
FIGURES_DIR="research/Draw/figure"
MAX_ROUNDS=30

T2T3_OUTPUT_FILE="t2t3_combined_distribution.png"
T2T3_SCATTER_OUTPUT_FILE="t2_vs_t3_scatter.png"
LEARNING_CURVE_OUTPUT_FILE="learning_curve.png"
SCORE_DISTRIBUTIONS_OUTPUT_FILE="score_distributions.png"

# 设置环境
echo "🔧 设置输出目录..."
mkdir -p "$CLEANED_DATA_DIR"
mkdir -p "$FIGURES_DIR"

# 数据清洗
echo "🔄 正在清洗数据..."
/home/pci/nas/miniconda3/envs/chy/bin/python3 research/Draw/clean_workflow_valid/clean.py --data_dir "$RAW_DATA_DIR" --output_dir "$CLEANED_DATA_DIR"

# 绘制学习曲线
echo "📊 正在绘制学习曲线..."
/home/pci/nas/miniconda3/envs/chy/bin/python3 research/Draw/draw_learning_curve.py --cleaned_data_dir "$CLEANED_DATA_DIR" --figures_dir "$FIGURES_DIR" --output_file "$LEARNING_CURVE_OUTPUT_FILE" --max_rounds "$MAX_ROUNDS"

# 绘制 T2/T3 分布柱状图
echo "📊 正在绘制 T2/T3 分布柱状图..."
/home/pci/nas/miniconda3/envs/chy/bin/python3 research/Draw/draw_t2t3_combined_distribution.py --cleaned_data_dir "$CLEANED_DATA_DIR" --figures_dir "$FIGURES_DIR" --output_file "$T2T3_OUTPUT_FILE"

# 绘制 T2/T3 散点图
echo "📊 正在绘制 T2/T3 散点图..."
/home/pci/nas/miniconda3/envs/chy/bin/python3 research/Draw/draw_t2_vs_t3_scatter.py --cleaned_data_dir "$CLEANED_DATA_DIR" --figures_dir "$FIGURES_DIR" --output_file "$T2T3_SCATTER_OUTPUT_FILE"

# 绘制评分分布箱线图
echo "📊 正在绘制评分分布箱线图..."
/home/pci/nas/miniconda3/envs/chy/bin/python3 research/Draw/draw_score_distributions.py --cleaned_data_dir "$CLEANED_DATA_DIR" --figures_dir "$FIGURES_DIR" --output_file "$SCORE_DISTRIBUTIONS_OUTPUT_FILE"

echo "✅ 所有任务完成！"