#!/bin/bash
# Chat Exporter - 文字提取引导脚本
# 用法：./chat-extract.sh <截图文件路径>

set -e

if [ $# -lt 1 ]; then
    echo "❌ 错误：缺少截图路径"
    echo "用法: $0 <截图文件路径>"
    echo ""
    echo "示例："
    echo "  $0 ~/Pictures/elink-chat-*.png"
    echo "  $0 ~/Pictures/elink-徐璐杨-chat-*.png"
    exit 1
fi

SCREENSHOTS="$1"
OUTPUT_FILE="${OUTPUT_FILE:-/Users/yuxuan/.openclaw/workspace/聊天记录.md}"

echo "📝 聊天记录提取工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "截图路径: $SCREENSHOTS"
echo "输出文件: $OUTPUT_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 统计截图数量
FILE_COUNT=$(ls $SCREENSHOTS 2>/dev/null | wc -l | tr -d ' ')

if [ "$FILE_COUNT" -eq 0 ]; then
    echo "❌ 错误：没有找到截图文件"
    echo "请检查路径是否正确：$SCREENSHOTS"
    exit 1
fi

echo "✅ 找到 $FILE_COUNT 张截图"
echo ""
echo "💡 提示：这个脚本会启动一个子代理来处理文字提取"
echo "   子代理会："
echo "   1. 读取所有截图"
echo "   2. 提取聊天内容并识别发送者"
echo "   3. 自动去重（去除重复内容）"
echo "   4. 生成 Markdown 文件"
echo ""
echo "⏳ 预计需要 2-5 分钟（取决于截图数量）"
echo ""

# 询问是否继续
read -p "是否继续？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 已取消"
    exit 0
fi

# 生成任务描述
TASK_FILE="/tmp/chat-extract-task.txt"
cat > "$TASK_FILE" <<EOF
任务：提取聊天记录并生成 Markdown 文件

**截图路径：**
$SCREENSHOTS

**输出文件：**
$OUTPUT_FILE

**任务要求：**
1. 按顺序读取所有截图（从第1张到最后1张）
2. 使用 image 工具分析每张图，提取聊天内容
3. 识别消息发送者（对方 vs 我）
4. **重要：去重！** 连续截图有大量重叠，只保留不重复的部分
5. 按时间顺序整理成对话格式
6. 生成完整的 Markdown 文件

**输出格式示例：**
\`\`\`markdown
# 聊天记录：[对象名称]

## 2025年11月27日

**对方：**
消息内容...

**我：**
回复内容...
\`\`\`

开始处理！
EOF

echo "📋 任务已生成，正在启动子代理..."
echo "   请查看子代理的输出结果"
echo ""

# 这里应该调用 sessions_spawn，但在 bash 脚本中不方便
# 所以生成一个说明文件，告诉用户如何操作

cat <<EOF

🔧 **下一步操作：**

请告诉呆呆：

"帮我提取聊天记录：$(basename $OUTPUT_FILE)"
 
并指定截图路径：
"$SCREENSHOTS"

或者，你可以直接运行：

  openclaw sessions_spawn \\
    --label "chat-extract" \\
    --task "请提取 $SCREENSHOTS 所有截图中的聊天记录，生成 Markdown 文件到 $OUTPUT_FILE" \\
    --timeout 600

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

# 保存任务信息到文件
INFO_FILE="/Users/yuxuan/.openclaw/workspace/chat-extract-info.txt"
cat > "$INFO_FILE" <<EOF
聊天记录提取任务信息
===================

截图路径: $SCREENSHOTS
输出文件: $OUTPUT_FILE
截图数量: $FILE_COUNT
创建时间: $(date)

使用方法：
-------
告诉呆呆："帮我提取这些截图的聊天记录：$SCREENSHOTS"
EOF

echo "✅ 任务信息已保存到: $INFO_FILE"
echo ""
