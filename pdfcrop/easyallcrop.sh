#!/bin/bash
######################################################################
##                                                                  ##
##   遍历指定目录获取当前目录下指定后缀（如txt和ini）的文件名            ##
##                                                                  ##
######################################################################
 
##递归遍历
traverse_dir()
{
    filepath=$1
    
    # 使用find命令列出当前目录下的文件，不包括子文件夹
    for file in $(find "$filepath" -maxdepth 1 -type f)
    do
        # 调用check_suffix函数检查文件后缀
        check_suffix "$file"
    done
}

check_suffix()
{
    file=$1
    
    # 获取后缀为pdf的文件，并进行处理
    if [ "${file##*.}"x = "pdf"x ]; then
        echo "$file"

        pdfpath="$file"
        filename=$(basename "$pdfpath")
        dirpath=$(dirname "$pdfpath")
        remotedir='/home/hadoop/lql/'
        remotepath="${remotedir}${filename}"
        
        # 将PDF文件传输到指定服务器
        scp "$pdfpath" hadoop@n19:"$remotedir"
        
        # 在远程服务器上执行pdfcrop操作
        ssh hadoop@n19 "~/bin/pdfcrop ${remotepath} ${remotepath}"
        
        # 将处理后的文件传输回原始文件所在的目录
        scp hadoop@n19:"$remotepath" "$dirpath"
    fi
}

traverse_dir $1