#!/usr/bin/env bash
# 简单 HTTP 压测助手（基于 wrk）

set -e

if ! command -v wrk >/dev/null 2>&1; then
  echo "错误: 未找到 wrk 命令，请先安装 wrk。"
  echo "Ubuntu 示例: sudo apt update && sudo apt install -y wrk"
  exit 1
fi

read -rp "请输入要压测的 URL (例如 http://127.0.0.1:8080/): " URL
if [ -z "$URL" ]; then
  echo "URL 不能为空"
  exit 1
fi

read -rp "线程数量 [默认 8]: " THREADS
THREADS=${THREADS:-8}

read -rp "并发连接数（-c）[默认 100]: " CONC
CONC=${CONC:-100}

read -rp "持续时间（秒）[默认 60]: " DURATION
DURATION=${DURATION:-60}

echo
echo "即将开始压测："
echo "  URL        = $URL"
echo "  线程数     = $THREADS"
echo "  并发数(-c) = $CONC"
echo "  时长       = ${DURATION}s"
echo

OUT_DIR="$HOME/http_bench_reports"
mkdir -p "$OUT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
RAW_FILE="$OUT_DIR/wrk_${TS}.txt"
HTML_FILE="$OUT_DIR/report_${TS}.html"

echo "压测中，请稍候..."
echo

# 运行 wrk，并把输出保存下来
wrk -t"$THREADS" -c"$CONC" -d"${DURATION}s" "$URL" | tee "$RAW_FILE"

# 生成一个简单的 HTML 报告，把 wrk 输出包在 <pre> 里
{
  echo "<!doctype html>"
  echo "<html><head><meta charset=\"utf-8\"><title>HTTP Bench Report - $TS</title>"
  echo "<style>body{font-family:monospace;background:#111;color:#eee;padding:20px;}pre{white-space:pre-wrap;}</style>"
  echo "</head><body>"
  echo "<h1>HTTP Bench Report</h1>"
  echo "<p><b>URL:</b> $URL</p>"
  echo "<p><b>线程数:</b> $THREADS, <b>并发:</b> $CONC, <b>时长:</b> ${DURATION}s</p>"
  echo "<hr>"
  echo "<pre>"
  # HTML 转义
  sed 's/&/\&amp;/g; s/</\&lt;/g' "$RAW_FILE"
  echo "</pre>"
  echo "</body></html>"
} > "$HTML_FILE"

echo
echo "压测完成。"
echo "原始结果文件: $RAW_FILE"
echo "HTML 报告文件: $HTML_FILE"
echo "在浏览器中打开以下网址查看结果："
echo
echo "  file://$HTML_FILE"
echo
