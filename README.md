# Chat Exporter / 聊天记录导出工具

[English](#english) | [中文](#中文)

---

<a id="english"></a>
## English

### Overview / 概述

Chat Exporter is an automation tool that exports chat history from macOS messaging applications (such as WeChat Work, DingTalk, Slack, etc.) to formatted Markdown documents. By combining window automation (Peekaboo), OCR text extraction, and intelligent deduplication, it solves the problem of archiving and searching chat records.

**Key Features:**
- 📸 **Automatic Screenshots** - Auto-scroll and capture chat history using PageDown
- 🔍 **OCR Text Extraction** - Extract chat content from screenshots
- 🧹 **Smart Deduplication** - Remove duplicate content from overlapping screenshots
- 📝 **Markdown Output** - Generate clean, formatted Markdown files
- 🚀 **One-Command Workflow** - Simple and easy to use

### Motivation / 动机

**The Problem:**
- Chat history in messaging apps is hard to export
- Manual screenshots are time-consuming for long conversations
- Screenshots cannot be searched or edited
- Need to archive important work conversations

**The Solution:**
Automate the entire process with a single tool:
1. Open chat window and scroll to top
2. Run the script → auto-scroll, screenshot, extract text
3. Get a clean Markdown file with all chat history

### How It Works / 原理

```
┌─────────────────┐
│  1. List Window │  peekaboo list windows
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  2. Auto Scroll │  peekaboo press pagedown
│    & Screenshot │  peekaboo image --retina
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  3. Extract Text│  image tool (OCR)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  4. Deduplicate │  Compare adjacent screenshots
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  5. Generate MD │  Formatted Markdown output
└─────────────────┘
```

**Key Technologies:**
- **Peekaboo CLI** - macOS UI automation
- **OCR** - Text extraction from images
- **Bash Scripts** - Automation glue code
- **Deduplication Algorithm** - Remove overlapping content

### Installation / 安装

#### Prerequisites / 前置要求

1. **Install Peekaboo**
   ```bash
   brew install steipete/tap/peekaboo
   ```

2. **Grant Permissions**
   - Open **System Preferences** → **Privacy & Security**
   - Enable **Screen Recording** and **Accessibility** for Peekaboo
   - Verify permissions: `peekaboo permissions`

3. **Clone This Repository**
   ```bash
   git clone https://github.com/YuxuanXiu/openclaw-skill-chat--exporter.git
   cd openclaw-skill-chat--exporter
   ```

### Usage / 使用方法

#### Method 1: Automated (Recommended) / 方法 1：自动化（推荐）

**If you have OpenClaw installed:**

1. Open the chat window and scroll to the **top**
2. Tell your AI assistant: "Help me export this chat history"
3. Done! The assistant will:
   - Auto-capture screenshots
   - Extract text and deduplicate
   - Generate Markdown file

#### Method 2: Manual Scripts / 方法 2：手动脚本

**Step 1: Get Window Information / 步骤 1：获取窗口信息**

```bash
# List all windows for the target app
peekaboo list windows --app "WeChat Work" --json
```

Note down the `processIdentifier` (PID) and `window_id`.

**Step 2: Capture Screenshots / 步骤 2：截图**

```bash
# Run the capture script
./chat-capture.sh <PID> <WINDOW_ID> [START_NUMBER] [LOOP_COUNT]

# Example: Capture 100 screenshots starting from #1
./chat-capture.sh 70444 5764 1 100
```

Parameters:
- `PID` - Process ID of the target app
- `WINDOW_ID` - Window ID to capture
- `START_NUMBER` - Starting screenshot number (default: 1)
- `LOOP_COUNT` - Number of screenshots (default: 50)

**Step 3: Extract Text / 步骤 3：提取文字**

```bash
# Extract text from screenshots
./chat-extract.sh ~/Pictures/elink-chat-*.png
```

The extracted Markdown file will be saved to: `~/workspace/聊天记录.md`

### Configuration / 配置

#### Environment Variables / 环境变量

```bash
# Screenshot settings
export OUTPUT_DIR=~/Pictures              # Screenshot output directory
export SLEEP_TIME=0.5                     # Delay between scrolls (seconds)
export LOOP_COUNT=50                       # Default screenshot count

# Extraction settings
export OUTPUT_FILE=~/workspace/chat.md    # Output Markdown file
```

### Output Format / 输出格式

The generated Markdown file follows this format:

```markdown
# Chat Log: [Contact Name]

## 2025-11-27

**John Doe:**
Message content goes here...

**Me:**
Reply message...

## 2025-11-28

**John Doe:**
Another message...
```

### Features / 功能特性

#### Automatic Screenshots / 自动截图

- Uses `PageDown` key for full-page scrolling
- High-resolution screenshots with `--retina` flag
- Configurable delay and loop count
- Progress indicator

#### Text Extraction / 文字提取

- OCR-powered text recognition
- Identifies sender (recipient vs. sender)
- Preserves timestamps
- Supports multiple languages

#### Smart Deduplication / 智能去重

Algorithm:
1. Compare each screenshot with the previous one
2. Identify new messages not seen before
3. Only add unique messages to the final output

Example:
```
Screenshot 1: [A, B, C]
Screenshot 2: [A, B, C, D, E]  ← A, B, C already seen
Screenshot 3: [C, D, E, F]     ← C, D, E already seen
Output: [A, B, C, D, E, F]     ← Only F is new
```

### Use Cases / 使用场景

- ✅ **Archive Work Chats** - Save important project discussions
- ✅ **Documentation Backup** - Prevent loss of chat records
- ✅ **Report Compilation** - Extract key information from conversations
- ✅ **Knowledge Management** - Convert chats to searchable documents
- ✅ **Legal Evidence** - Preserve communication records

### Troubleshooting / 故障排查

#### Screenshot Failed / 截图失败

**Problem:** Script reports capture error

**Solution:**
```bash
# Check Peekaboo permissions
peekaboo permissions

# Verify window ID
peekaboo list windows --app "AppName" --json

# Ensure window is focused
peekaboo click --pid <PID> --window-id <WINDOW_ID> --coords 450,400
```

#### Duplicate Screenshots / 截图重复

**Problem:** Screenshots look identical

**Solution:**
- Increase `SLEEP_TIME`: `SLEEP_TIME=1.0 ./chat-capture.sh ...`
- Ensure `PageDown` is working: Check if content is scrolling
- Verify window has focus

#### OCR Inaccurate / 文字识别不准确

**Problem:** Extracted text has errors

**Solution:**
- Use high-resolution screenshots (`--retina` enabled by default)
- Adjust window size for better text visibility
- Manually edit the generated Markdown file
- Ensure screenshot quality is good (not blurry)

#### Cannot Scroll to Bottom / 无法滚动到底部

**Problem:** Chat history is very long

**Solution:**
```bash
# Run in batches
./chat-capture.sh <PID> <WINDOW_ID> 1 100   # First batch
./chat-capture.sh <PID> <WINDOW_ID> 101 100 # Continue from #101
```

### Performance / 性能

- **Screenshot speed:** ~2 screenshots/second
- **Extraction time:** ~3-5 seconds/screenshot (OCR)
- **Total time for 100 screenshots:** ~5-8 minutes

### Limitations / 局限性

- **Platform:** macOS only (requires Peekaboo)
- **Image recognition accuracy:** Depends on screenshot quality
- **Complex content:** Emojis, images, and files may not be recognized
- **Manual review recommended:** Always check the output for errors

### Contributing / 贡献

Contributions are welcome! Please feel free to submit issues or pull requests.

Areas for improvement:
- Support for more platforms (Windows, Linux)
- Better OCR accuracy
- Support for images and file attachments
- Sentiment analysis and keyword extraction
- Automatic summarization

### License / 许可证

MIT License - feel free to use and modify for your needs.

### Acknowledgments / 致谢

- **Peekaboo** - macOS UI automation tool
- **OpenClaw** - AI agent framework
- **OCR Technology** - Text extraction from images

### Changelog / 更新日志

#### v1.0 (2026-03-08)
- Initial release
- Auto-capture with PageDown scrolling
- OCR text extraction
- Smart deduplication
- Markdown output

---

<a id="中文"></a>
## 中文

### 概述

聊天记录导出工具是一个自动化工具，可以将 macOS 即时通讯应用（如企业微信、钉钉、Slack 等）的聊天记录导出为格式化的 Markdown 文档。通过结合窗口自动化（Peekaboo）、OCR 文字提取和智能去重技术，解决了聊天记录归档和搜索的问题。

**核心功能：**
- 📸 **自动截图** - 使用 PageDown 自动滚动并截图聊天记录
- 🔍 **OCR 文字提取** - 从截图中提取聊天内容
- 🧹 **智能去重** - 删除重叠截图中的重复内容
- 📝 **Markdown 输出** - 生成清晰、格式化的 Markdown 文件
- 🚀 **一键操作** - 简单易用

### 动机

**问题：**
- 即时通讯应用中的聊天记录难以导出
- 长对话手动截图费时费力
- 截图无法搜索或编辑
- 需要归档重要的工作对话

**解决方案：**
用单一工具自动化整个流程：
1. 打开聊天窗口并滚动到顶部
2. 运行脚本 → 自动滚动、截图、提取文字
3. 获得包含所有聊天记录的清晰 Markdown 文件

### 原理

```
┌─────────────────┐
│  1. 列出窗口    │  peekaboo list windows
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  2. 自动滚动    │  peekaboo press pagedown
│    & 截图       │  peekaboo image --retina
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  3. 提取文字    │  image tool (OCR)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  4. 智能去重    │  比较相邻截图
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  5. 生成 MD 文件│  格式化 Markdown 输出
└─────────────────┘
```

**核心技术：**
- **Peekaboo CLI** - macOS UI 自动化
- **OCR** - 图像文字提取
- **Bash 脚本** - 自动化胶水代码
- **去重算法** - 删除重叠内容

### 安装

#### 前置要求

1. **安装 Peekaboo**
   ```bash
   brew install steipete/tap/peekaboo
   ```

2. **授予权限**
   - 打开 **系统偏好设置** → **隐私与安全性**
   - 为 Peekaboo 启用 **屏幕录制** 和 **辅助功能** 权限
   - 验证权限：`peekaboo permissions`

3. **克隆仓库**
   ```bash
   git clone https://github.com/YuxuanXiu/openclaw-skill-chat--exporter.git
   cd openclaw-skill-chat--exporter
   ```

### 使用方法

#### 方法 1：自动化（推荐）

**如果你安装了 OpenClaw：**

1. 打开聊天窗口并滚动到**顶部**
2. 告诉 AI 助手："帮我导出这个聊天窗口的记录"
3. 完成！助手会：
   - 自动截图
   - 提取文字并去重
   - 生成 Markdown 文件

#### 方法 2：手动脚本

**步骤 1：获取窗口信息**

```bash
# 列出目标应用的所有窗口
peekaboo list windows --app "企业微信" --json
```

记下 `processIdentifier` (PID) 和 `window_id`。

**步骤 2：截图**

```bash
# 运行截图脚本
./chat-capture.sh <PID> <WINDOW_ID> [起始编号] [截图次数]

# 示例：从第1张开始，截图100次
./chat-capture.sh 70444 5764 1 100
```

参数：
- `PID` - 目标应用的进程 ID
- `WINDOW_ID` - 要截图的窗口 ID
- `起始编号` - 起始截图编号（默认：1）
- `截图次数` - 截图次数（默认：50）

**步骤 3：提取文字**

```bash
# 从截图提取文字
./chat-extract.sh ~/Pictures/elink-chat-*.png
```

提取的 Markdown 文件将保存到：`~/workspace/聊天记录.md`

### 配置

#### 环境变量

```bash
# 截图设置
export OUTPUT_DIR=~/Pictures              # 截图输出目录
export SLEEP_TIME=0.5                     # 滚动延迟（秒）
export LOOP_COUNT=50                       # 默认截图次数

# 提取设置
export OUTPUT_FILE=~/workspace/chat.md    # 输出 Markdown 文件
```

### 输出格式

生成的 Markdown 文件遵循以下格式：

```markdown
# 聊天记录：[联系人名称]

## 2025-11-27

**张三：**
消息内容...

**我：**
回复消息...

## 2025-11-28

**张三：**
另一条消息...
```

### 功能特性

#### 自动截图

- 使用 `PageDown` 键进行整页滚动
- 使用 `--retina` 标志进行高清截图
- 可配置延迟和循环次数
- 进度指示器

#### 文字提取

- 基于 OCR 的文字识别
- 识别发送者（对方 vs. 我）
- 保留时间戳
- 支持多种语言

#### 智能去重

算法：
1. 比较每张截图与前一张
2. 识别之前未见过的消息
3. 只将唯一消息添加到最终输出

示例：
```
截图 1: [A, B, C]
截图 2: [A, B, C, D, E]  ← A, B, C 已见过
截图 3: [C, D, E, F]     ← C, D, E 已见过
输出: [A, B, C, D, E, F] ← 只有 F 是新的
```

### 使用场景

- ✅ **归档工作聊天** - 保存重要的项目讨论记录
- ✅ **文档备份** - 防止聊天记录丢失
- ✅ **报告整理** - 从对话中提取关键信息
- ✅ **知识管理** - 将聊天转换为可搜索的文档
- ✅ **法律证据** - 保存沟通记录

### 故障排查

#### 截图失败

**问题：** 脚本报截图错误

**解决方案：**
```bash
# 检查 Peekaboo 权限
peekaboo permissions

# 验证窗口 ID
peekaboo list windows --app "应用名" --json

# 确保窗口有焦点
peekaboo click --pid <PID> --window-id <WINDOW_ID> --coords 450,400
```

#### 截图重复

**问题：** 截图看起来相同

**解决方案：**
- 增加 `SLEEP_TIME`：`SLEEP_TIME=1.0 ./chat-capture.sh ...`
- 确保 `PageDown` 正常工作：检查内容是否在滚动
- 验证窗口是否有焦点

#### 文字识别不准确

**问题：** 提取的文字有错误

**解决方案：**
- 使用高清截图（默认启用 `--retina`）
- 调整窗口大小以获得更好的文字可见性
- 手动编辑生成的 Markdown 文件
- 确保截图质量良好（不模糊）

#### 无法滚动到底部

**问题：** 聊天记录很长

**解决方案：**
```bash
# 分批运行
./chat-capture.sh <PID> <WINDOW_ID> 1 100   # 第一批
./chat-capture.sh <PID> <WINDOW_ID> 101 100 # 从第101张继续
```

### 性能

- **截图速度：** ~2 张/秒
- **提取时间：** ~3-5 秒/张（OCR）
- **100 张截图总时间：** ~5-8 分钟

### 局限性

- **平台：** 仅限 macOS（需要 Peekaboo）
- **图像识别准确率：** 取决于截图质量
- **复杂内容：** 表情、图片和文件可能无法识别
- **建议人工检查：** 始终检查输出是否有错误

### 贡献

欢迎贡献！请随时提交问题或拉取请求。

改进方向：
- 支持更多平台（Windows、Linux）
- 更好的 OCR 准确率
- 支持图片和文件附件
- 情感分析和关键词提取
- 自动摘要生成

### 许可证

MIT License - 可根据需要自由使用和修改。

### 致谢

- **Peekaboo** - macOS UI 自动化工具
- **OpenClaw** - AI 智能体框架
- **OCR 技术** - 图像文字提取

### 更新日志

#### v1.0 (2026-03-08)
- 初始发布
- PageDown 滚动自动截图
- OCR 文字提取
- 智能去重
- Markdown 输出

---

**Language:** English | 中文

**GitHub:** https://github.com/YuxuanXiu/openclaw-skill-chat--exporter

**Author:** 休语 & 呆呆

**Date:** 2026-03-08
