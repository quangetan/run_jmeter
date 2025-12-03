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
