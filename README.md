# Simple JMeter HTTP Benchmark

一个简单的 JMeter 压测脚本，支持通过命令行指定：

- URL
- 并发数（线程数）
- 每个用户循环次数
- Ramp 时间（多少秒内把所有用户拉满）

会自动生成 JMeter HTML 报告。

## 前置条件

Linux 环境，已安装 JMeter，并且命令 `jmeter` 可用。

以 Ubuntu 为例：

```bash
sudo apt update
sudo apt install -y openjdk-11-jre

# 下载并解压 JMeter（也可以自己去官网下新版）
cd ~
wget https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.6.3.tgz
tar -xzf apache-jmeter-5.6.3.tgz

# 把 jmeter 加到 PATH（示例）
echo 'export PATH="$HOME/apache-jmeter-5.6.3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

使用方法
# 1. 克隆本项目
git clone <your-repo-url> jmeter-bench
cd jmeter-bench

# 2. 赋予脚本执行权限
chmod +x run_jmeter.sh

# 3. 运行压测
./run_jmeter.sh URL 并发数 每用户循环次数 ramp时间(秒)

# 示例：对 http://47.128.230.2:7765/ 做 500 并发，循环 1 次，50 秒内拉满
./run_jmeter.sh http://47.128.230.2:7765/ 500 1 50

运行完成后，会在项目目录下生成类似这样的目录：

•  results_20251203_141500/
◦  results.jtl   —— 原始结果文件
◦  report/       —— HTML 报告目录
▪  index.html —— 报告入口

用浏览器打开 report/index.html 即可查看图形化报表（吞吐、响应时间分布、错误率、P90/P95/P99 等）。

参数说明
./run_jmeter.sh URL THREADS LOOPS RAMP

URL      : 目标地址（如 http://47.128.230.2:7765/）
THREADS  : 并发用户数（JMeter 线程数）
LOOPS    : 每个用户循环次数（压多少轮）
RAMP     : ramp-up 时间（秒），在多少秒内把 THREADS 个用户全部拉起来

注意事项

•  如果机器性能一般，直接 500 并发可能会把压测机打满，建议先从 50、100 开始试，再慢慢加。
•  URL 支持端口和路径，例如：
◦  http://example.com
◦  http://example.com:8080/api/test?x=1
•  脚本会自动解析协议/域名/端口/路径，传给 JMeter。
