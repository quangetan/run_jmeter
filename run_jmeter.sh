#!/usr/bin/env bash

# 用法:
#   ./run_jmeter.sh URL THREADS LOOPS RAMP
# 示例:
#   ./run_jmeter.sh http://47.128.230.2:7765/ 500 1 50

set -e

if [ "$#" -ne 4 ]; then
  echo "用法: $0 URL 并发数(THREADS) 每用户循环次数(LOOPS) ramp时间秒(RAMP)"
  echo "示例: $0 http://47.128.230.2:7765/ 500 1 50"
  exit 1
fi

URL="$1"
THREADS="$2"
LOOPS="$3"
RAMP="$4"

# 简单校验
if ! [[ "$THREADS" =~ ^[0-9]+$ ]] || ! [[ "$LOOPS" =~ ^[0-9]+$ ]] || ! [[ "$RAMP" =~ ^[0-9]+$ ]]; then
  echo "错误: 并发数/循环次数/ramp 时间必须是整数"
  exit 1
fi

# 解析协议
PROTO="$(echo "$URL" | sed -E 's#^(https?)://.*#\1#')"
if [ -z "$PROTO" ] || { [ "$PROTO" != "http" ] && [ "$PROTO" != "https" ]; }; then
  PROTO="http"
fi

# 去掉协议前缀
URL_NOPROTO="${URL#*://}"

# HOST:PORT/REST
HOSTPORT="${URL_NOPROTO%%/*}"
REST="${URL_NOPROTO#"$HOSTPORT"}"

# 路径（含 query）
if [ -z "$REST" ] || [ "$REST" = "$URL_NOPROTO" ]; then
  PATH="/"
else
  PATH="$REST"
fi

# 主机 & 端口
if [[ "$HOSTPORT" == *:* ]]; then
  DOMAIN="${HOSTPORT%%:*}"
  PORT="${HOSTPORT##*:}"
else
  DOMAIN="$HOSTPORT"
  if [ "$PROTO" = "https" ]; then
    PORT=443
  else
    PORT=80
  fi
fi

# JMeter 可执行文件：假设已在 PATH 中
JMETER_BIN="${JMETER_BIN:-jmeter}"

# 当前脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# JMX 模板路径
JMX_TEMPLATE="$SCRIPT_DIR/http_template.jmx"
if [ ! -f "$JMX_TEMPLATE" ]; then
  echo "未找到 JMeter 模板: $JMX_TEMPLATE"
  echo "请先创建 http_template.jmx（我前面给的那个 XML 模板）"
  exit 1
fi

# 结果 & 报告目录
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
RESULTS_DIR="$SCRIPT_DIR/results_${TIMESTAMP}"
JTL_FILE="$RESULTS_DIR/results.jtl"
REPORT_DIR="$RESULTS_DIR/report"

mkdir -p "$RESULTS_DIR"

echo "=============================================="
echo "JMeter 压测启动"
echo "URL      : $URL"
echo "协议     : $PROTO"
echo "域名     : $DOMAIN"
echo "端口     : $PORT"
echo "路径     : $PATH"
echo "并发(THREADS) : $THREADS"
echo "循环(LOOPS)   : $LOOPS"
echo "ramp(秒)      : $RAMP"
echo "结果目录      : $RESULTS_DIR"
echo "=============================================="

# 运行 JMeter（非 GUI + 生成 HTML 报告）
"$JMETER_BIN" -n \
  -t "$JMX_TEMPLATE" \
  -JDOMAIN="$DOMAIN" \
  -JPORT="$PORT" \
  -JPROTOCOL="$PROTO" \
  -JPATH="$PATH" \
  -JTHREADS="$THREADS" \
  -JLOOPS="$LOOPS" \
  -JRAMP="$RAMP" \
  -l "$JTL_FILE" \
  -e -o "$REPORT_DIR"

echo
echo "压测完成！"
echo "JTL 结果文件 : $JTL_FILE"
echo "HTML 报告目录: $REPORT_DIR"
echo "用浏览器打开: $REPORT_DIR/index.html"
