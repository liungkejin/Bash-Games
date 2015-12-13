#!/bin/bash

# Author: LKJ
# Email : liungkejin@gmail.com
# Date  : 2013.5.14
#

################################################
# 实现从dict.baidu.com接口获取网络释义
# 实现英译汉，汉译英
# 用法：
# 汉译英：./translate -c <词语>
#         ./translate -c   从标准输入翻译
# 英译汉：./translate <单词>
#         ./translate      从标准输入翻译
###############################################

ENtoCN() {
    #sed -i 's/<div/\n<div/g' /tmp/tempword
    echo "简明释义>>"
    cat /tmp/tempword | grep "dict-en-simplemeans-english" | sed 's/<strong>/\n/g' | \
        sed 's/^\(.*\)<\/strong><span>\(.*\)<\/span>.*/\1 \2/g' | sed 's/<\/span>.*//g' | sed 's/.*<div.*//g';
    echo;
    echo "网络释义>>"
    cat /tmp/tempword | grep "dict-en-netmeans-english" | sed 's/<p>/\n/g' | \
        sed 's/^\(.*\)<\/p>.*/\1/g' | sed 's/<div.*//g';
    echo;
    echo "-----------------------------------------------------"
}

CNtoEN() {
    #sed -i 's/<div/\n<div/g' /tmp/tempword
    echo "简明释义>>"
    cat /tmp/tempword | grep "dict-en-simplemeans" | sed 's/\/s?wd=/\n/g' | \
        sed 's/^\(.*\)">.*/\1/g' | sed 's/.*<div.*//g';
    echo;
    echo "网络释义>>"
    cat /tmp/tempword | grep "dict-en-netmeans" | sed 's/.*dict-en-netmeans/<div/g' | sed 's/<p>/\n/g' | \
        sed 's/^\(.*\)<\/p>.*/\1/g' | sed 's/<div.*//g';
    echo;
    echo "-----------------------------------------------------"
}

Haveword() {
    while [[ $# -ne 0 ]]; do
        echo "======================== $1 ===========================";
        wget -q "dict.baidu.com/s?wd=$1" -O /tmp/tempword
        ((entocn==1)) && ENtoCN;
        ((entocn==0)) && CNtoEN;

        shift;
    done
}

Noword() {
    while read word; do
        echo "======================== $word ===========================";
        wget -q "dict.baidu.com/s?wd=$word" -O /tmp/tempword;
        ((entocn==1)) && ENtoCN;
        ((entocn==0)) && CNtoEN;
    done #< <(grep -v "'" /usr/share/dict/words)
}

entocn=1;

[[ $1 = "-c" ]] && ((entocn=0))
((entocn==0)) && shift;

[[ $# -eq 0 ]] && Noword;
[[ $# -ne 0 ]] && Haveword "$@";

[[ -e /tmp/tempword ]] && rm /tmp/tempword;
