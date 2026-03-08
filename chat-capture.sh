#!/bin/bash
# Chat Exporter - 截图脚本
# 用法：./chat-capture.sh <PID> <WINDOW_ID> [起始编号] [截图次数]

set -e

# 参数检查
if [ $# -lt 2 ]; then
    echo "❌ 错误：缺少必要参数"
    echo "用法: $0 <PID> <WINDOW_ID> [起始编号] [截图次数]"
    echo ""
    echo "示例："
    echo "  $0 70444 5764              # 从第1张开始，截图50次"
    echo "  $0 70444 5764 1 100        # 从第1张开始，截图100次"
    echo "  $0 70444 5764 50 30        # 从第50张开始，截图30次"
    exit 1
fi

# 配置参数
PID=$1
WINDOW_ID=$2
COUNTER_START=${3:-1}
LOOP_COUNT=${4:-50}
OUTPUT_DIR=${OUTPUT_DIR:-~/Pictures}
SLEEP_TIME=${SLEEP_TIME:-0.5}

echo "📸 开始自动截图聊天记录"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PID:         $PID"
echo "Window ID:   $WINDOW_ID"
echo "起始编号:    $COUNTER_START"
echo "截图次数:    $LOOP_COUNT"
echo "保存目录:    $OUTPUT_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

counter=$COUNTER_START

# 先点击聊天区域确保焦点
echo "🎯 点击聊天区域确保焦点..."
peekaboo click --pid $PID --window-id $WINDOW_ID --coords 450,400
sleep 1

# 先截第一张（顶部）
echo "📸 截图第 $counter 张（起始位置）..."
peekaboo image --pid $PID --window-id $WINDOW_ID --path "$OUTPUT_DIR/elink-chat-$counter.png" --retina
counter=$((counter+1))

# 用 PageDown 向下滚动并截图
echo "📜 开始向下滚动截图..."
for i in $(seq 1 $LOOP_COUNT); do
    echo "⏳ 正在截图第 $counter 张 ($i/$LOOP_COUNT)..."
    peekaboo press pagedown --pid $PID --window-id $WINDOW_ID --count 1
    sleep $SLEEP_TIME
    peekaboo image --pid $PID --window-id $WINDOW_ID --path "$OUTPUT_DIR/elink-chat-$counter.png" --retina
    counter=$((counter+1))
done

echo ""
echo "✅ 完成！共截图 $((counter - COUNTER_START)) 张"
echo "📁 保存位置: $OUTPUT_DIR/elink-chat-*.png"
echo ""
echo "💡 下一步：运行文字提取脚本"
echo "   chat-extract.sh \"$OUTPUT_DIR/elink-chat-*.png\""
