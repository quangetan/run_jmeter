#!/usr/bin/env bash
# 梯度压测脚本（基于 wrk）
# 用法:
#   ./gradient-bench.sh [URL] [THREADS] [DURATION] ["并发列表"]
# 示例:
#   ./gradient-bench.sh http://47.128.230.2:7765/ 8 30 "50 100 200 300 400 500"

set -e

if ! command -v wrk >/dev/null 2>&1; then
  echo "错误: 未找到 wrk 命令，请先安装 wrk。"
  echo "Ubuntu 示例: sudo apt update && sudo apt install -y wrk"
  exit 1
fi

URL="${1:-http://47.128.230.2:7765/}"
THREADS="${2:-8}"
DURATION="${3:-30}"
CONC_LIST="${4:-50 100 200 300 400 500}"

OUT_ROOT="$HOME/http_bench_gradients"
mkdir -p "$OUT_ROOT"

TS="$(date +%Y%m%d_%H%M%S)"
OUT_DIR="$OUT_ROOT/run_${TS}"
mkdir -p "$OUT_DIR"

SUMMARY_CSV="$OUT_DIR/summary.csv"
echo "concurrency,requests_per_sec,avg_latency,raw_file" > "$SUMMARY_CSV"

echo "URL      : $URL"
echo "线程数   : $THREADS"
echo "时长     : ${DURATION}s"
echo "并发梯度 : $CONC_LIST"
echo "输出目录 : $OUT_DIR"
echo

for C in $CONC_LIST; do
  echo "=============================="
  echo "并发: $C"
  echo "=============================="

  RAW_FILE="$OUT_DIR/wrk_c${C}.txt"

  wrk -t"$THREADS" -c"$C" -d"${DURATION}s" "$URL" | tee "$RAW_FILE"

  # 抽取 Requests/sec 和第一行 Latency
  REQ_PER_SEC="$(grep -E 'Requests/sec' "$RAW_FILE" | awk '{print $2}')"
  AVG_LATENCY_RAW="$(grep -E 'Latency' "$RAW_FILE" | head -n1 | awk '{print $2}')"

  # 写到 summary.csv
  echo "$C,$REQ_PER_SEC,$AVG_LATENCY_RAW,$RAW_FILE" >> "$SUMMARY_CSV"

  echo "=> C=$C, Requests/sec=$REQ_PER_SEC, Avg Latency=$AVG_LATENCY_RAW"
  echo
done

echo "全部梯度压测完成。汇总表在：$SUMMARY_CSV"
echo "你可以用 cat 或者导入 Excel 打开："
echo "  cat \"$SUMMARY_CSV\""
