#!/bin/bash

# 描述：
# 该脚本用于自动化执行研究流程：
# 1. 循环运行 'normal', 'sequence', 'score_driven' 三种模式。
# 2. 对每种模式，通过命令行参数运行批处理，并生成结果目录。
# 3. 调用 research/Draw/draw_all.sh 脚本，传递三种模式的结果目录以生成图表。
#
# 使用方法：
# 1. 激活您的 Python 环境 (例如: conda activate my_env)
# 2. 运行脚本: bash research/research_example.sh

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

    # 为每种模式定义唯一的输出目录
    RESULTS_DIR="results/results_${CURRENT_DATE}_${MODE}_${MODEL_TYPE}"
    LOG_DIR="$RESULTS_DIR/logs"
    OUTPUT_DIR="$RESULTS_DIR/batch_results"
    BATCH_LOG_DIR="$RESULTS_DIR/batch_logs"

    # 确保目录存在且为空
    rm -rf "$RESULTS_DIR"
    mkdir -p "$LOG_DIR" "$OUTPUT_DIR" "$BATCH_LOG_DIR"

    # 运行 main.py 批处理系统，通过命令行传递参数
    echo "🐍 正在运行 main.py..."
    python research/main.py \
        --dataset-path "$DATASET_PATH" \
        --department_guidance_file "$DEPARTMENT_GUIDANCE_FILE" \
        --comparison_rules_file "$COMPARISON_RULES_FILE" \
        --log-dir "$LOG_DIR" \
        --output-dir "$OUTPUT_DIR" \
        --batch-log-dir "$BATCH_LOG_DIR" \
        --model-type "$MODEL_TYPE" \
        --controller-mode "$MODE" \
        --num-threads "$NUM_THREADS" \
        --max-steps "$MAX_STEPS" \
        --start-index "$START_INDEX" \
        --end-index "$END_INDEX"

    if [ $? -ne 0 ]; then
        echo "❌ main.py 在模式 '$MODE' 下执行失败！请检查日志。"
        exit 1
    fi

    # 保存该模式的日志目录路径
    case $MODE in
        normal) NORMAL_LOG_DIR="$LOG_DIR" ;;
        sequence) SEQUENCE_LOG_DIR="$LOG_DIR" ;;
        score_driven) SCORE_DRIVEN_LOG_DIR="$LOG_DIR" ;;
    esac

    echo "✅ 模式 '$MODE' 完成！结果保存在 $RESULTS_DIR"
done

# --- 调用 draw_all.sh 脚本生成图表 ---
echo "=================================================="
echo "📊 所有模式运行完毕，开始生成图表..."
echo "=================================================="
bash research/Draw/draw_all_example.sh \
    --normal-raw-dir "$NORMAL_LOG_DIR" \
    --sequence-raw-dir "$SEQUENCE_LOG_DIR" \
    --score-raw-dir "$SCORE_DRIVEN_LOG_DIR"

if [ $? -ne 0 ]; then
    echo "❌ draw_all_example.sh 执行失败！请检查日志。"
    exit 1
fi

echo "✅ 全部任务完成！"