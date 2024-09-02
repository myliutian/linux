# Introduction
https://github.com/QiliangLi/CommandNotes

## git
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

# git统计代码行数
git ls-files | xargs wc -l

# git撤销上一个commit
git reset HEAD^

# git取消上一次push
git push --force origin <branch_name>

# git比较两个branch版本差异
git diff branch1 branch2

# 比较摘要（文件差异）
git diff --stat branch1 branch2

# 比较具体文件差异
git diff branch1 branch2 -- path/to/file

```

## 内存相关
```sh
# 设置大页内存页数
sudo su
echo 21504 > /proc/sys/vm/nr_hugepages
echo 14400 > /proc/sys/vm/nr_hugepages
echo 0 > /proc/sys/vm/nr_hugepages
exit

# 查看cpu占用状态
mpstat -P ALL

# 查看内核以及内存占用情况
htop

# 查看内存占用
free -m

# 整个集群执行

for i in {1..19};do ssh hadoop@n$i "cat /sys/devices/system/node/node*/meminfo | grep -i huge";done

cat /sys/devices/system/node/node*/meminfo | grep -i huge
```

## vscode问题
```sh
# 连接vscode-server失败并且私钥成功上传
远程/home/(username)/文件夹下vscode-server文件夹目录存在缓存问题，暴力方法直接删除之

# 你已连接到不受vscode支持的OS版本
降低vscode到指定版本

# 关闭vscode自动更新
设置里搜索 Auto Check Updates 关闭
```

## RDMA问题

```sh
# RDMA函数ibv_create_cq创建失败，提示malloc memory failed
ulimit -a
查看max locked memory应为unlimited，若为64则会ibv_create_cq失败
解决方法
sudo sh -c "ulimit -l unlimited && exec su $LOGNAME"

```

## screen

```sh
# 开启screen
screen

# 查找已有screen
screen -ls

# 关闭screen
ctrlA + ctrlD

# 


```

## 统计
```sh
# 统计文件夹下所有文件的总行数(包括此文件夹下所有文件夹内的迭代)
find path-to-directory -type f -exec wc -l {} + | awk '{s+=$1} END {print s}'


```




