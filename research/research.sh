#!/bin/bash

# 描述：
# 该脚本用于自动化执行以下任务：
# 1. 循环运行 'normal', 'sequence', 'score_driven' 三种模式。
# 2. 对每种模式，修改参数、运行批处理、重命名结果目录。
# 3. 调用 research/Draw/draw_all.sh 脚本，并传递三种模式的结果目录以生成图表。
# 4. 运行该脚本命令为  bash research/research.sh

# --- 通用配置 ---
DATASET_PATH="research/dataset/test_data.json"
DEPARTMENT_GUIDANCE_FILE="guidance/department_inquiry_guidance.json"
COMPARISON_RULES_FILE="guidance/department_comparison_guidance.json"
NUM_THREADS=4
MAX_STEPS=30
START_INDEX=0
END_INDEX=100
MODEL_TYPE="gpt-oss"
CURRENT_DATE=$(date +"%m%d")

# --- 模式和路径配置 ---
MODES=("normal" "sequence" "score_driven")
NORMAL_LOG_DIR=""
SEQUENCE_LOG_DIR=""
SCORE_DRIVEN_LOG_DIR=""

# --- 循环运行所有模式 ---
for MODE in "${MODES[@]}"; do
    echo "=================================================="
    echo "🚀 开始运行模式: $MODE"
    echo "=================================================="

    # 临时目录名，每次循环都会被重命名
    TEMP_LOG_DIR="results/logs"
    TEMP_OUTPUT_DIR="results/batch_results"
    TEMP_BATCH_LOG_DIR="results/batch_logs"

    # 动态修改 parse_arguments.py 的默认参数
    echo "🔄 正在更新 parse_arguments.py 的默认参数..."
    sed -i "/'--dataset-path'/,/help=/ s|default='[^']*'|default='$DATASET_PATH'|" research/utils/parse_arguments.py
    sed -i "/'--department_guidance_file'/,/help=/ s|default='[^']*'|default='$DEPARTMENT_GUIDANCE_FILE'|" research/utils/parse_arguments.py
    sed -i "/'--comparison_rules_file'/,/help=/ s|default='[^']*'|default='$COMPARISON_RULES_FILE'|" research/utils/parse_arguments.py
    sed -i "/'--log-dir'/,/help=/ s|default='[^']*'|default='$TEMP_LOG_DIR'|" research/utils/parse_arguments.py
    sed -i "/'--output-dir'/,/help=/ s|default='[^']*'|default='$TEMP_OUTPUT_DIR'|" research/utils/parse_arguments.py
    sed -i "/'--batch-log-dir'/,/help=/ s|default='[^']*'|default='$TEMP_BATCH_LOG_DIR'|" research/utils/parse_arguments.py
    sed -i "/'--model-type'/,/help=/ s|default='[^']*'|default='$MODEL_TYPE'|" research/utils/parse_arguments.py
    sed -i "/'--controller-mode'/,/help=/ s|default='[^']*'|default='$MODE'|" research/utils/parse_arguments.py

    # 2. 替换数字/整数类型的参数 (注意：不要加引号)
    # 这里的正则变成 default=[0-9]* 或者 default=[^,]*

    sed -i "/'--num-threads'/,/help=/ s|default=[0-9]\+|default=$NUM_THREADS|" research/utils/parse_arguments.py
    sed -i "/'--max-steps'/,/help=/ s|default=[0-9]\+|default=$MAX_STEPS|" research/utils/parse_arguments.py
    sed -i "/'--start-index'/,/help=/ s|default=[0-9]\+|default=$START_INDEX|" research/utils/parse_arguments.py
    sed -i "/'--end-index'/,/help=/ s|default=[0-9]\+|default=$END_INDEX|" research/utils/parse_arguments.py

    # 确保临时目录存在且为空
    rm -rf "$TEMP_LOG_DIR" "$TEMP_OUTPUT_DIR" "$TEMP_BATCH_LOG_DIR"
    mkdir -p "$TEMP_LOG_DIR" "$TEMP_OUTPUT_DIR" "$TEMP_BATCH_LOG_DIR"

    # 运行 main.py 批处理系统
    echo "🐍 正在运行 main.py..."
    /home/pci/nas/miniconda3/envs/chy/bin/python research/main.py 

    if [ $? -ne 0 ]; then
        echo "❌ main.py 在模式 '$MODE' 下执行失败！请检查日志。"
        exit 1
    fi

    # 重命名结果目录
    RESULTS_DIR="results_${CURRENT_DATE}_${MODE}_${MODEL_TYPE}"
    echo "🔄 正在重命名结果目录为 $RESULTS_DIR..."
    rm -rf "$RESULTS_DIR"
    mkdir -p "$RESULTS_DIR"
    mv "$TEMP_LOG_DIR" "$RESULTS_DIR/logs"
    mv "$TEMP_OUTPUT_DIR" "$RESULTS_DIR/batch_results"
    mv "$TEMP_BATCH_LOG_DIR" "$RESULTS_DIR/batch_logs"

    # 保存该模式的日志目录路径
    case $MODE in
        normal) NORMAL_LOG_DIR="$RESULTS_DIR/logs" ;;
        sequence) SEQUENCE_LOG_DIR="$RESULTS_DIR/logs" ;;
        score_driven) SCORE_DRIVEN_LOG_DIR="$RESULTS_DIR/logs" ;;
    esac

    echo "✅ 模式 '$MODE' 完成！结果保存在 $RESULTS_DIR"
done

# --- 调用 draw_all.sh 脚本生成图表 ---
echo "=================================================="
echo "📊 所有模式运行完毕，开始生成图表..."
echo "=================================================="
bash research/Draw/draw_all.sh \
    --normal-raw-dir "$NORMAL_LOG_DIR" \
    --sequence-raw-dir "$SEQUENCE_LOG_DIR" \
    --score-raw-dir "$SCORE_DRIVEN_LOG_DIR"

if [ $? -ne 0 ]; then
    echo "❌ draw_all.sh 执行失败！请检查日志。"
    exit 1
fi

echo "✅ 全部任务完成！"