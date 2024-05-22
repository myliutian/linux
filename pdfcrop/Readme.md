# 快速裁pdf白边

## Requirement
1. n19安装了pdfcrop
2. 在`C:\Users\USTC\.ssh`添加连接n19的配置信息（以node1为跳板机）
```sh
Host n19
  Hostname 192.168.1.29
  User hadoop
  ProxyCommand ssh node1 -W %h:%p
```

## Usage of Script
```sh
# crop a given pdf file test.pdf
./easycrop.sh ./test.pdf

# recursively crop all pdf file under a given path
# the given path ends with no '/'
./easyallcrop.sh .
```

## Known Limitations
1. 无法处理包含空格的pdf路径