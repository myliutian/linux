## HDFS相关
### 基本命令
```sh
# ls
# 列出hdfs文件系统根目录下的目录和文件
hadoop fs -ls  /
# 列出hdfs文件系统所有的目录和文件
hadoop fs -ls -R /

# put
# hdfs file的父目录一定要存在，否则命令不会执行
hadoop fs -put < local file > < hdfs file >
# hdfs dir 一定要存在，否则命令不会执行
hadoop fs -put  < local file or dir >...< hdfs dir >
# 从键盘读取输入到hdfs file中，按Ctrl+D结束输入，hdfs file不能存在，否则命令不会执行
hadoop fs -put - < hdsf  file>

# rm
# 每次可以删除多个文件或目录
hadoop fs -rm < hdfs file > ...
hadoop fs -rm -r < hdfs dir>...

# erasure coding
# 查看编码块的分布
hdfs fsck /rs-6-3/file8064M -files -blocks -locations
hdfs fsck /rs-3-2/file8064M -files -blocks -locations

# 停止datanode进程
hdfs --daemon stop datanode

hadoop fs -rm /rs-6-3/*
hdfs ec -setPolicy -path / -policy RS-6-3-1024k

hdfs dfs -mkdir /rs-6-3
hdfs ec -setPolicy -path /rs-6-3 -policy RS-6-3-1024k
hdfs ec -getPolicy -path /rs-6-3
hadoop fs -put ~/TestFile/file8064M /rs-6-3/

hdfs ec -enablePolicy  -policy RS-3-2-1024k
hdfs dfs -mkdir /rs-3-2
hdfs ec -setPolicy -path /rs-3-2 -policy RS-3-2-1024k
hdfs ec -getPolicy -path /rs-3-2
hadoop fs -put ~/TestFile/file8064M /rs-3-2/

hdfs ec -enablePolicy  -policy RS-10-4-1024k
hdfs dfs -mkdir /rs-10-4
hdfs ec -setPolicy -path /rs-10-4 -policy RS-10-4-1024k
hdfs ec -getPolicy -path /rs-10-4

```
[这里](http://bigdatastudy.net/show.aspx?id=458&cid=8) 有更多关于EC的Hadoop命令

### 实验相关
```sh
# 编译hadoop源码
mvn package -Pdist,native -DskipTests -Dtar

# 常用bash脚本命令
for i in {11..12};do ssh hadoop@n$i "sudo mount /dev/sdj1 /home/hadoop/echadoop";done

# 收集log
for i in {2,3,4};do ssh hadoop@node$i "hostname;tail -n 10 ~/echadoop/hadoop-3.1.2/logs/hadoop-hadoop-datanode-node$i.log" >> test;done

# 生成任意大小的文件
# if为输入文件名，of为输出文件名，bs为单次读取和写入的字节数，count为拷贝的次数，因而总文件大小为bs*count
# if为/dev/urandom——提供不为空字符的随机字节数据流
dd if=/dev/urandom of=file19680M count=19680 bs=1M
# 文件中的内容全部为\0空字符，输入文件是/dev/zero——一个特殊的文件，提供无限个空字符（NULL、0x00）
dd if=/dev/zero of=my_new_file count=102400 bs=1024
```
[这里](https://www.jianshu.com/p/81fc1297a7c4) 有更多关于Linux生成大文件的命令

## Linux相关

### 编译安装Linux内核
```sh
# step1: 在 https://cdn.kernel.org/pub/linux/kernel 下载要编译安装的内核的源码，例如要编译3.13.0版本的内核，则下载linux-3.13.tar.gz 或 linux-3.13.tar.xz
wget https://cdn.kernel.org/pub/linux/kernel/v3.0/linux-3.13.tar.gz
tar zxvf linux-3.13.tar.gz

# step2: 生成.config文件
cd linux-3.13/
# 方式一：适合无控制台使用
cp /boot/config-$(uname -r) .config
# 需要sudo权限，执行指令后一直回车（选择默认值）
make oldconfig
# 方式二：适合有控制台使用
# 需要sudo权限，进入后先save，再exit
make menuconfig

# step3：编译 & 安装（需要sudo权限，并严格按照下面的顺序进行make）
make -j `nproc`
make modules_install
make install

make -j `nproc` && make modules_install && make install

# step4：更新grub
# 需要sudo权限
grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

# step5: 设置开机启动的内核版本
# 查看可用的内核版本（需要sudo权限）
grep menuentry /boot/efi/EFI/centos/grub.cfg
# 选择想要启动的内核版本，并设置序号（从0开始编号，指令需要sudo权限）
# 例如想启动的内核的标号是1
grub2-set-default 1

# step6：重启
sudo reboot

# 相关指令
# 验证
uname -r
# 查看安装的内核（非编译安装）
rpm -qagrep -i kernel
rpm -ga kernel
```

参考资料：
路路的博客（适用于Ubuntu）：https://blog.csdn.net/ibless/article/details/82349507
CentOS换内核：
https://zskjohn.blog.csdn.net/article/details/108931626?spm=1001.2101.3001.6650.1&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-108931626-blog-92394180.pc_relevant_recovery_v2&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-108931626-blog-92394180.pc_relevant_recovery_v2&utm_relevant_index=2

https://blog.csdn.net/xj178926426/article/details/78727991?spm=1001.2101.3001.6650.14&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-14-78727991-blog-81479603.pc_relevant_3mothn_strategy_and_data_recovery&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-14-78727991-blog-81479603.pc_relevant_3mothn_strategy_and_data_recovery&utm_relevant_index=15

### 查看、加载、卸载Linux kernel的模块
```sh
# 查看当前运行的内核版本的所有模块
find /lib/modules/$(uname -r) -type f -name '*.ko*' | more
find /lib/modules/$(uname -r) -type f -name 'hydra.ko' | more
# 查看已加载的内核模块，一般配合grep使用
lsmod
lsmod | grep hydra
# 加载内核模块
sudo modprobe hydra
# 确认加载成功
sudo modprobe hydra --first-time
# 卸载内核模块
sudo modprobe -r hydra
# 确认卸载成功
sudo modprobe -r hydra --first-time
```
[更多](https://phoenixnap.com/kb/modprobe-command) 参数。

### 查看登录该服务器的所有用户
```sh
# 所有信息
w
```

### 挂载磁盘相关命令
```sh
# 查看所有磁盘的顺序及类型
lsscsi

# 查看当前已挂载的磁盘
df -h

# 对已有数据的磁盘重新进行挂载，para1=磁盘文件路径，para2=挂载文件夹路径
sudo mount /dev/sdj1 /home/hadoop/echadoop

# 取消挂载,参数可以是设备，或者挂载点
sudo umount /dev/sdh1
sudo umount /home/hadoop/echadoop
# FAQ: target is busy
sudo fuser -cuk /home/hadoop/echadoop

# 添加开机自动挂载硬盘时要以UUID的方式，不要用绝对路径的方式，因为硬盘再每次启动后顺序可能会变
# 查看UUID
sudo blkid
# 注意：每次重建文件系统（格式化等），UUID都会变

# 添加开机自动挂载
sudo vi /etc/fstab
UUID=5c3dcf06-b781-4f5b-8542-3077be342814 /home/hadoop/echadoop ext4 defaults 0 0
UUID= /home/hadoop/echadoop ext4 defaults 0 0
UUID= /home/hadoop/TFiles ext4 defaults 0 0

# 查看可挂载的磁盘都有哪些
sudo fdisk -l

# 磁盘分区
sudo fdisk /dev/sdi
键入：m，可以看到帮助信息，
键入：n，添加新分区
键入：p，选择添加主分区
键入：l，选择主分区编号为1，这样创建后的主分区为sdi1
之后，fdisk会让你选择该分区的开始值和结束值，直接回车
最后键入：w，保存所有并退出，完成新硬盘的分区。

# umount时出现device is busy
sudo fuser -km /data

# 删除磁盘所有分区
sudo mkfs.ext4 /dev/sdb

# 格式化磁盘
sudo mkfs -t ext4 /dev/sdi1
# 格式完磁盘之后就可以挂载，然后设置开机自动挂载

# bash
sleep 5s #延迟5s
sleep 5m #延迟5m
sleep 5h #延迟5h
sleep 5d #延迟5d

# 压缩
tar zcvf FileName.tar.gz DirName
# 解压
tar zxvf FileName.tar.gz

# 使用iperf测量worker1和worker2的带宽
# 在worker1运行
iperf -s
# 在worker2运行
iperf -c worker1

# 脚本后台运行，不受关闭终端的影响
nohup sh autoRun.sh &

# 查看后台运行的脚本
ps -aux|grep autoRun.sh| grep -v grep
ps -aux|grep schemeAutoRun.sh| grep -v grep

ps -aux|grep workloadAutoRun.sh| grep -v grep
ps -aux|grep wSchemeAutoRun.sh| grep -v grep

ps -aux|grep Simulate| grep -v grep

ps -aux|grep recovery| grep -v grep

ps -aux|grep heterogeneousAutoRun.sh| grep -v grep
ps -aux|grep heterogeneousSchemeAutoRun.sh| grep -v grep

# TC限速
sudo tc qdisc add dev ens9 root tbf rate 240Mbit latency 50ms burst 15kb
# 解除TC限速
sudo tc qdisc del dev ens9 root
# 列出所有的TC限速策略
sudo tc -s qdisc ls dev ens9 

# TC放大带宽 
for j in {1..19};do ssh hadoop@n$j "hostname;sudo tc qdisc add dev ens9 root tbf rate 280Mbit latency 50ms burst 250kb";done
# TC 30MB/s
for j in {1..19};do ssh hadoop@n$j "hostname;sudo tc qdisc add dev ens9 root tbf rate 250Mbit latency 50ms burst 250kb";done
for j in {1..19};do ssh hadoop@n$j "hostname;sudo tc qdisc del dev ens9 root";done

for j in {1..19};do ssh hadoop@n$j "hostname;sudo ~/wondershaper/wondershaper -a ens9 -d 240000 -u 240000";done
for j in {1..19};do ssh hadoop@n$j "hostname;sudo ~/wondershaper/wondershaper -c -a ens9";done

cd /home/qingya/hadoop-3.1.2-src/hadoop-hdfs-project/hadoop-hdfs-client
mvn package -Pdist -Dtar -DskipTests
cp /home/qingya/hadoop-3.1.2-src/hadoop-hdfs-project/hadoop-hdfs-client/target/hadoop-hdfs-client-3.1.2.jar /home/qingya/compile

cd /home/hadoop/hadoop-3.1.2-src/hadoop-hdfs-project/hadoop-hdfs
mvn package -Pdist -Dtar -DskipTests
scp -r /home/hadoop/hadoop-3.1.2-src/hadoop-hdfs-project/hadoop-hdfs/target/hadoop-hdfs-3.1.2/share/hadoop/hdfs hadoop@n$i:~/echadoop/hadoop-3.1.2/share/hadoop/

cp ~/SLECTIVEEC-src/*.java /home/hadoop/hadoop-3.1.2-src/hadoop-hdfs-project/hadoop-hdfs/src/main/java/org/apache/hadoop/hdfs/server/blockmanagement/
sh ~/mvnHadoopSrc.sh

for i in {5..6};do ssh hadoop@n$i "hdfs --daemon stop datanode";done
for i in {5..7};do ssh hadoop@n$i "hdfs --daemon stop datanode";done

# 查看每个节点的上下行已使用的带宽（网卡使用状态）
ifstat -t -i ens9 1 1
ifstat -t -i ib0
ifstat -t -i ib0 1 1
ifstat -t -i ens4f1 1 1

for i in {1..19};do ssh hadoop@n$i "hostname;ifstat -t -i ib0 1 1";done
for i in {1..19};do ssh hadoop@n$i "hostname;sudo ~/wondershaper/wondershaper -c -a ens9 &";done

scp -P 12345 -r ./0.9 hadoop@210.45.114.30:/home/hadoop/
scp -P 12345 ./argsTest.sh hadoop@210.45.114.30:/home/hadoop/

for i in {1..30};do ssh hadoop@node$i "hostname;sudo systemctl stop firewalld.service;sudo systemctl disable firewalld.service;sudo firewall-cmd --state";done

for i in {2..30};do scp ./workers hadoop@node$i:/home/hadoop/echadoop/hadoop-3.1.2/etc/hadoop/;done

for i in {1..30};do ssh hadoop@node$i "hostname;jps";done

# 让Simulate可用的JVM的内存大小从32m到450G
java -Xms32m -Xmx460800m Simulate

# 统计当前目录下文件的个数（不包括目录）
ls -l | grep "^-" | wc -l
# 统计当前目录下文件的个数（包括子目录）
ls -lR| grep "^-" | wc -l
# 查看某目录下文件夹(目录)的个数（包括子目录）
ls -lR | grep "^d" | wc -l

# 查看centos的版本
cat /etc/redhat-release / lsb_release -a / cat /etc/issue
# 查看OS版本
cat /etc/os-release
# 查看内核版本
cat /proc/version / uname -a

# 总核数 = 物理CPU个数 X 每颗物理CPU的核数 
# 总逻辑CPU数 = 物理CPU个数 X 每颗物理CPU的核数 X 超线程数
# 查看物理CPU个数
cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l
# 查看每个物理CPU中core的个数(即核数)
cat /proc/cpuinfo| grep "cpu cores"| uniq
# 查看逻辑CPU的个数（总数）
cat /proc/cpuinfo| grep "processor"| wc -l
# 查看CPU信息（型号）
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c
# 查看机器型号（机器硬件型号）
sudo dmidecode | grep "Product Name"
sudo dmidecode
# 查看服务器的型号
sudo dmidecode | grep -A4 "System Information"
# 查看linux 系统内存大小的信息，可以查看总内存，剩余内存，可使用内存等信息  
cat /proc/meminfo
```

### 统计字符出现的次数
```sh
# vim
:%s/objStr//gn

# grep, 单个字符串
grep -o objStr  filename|wc -l
# grep, 多个字符串
grep -o ‘objStr1\|objStr2'  filename|wc -l  #直接用\| 链接起来即可
```
### Linux查找文件或内容
```sh
# 在一个目录下的所有文件中查找文件名
# 例如：将当前目录及其子目录下所有文件后缀为 .c 的文件列出来
find . -name "*.cc"
# 在一个目录下的所有文件（内容）中查找字符串
find . -iname '*.h' | xargs grep "search string" -sl
```
[参数解释-找内容](https://blog.51cto.com/u_15239532/2835499)
[参数解释-找文件名](https://www.runoob.com/linux/linux-comm-find.html)

### Linux比较两个文件内容
```sh
# 比较文件
diff filea fileb
# 比较文件夹
# r：递归比较所有文件；q：只输出哪些文件是不一样的；N：In directory comparison, if a file is found in only one directory, treat it as present but empty in the other directory.
diff -Nrq a b
```
[更多比较参数](https://blog.csdn.net/mosesmo1989/article/details/51093631)

### Linux根据进程名获取pid
```sh
# 根据进程名获取pid
pgrep -f name
# 根据进程名kill一个进程
pkill -f name
```
[More](https://blog.csdn.net/baidu_33850454/article/details/78568392)

### 查找文件
https://www.cnblogs.com/wuchanming/p/4013517.html

### Linux端口related
```sh
# 范围：0~65535，0~1023被OS使用
# 显示所有端口和所有对应的程序
netstat -atulnp | grep [port no]
# 查看某一端口的占用情况
sudo lsof -i:[port no]
# 清除端口占用
sudo kill -9 $(lsof -i:端口号 -t)
```

### CGroup
```sh
# 限速目录
/sys/fs/cgroup/blkio
blkio.throttle.read_bps_device
blkio.throttle.read_iops_device
blkio.throttle.write_bps_device
blkio.throttle.write_iops_device
"8:16 52428800" > blkio.throttle.read_bps_device

# bash按行读文件
while read line;do echo $line;done < /home/hadoop/raid2pp/parsingdisks/restrictions.txt

# cgroup磁盘限速
while read line;do echo $line >> blkio.throttle.read_bps_device;done < /home/hadoop/raid2pp/parsingdisks/restrictions.txt
while read line;do echo $line >> blkio.throttle.write_bps_device;done < /home/hadoop/raid2pp/parsingdisks/restrictions.txt
# 取消限速
while read line;do echo $line >> blkio.throttle.read_bps_device;done < /home/hadoop/raid2pp/parsingdisks/restore.txt
while read line;do echo $line >> blkio.throttle.write_bps_device;done < /home/hadoop/raid2pp/parsingdisks/restore.txt

# 查看ib
for i in {1..19};do ssh hadoop@n$i "hostname;ifstat -t -i ib0 1 1";done
```

### 在linux系统中查看cacheline的大小
```sh
# 在/sys/devices/system/cpu/cpu1/cache路径下，有index文件夹（index0, index1, index2, index3），四者分别L1数据cache，L1指令cache，L2cache，L3cache
# 每个文件夹下有多个cache相关信息，例如cacheline_size就是cacheline的大小，x86结构的 cacheline 一般为64字节
cat /sys/devices/system/cpu/cpu1/cache/index0/coherency_line_size 
```

### 后台执行命令screen
```sh
# 开启一个session
screen

# 挂起一个session
ctrl+a d

# 列出所有session
screen -ls

# kill一个已经开启的session
# 1. 使用screen的名字，kill掉
screen -S session_name -X quit
# 2. 激活screen，并利用exit退出并kill掉session
screen -r session_name
# 3. 在session的窗口中exit
exit
```

### CentOS防火墙
```sh
# 查看防火墙状态
firewall-cmd --state
# 停止firewall
systemctl stop firewalld.service
# 禁止firewall开机启动
systemctl disable firewalld.service 
```

### 高效的Vi的命令

```sh
# 跳转指定行
:rowNum

# 行首 & 行位
shift+4 & shift+6
```

### Git

```sh
# fatal: remote origin already exists
git remote rm origin
git remote add origin git@github.com:FBing/java-code-generator

# 放弃修改，强制覆盖本地代码
git fetch --all
git reset --hard origin/master 
git pull

```

### Kernel version and transparent huge page configuration

```sh
# 开启透明大页
echo 'always' > /sys/kernel/mm/transparent_hugepage/enabled
# 关闭透明大页
echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled

# 查看大页使用情况
# 系统级
cat /proc/meminfo | grep AnonHugePages
# 进程级
cat /proc/[$PID]/smaps | grep AnonHugePages

# 查看cpu core的信息
numactl --hardware
```

## Crail

```sh
# 编译
rm -rf /home/hadoop/incubator-crail/assembly/target/apache-crail-1.3-incubating-SNAPSHOT-bin
mvn -DskipTests install

crail iobench -t write -s 2801664 -k 1 -m false -f /dc118836v2dbe7d36cb3540033blobsd759867d

crail iobench -t write -s 2342912 -k 1 -m false -f /260f35e1v248deada7a65747a0blobse23bc03c

crail iobench -t write -s 2670592 -k 1 -m false -f /dc118836v2f9ac28b0b2ec79aablobse90f9c2d

crail iobench -t write -s 117964800 -k 1 -m false -f /786b3803v2987f5d81ad3ea282blobs99686f6f

# iobench
crail iobench -t write -s $((1024*1024)) -k 1000
crail iobench -t write -s $((1024*1024)) -k 1 -m false -f /tmp.dat
crail iobench -t writeReplicas -s $((4*1024)) -k 1000 -f /tmp.dat
crail iobench -t write -s $((1024*1024)) -k 1 -m false -f /tmp.dat
crail iobench -t readReplicas -k 1000 -f /tmp.dat

crail iobench -t writeECCache -s $((1024*1024)) -r $((256*1024)) -k 1000 -f /tmp.dat
crail iobench -t readSequential -s $((1024*1024)) -k 1000 -m false -f /tmp.dat

crail iobench -t readNormalErasureCoding -k 1000 -f /tmp.dat
crail iobench -t degradeReadReplicas -k 1 -f /tmp.dat
crail iobench -t recoveryReplicas -k 1 -f /tmp.dat

crail iobench -t degradeReadErasureCoding -k 1 -f /tmp.dat
crail iobench -t normalRecoveryErasureCoding -k 1 -f /tmp.dat
crail iobench -t pipelineDegradeReadErasureCoding -k 1 -f /tmp.dat -n $((64*1024))
crail iobench -t recoveryPipelineErasureCoding -k 1 -f /tmp.dat -n $((64*1024))
crail iobench -t monECDegradeReadErasureCoding -k 1 -f /tmp.dat -a 64 -n $((64*1024))
crail iobench -t monECRecoveryErasureCoding -k 1 -f /tmp.dat -a 64 -n $((64*1024))
crail iobench -t pureMonECDegradeReadErasureCoding -k 1 -f /tmp.dat -a 64
crail iobench -t pureMonECRecoveryErasureCoding -k 1 -f /tmp.dat -a 64

ycsbTest(ycsbRequestType, size, encodingSplitSize, pureMonECSubStripeNum, transferSize, isPureMonEC);
user5464797676921564295
# ycsb test [replicasYCSB|eccacheYCSB|ecpipelineYCSB|pureMonECYCSB|monECYCSB]
crail iobench -t ycsbTest -y replicasYCSB -s $((1024*1024))
crail iobench -t ycsbTest -y eccacheYCSB -s $((1024*1024)) -r $((256*1024))
crail iobench -t ycsbTest -y ecpipelineYCSB -s $((1024*1024)) -r $((64*1024))
crail iobench -t ycsbTest -y pureMonECYCSB -s $((1024*1024)) -r $((256*1024)) -a 64 -i true
crail iobench -t ycsbTest -y monECYCSB -s $((1024*1024)) -n $((32*1024)) -a 64

# ECCache
crail iobench -t writeECPipeline -s $((3*256*1024)) -r $((256*1024)) -k 1500 -f /tmp1.dat
# 64k pipeline
crail iobench -t writeECPipeline -s $((3*256*1024)) -r $((64*1024)) -k 1500 -f /tmp2.dat 
# 4k pureMonEC
crail iobench -t writeECPipeline -s $((1024*1024)) -r $((256*1024)) -k 1 -f /tmp.dat -a 64 -i true
# 4k MonEC
crail iobench -t writeMicroEC -s $((1024*1024)) -k 1500 -a 64 -n $((16*1024)) -f /tmp1.dat
crail iobench -t multiWriteMicroEC -s $((1024*1024)) -k 1500 -a 64 -n $((16*1024)) -f /tmp1.dat
crail iobench -t writeMicroEC_slicing -s $((1024*1024)) -k 1500 -a 64 -n $((256*1024)) -f /tmp1.dat
crail iobench -t writeMicroEC_asyncFixed -s $((1024*1024)) -k 1500 -a 64 -n $((16*1024)) -f /tmp1.dat
crail iobench -t writeMicroEC_asyncFinished -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat
crail iobench -t writeMicroEC_asyncNotFinished -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat

taskset -c 11 crail iobench -t writeMicroEC_asyncFixed -s $((1024*1024)) -k 1500 -a 64 -n $((16*1024)) -f /tmp1.dat
taskset -c 11 crail iobench -t writeMicroEC_asyncFinished -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat
taskset -c 11 crail iobench -t writeMicroEC_asyncNotFinished -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat

crail iobench -t testNativeEncoding -s $((1024*1024)) -k 1500
crail iobench -t testAsyncCodingSame -s $((16*1024)) -k 1500 -a 1
crail iobench -t testAsyncCodingSame -s $((3*256*1024)) -k 1500 -a 64
crail iobench -t testNativePureEncoding -s $((3*64*1024)) -k 1500 
crail iobench -t testNativePureEncoding -s $((6*256*1024)) -k 1500 
crail iobench -t testNativePureEncoding -s $((6*256*1024)) -k 1500 -a 64 -i true
crail iobench -t testNetworkLatency -s $((6*256*1024)) -k 1500 -f /n1.dat
crail iobench -t warmupCreateRedundantFile -k 1500 -f /w1.dat


crail iobench -t writeMicroEC_CodingFixed -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat
crail iobench -t writeMicroEC_CodingFinished -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat
crail iobench -t writeMicroEC_CodingDescent -s $((3*256*1024)) -k 1500 -a 64 -f /loop.dat
crail iobench -t writeMicroEC_CodingDescentRegenerated -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat
for i in {1..17};do crail iobench -t writeMicroEC -s $((1024*1024)) -k 10000 -a 64 -n $((16*1024)) -f /tmp${i}.dat;done


# breakdown test
crail iobench -t testAsyncCodingSame -s $((3*256*1024)) -k 1500 -a 64
crail iobench -t testNativePureEncoding -s $((3*64*1024)) -k 1500
crail iobench -t testNativePureEncoding -s $((6*256*1024)) -k 1500 -a 64 -i true
crail iobench -t testNetworkLatency -s $((6*256*1024)) -k 1500 -f /n1.dat


# MicroEC
crail iobench -t writeMicroEC_CodingDescent -s $((3*256*1024)) -k 1500 -a 64 -f /loop.dat
# ECCache
crail iobench -t writeECPipeline -s $((3*256*1024)) -r $((256*1024)) -k 1500 -f /tmp1.dat
# 64k pipeline
crail iobench -t writeECPipeline -s $((3*256*1024)) -r $((64*1024)) -k 1500 -f /tmp2.dat

crail iobench -t writeHydra -s $((4*256*1024)) -k 1500 -f /loop.dat


# shell
$CRAIL_HOME/bin/crail fs
$CRAIL_HOME/bin/crail fs -ls <crail_path>
$CRAIL_HOME/bin/crail fs -mkdir <crail_path>
$CRAIL_HOME/bin/crail fs -copyFromLocal <local_path> <crail_path>
$CRAIL_HOME/bin/crail fs -copyToLocal <crail_path> <local_path>
$CRAIL_HOME/bin/crail fs -cat <crail_path>

# 常用脚本
for i in {2..9};do scp -r /home/hadoop/incubator-crail/assembly/target/apache-crail-1.3-incubating-SNAPSHOT-bin/apache-crail-1.3-incubating-SNAPSHOT hadoop@worker$i:~/;done
for i in {2..9};do ssh hadoop@worker$i "hostname;rm /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/logs/*;rm -rf /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/tmp/*";done

# test ib
for i in {2..9};do ssh hadoop@node$i "hostname;ifstat -t -i ib0 1 1";done

# node2
for j in {3..9};do scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/core-site.xml hadoop@node$j:/home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/;done
for j in {3..9};do scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/crail-site.conf hadoop@node$j:/home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/;done
for j in {3..9};do scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/slaves hadoop@node$j:/home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/;done
for i in {3..9};do scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/lib/* hadoop@node$i:/home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/lib/;done

scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/core-site.xml hadoop@node1:/home/hadoop/incubator-crail/conf/
scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/crail-site.conf hadoop@node1:/home/hadoop/incubator-crail/conf/
scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/slaves hadoop@node1:/home/hadoop/incubator-crail/conf/

for i in {2..5};do ssh hadoop@node$i "hostname;sudo cp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/lib/libjnitest.so /usr/lib64/";done
for i in {2..5};do ssh hadoop@node$i "hostname;sudo rm /lib64/libjnitest.so";done


# 编译C代码到.so的流程（目前已经写成了编译脚本在node1的/home/hadoop/incubator-crail/scripts/compileSo.sh）
# 修改好Crailcoding.java以及microec.c源码
# step1：先编译jni的C接口
cd /home/hadoop/MicroEC/client/src/main/java
javah org.apache.crail.tools.Crailcoding
sudo cp org_apache_crail_tools_Crailcoding.h /home/hadoop/MicroEC/client/src/main/java/org/apache/crail/tools
# step2：编译C代码
cd /home/hadoop/MicroEC/client/src/main/java/org/apache/crail/tools
g++ -std=c++11 -I/usr/java/jdk1.8.0_221-amd64/include -I/usr/java/jdk1.8.0_221-amd64/include/linux -fPIC -shared microec.c -o libmicroec.so -L.  /usr/lib/libisal.so
# 注意：org_apache_crail_tools_Crailcoding.h文件中的c接口有时候自动编译出来函数名带有_1等，比如“Java_org_apache_crail_tools_Crailcoding_MicroecDecoding_1update_1networkinfo”，注意.c文件中需要对应改过来
```

## 统计代码行数
git统计的不准确

## 创建Linux新账户

```sh
# pm集群
# 1. 创建账号
# useradd -d  /home/ecgroup -m ecgroup -s /bin/bash
# 2. 配置账号密码（可选，配置成给定的密码方便后续管理）
# passwd ecgroup
# 3. 在/etc/sudoers配置一行，使得sudo su时不需要输入密码
# 4. 创建~/.ssh并拷贝已有公私钥，authorized_keys，known_hosts，并更改文件所属文件组
# chmod ~/.ssh
# chown -R ecgroup:ecgroup ~/.ssh
```

## Linux环境变量加载顺序
```sh
# 用户环境变量覆盖全局环境变量：修改~/.bashrc
# 注：新加路径要在$PATH之前
export PATH=/home/hadoop/bin:$PATH / export PATH=/home/ecgroup/bin:$PATH
```

## Swap

```sh
# 不重启电脑，禁用启用swap，立刻生效
# 禁用命令
sudo swapoff -a
# 启用命令
sudo swapon -a
# 查看是否关闭swap，显示0则表示关闭成功
sudo free -m
```

## 时间戳（C/C++）
```C
// 头文件
#include <time.h>
// 初始化两个变量
struct timespec time1 = {0, 0};
struct timespec time2 = {0, 0};
// 获得第一个时间戳
clock_gettime(CLOCK_REALTIME, &time1);
// 需要测试内容
// 获得第二个时间戳
clock_gettime(CLOCK_REALTIME, &time2);
// 计算时间，单位为ns
long encode_time=(time2.tv_sec-time1.tv_sec)*1000000000+(time2.tv_nsec-time1.tv_nsec);
```

## isocpus
```sh
# node14改的sudo vim /etc/grub2-efi.cfg
# 修改文件
sudo vim /etc/grub2-efi.cfg
or
sudo vim /etc/default/grub

# 同步一下
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo grub2-mkconfig -o /boot/grub/grub.cfg

# 重启后查看是否隔离成功
cat /proc/cmdline
```

## RDMA速度测试
```sh
# 使用[perftest](https://github.com/linux-rdma/perftest)进行测试
# 时延：ib_send_lat, ib_write_lat, ib_read_lat, ib_atomic_lat
# 带宽：ib_send_bw, ib_write_bw, ib_read_bw, ib_atomic_bw
# 查看网卡状态
ibstatus
# 查看设备号
ibdev2netdev or ibstat -l
# server端测试命令（以ib_read_lat为例），-a：Run sizes from 2 till 2^23；-F：Do not fail even if cpufreq_ondemand module
ib_read_lat -d mlx5_1 -a -F
ib_write_lat -d mlx5_1 -a -F

sudo ib_read_lat -d mlx4_0 -a -F
sudo ib_write_lat -d mlx4_0 -a -F
# client端测试命令
ib_read_lat -d mlx5_1 -a -F 10.0.0.62<server ip>
ib_write_lat -d mlx5_1 -a -F 10.0.0.62

sudo ib_read_lat -d mlx4_0 -a -F 10.0.0.2
sudo ib_write_lat -d mlx4_0 -a -F 10.0.0.2


# FAQ：
# 1. (client端) Completion with error at client. Failed status 10: wr_id 0 syndrom 0x88. scnt=1, ccnt=1.
# 解决方法：server端的指令没有加参数-a -F
# 2. (server端) Port number 1 state is Down. Couldn't set the link layer. Couldn't get context for the device.
# 解决方法：未使用-d指定设备，需要先查看设备号（mlx开头），再使用-d指定设备
```

## Mellanox OFED命令
```sh
#查看 Mellanox 网卡
lspci -v | grep Mellanox

# 查看Mellanox网卡驱动版本和固件版本（以node集群为例）
# ib0为网卡名，可以通过ifconfig查询
ethtool -i ib0 | grep -i firmware | cut -d ' ' -f 2-
ethtool -i ib0 | grep -i version
ethtool -i ib0

# mlx4_core可通过ibstatus查到（把编号换成core）
modinfo mlx4_core | grep ^version:|sed 's/version: * //g'
modinfo mlx4_core | grep ^version:
modinfo mlx4_core
```

## Mellanox OFED驱动安装
```sh
# 脚本 copyright@Daniel
#!/bin/bash

SUDO=
ID=12
IB_CONF=/etc/sysconfig/network-scripts/ifcfg-ib0


### Script starts here

## Check sudo priviledge
if test $(id -u) -eq 0; then
        SUDO=
else
        SUDO=sudo
fi

## Install dependencies
${SUDO} yum install -y gtk2 atk cairo gcc-gfortran tcsh libnl lsof tcl tk vim wget

## Work in temporary directory
cd ~
mkdir -p sxy/ib/mnt
cd sxy/ib
cp /home/hadoop/MLNX_OFED_LINUX-3.4-2.2.2.3-rhel7.3-x86_64-ext.iso ./
${SUDO} mount -o ro,loop MLNX_OFED_LINUX-3.4-2.2.2.3-rhel7.3-x86_64-ext.iso mnt
cd mnt
${SUDO} ./mlnxofedinstall

## Wait for confirmation to continue
echo
echo "Press [Enter] to continue or [Ctrl-C] to abort" && read

## Start service(1)
${SUDO} service openibd start

## Wait for confirmation to continue
echo
echo "Press [Enter] to continue or [Ctrl-C] to abort" && read

${SUDO} modprobe -rv ib_isert rpcrdma ib_srpt
${SUDO} service openibd start

## Start service(2)
${SUDO} chkconfig openibd on
${SUDO} service opensmd start
${SUDO} serviceig opensmd on

## Unmount
${SUDO} umount mnt

## Make out configuration for Infiniband adapter
${SUDO} touch ${IB_CONF}

echo
echo "Writing information to Infiniband configuration file(${IB_CONF}):"
echo -e "DEVICE=ib0\n"\
"BOOTPROTO=static\n"\
"IPADDR=10.0.0.${ID}\n"\
"NETMASK=255.255.255.0\n"\
"BROADCAST=10.0.0.255\n"\
"NETWORK=10.0.0.0\n"\
"ONBOOT=yes" | ${SUDO} tee ${IB_CONF}
echo

## Really startup
${SUDO} nmcli connection add con-name iblink ifname ib0 type infiniband ip4 10.0.0.${ID}/24 gw4 10.0.0.0
${SUDO} nmcli connection up iblink
# Check
echo "IP Address:"
ip addr

# FAQ：Mellanox官网驱动并不会只会指定OS版本，并不会指定内核版本，因此可能会出现内核版本不匹配的问题：The 4.4.0 kernel is installed, MLNX OFED LINUX does not have drivers available for this kernel.
# 解决方法：编译一个符合当前OS和内核版本的驱动镜像
cd sxy/ib/mnt
sudo ./mlnx_add_kernel_support.sh --mlnx_ofed ./ --make-iso
sudo umount sxy/ib/mnt
# 将编译生成在/tmp下的镜像名替换至以上脚本，并重新安装

# 验证是否成功：查看驱动版本号
modinfo mlx4_core | grep ^version:
```

## Weird RDMA Bugs
```sh
# 问题：使用Disni时遇到 j2c::createEventChannel: rdma_create_event_channel failed: No such file or directory
# 原因：内核模块rdma_ucm未加载
# 解决：加载rdma_ucm模块
sudo modprobe rdma_ucm
```

## Notes on running Hydra
```sh
setup/portal.list: 类似于slaves
port number范围：1到65535 1到1023是系统其它的可以随便用

# 当 remote memory节点的数量少于 (#define NDISKS (NDATAS + 2) //number of splits+parity)，下面这条指令就会一直卡住，并且无法被kill，只能通过重启来解决
/usr/local/bin/nbdxadm -o create_device -i 0 -d 0

# 查看内核日志信息
dmesg
# 最新10行内核日志信息
dmesg | tail -n 10

# 内核版本与OFED版本测试
# CentOS Linux release 7.3.1611 (Core)
kernel 4.4.0    OFED 3.4-2.2.2      修改Makefile后编译成功；create_device卡死
kernel 4.11.0   OFED 3.4-2.2.2      无法成功编译出符合kernel版本的OFED

kernel 4.4.0    OFED 4.1-1.0.2
kernel 4.11.0   OFED 4.1-1.0.2      仅修复了Makefile中关于hydra.ko模块的位置；

node19 x x
node18 o o
node17 x o x
node16 x x
node15 o
node14 -
node13 o x o
node12 -
node11 x
node10 o x
node9 o x
node8 x x
node7 x o
node6 x x
node5 x o 
node4 x x
node3 o x x
node2 x x
node1 x x

```

## YCSB生成trace
```sh
# node6上，可以调整读写比例和request条数
/home/hadoop/YCSB-tracegen/ycsb.sh
```

## Configure and Makefile
```sh
# 输出基于Makefile的完整gcc编译指令
make -n
```

## Stop some applications
```sh
# 关闭ceph-osd和ceph-mds
sudo systemctl stop ceph.target / sudo systemctl stop ceph-osd.target / sudo systemctl stop ceph-mds.target
# 关闭docker
sudo systemctl stop docker
# 关闭containerd
sudo systemctl stop containerd
# 关闭etcd
sudo systemctl stop etcd
# 关闭influxdb
sudo service influxdb stop
# 关闭Prometheus等：切换到tidb，source .bash_profile
tiup cluster stop hands
```

## New
```sh
# git遇到Failed to connect to github.com port 443 after 21090 ms: Couldn‘t connect to server
## 挂了梯子
1.查看本机系统端口号
设置->网络和Internet->代理
查看本机系统端口号
2.设置git端口号和上面的端口号保持一致（我的是7890）
git config --global http.proxy 127.0.0.1:7890
git config --global https.proxy 127.0.0.1:7890

# git遇到commit之后由于github100MB大小限制从而push失败，需要清理之前commit中的大文件
git filter-branch --force --index-filter "git rm --cached --ignore-unmatch -r 要删除的文件" --prune-empty --tag-name-filter cat -- --all
这句的意思是从遍历所有的commit，删除那个文件，重写历史commit
```



