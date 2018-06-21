#!/bin/bash

# filename: snake.sh
# snake game
# Author: LKJ 2013.5.17

good_game=(
    '                                                 '
    '                G A M E  O V E R !               '
    '                                                 '
    '                   Score:                        '
    '          press   q   to quit                    '
    '          press   n   to start a new game        '
    '          press   s   to change the speed        '
    '                                                 '
);

game_start=(
    '                                                 '
    '                ~~~ S N A K E ~~~                '
    '                                                 '
    '                  Author:  LKJ                   '
    '         space or enter   pause/play             '
    '         q                quit at any time       '
    '         s                change the speed       '
    '                                                 '
    '         Press <Enter> to start the game         '
    '                                                 '
);

snake_exit() {  #退出游戏
    stty echo;  #恢复回显
    tput rmcup; #恢复屏幕
    tput cvvis; #恢复光标
    exit 0;
}

draw_gui() {                                  # 画边框 
    clear;
    color="\033[34m*\033[0m";
    for (( i = 0; i < $1; i++ )); do
        echo -ne "\033[$i;0H${color}";
        echo -ne "\033[$i;$2H${color}";
    done

    for (( i = 0; i <= $2; i++ )); do
        echo -ne "\033[0;${i}H${color}";
        echo -ne "\033[$1;${i}H${color}";
    done

    ch_speed 0;
    echo -ne "\033[$Lines;$((yscore-10))H\033[36mScores: 0\033[0m";
    echo -en "\033[$Lines;$((Cols-50))H\033[33mPress <space> or enter to pause game\033[0m";
}

snake_init() {
    Lines=`tput lines`; Cols=`tput cols`;     #得到屏幕的长宽
    xline=$((Lines/2)); ycols=4;              #开始的位置
    xscore=$Lines;      yscore=$((Cols/2));   #打印分数的位置
    xcent=$xline;       ycent=$yscore;        #中心点位置
    xrand=0;            yrand=0;              #随机点 
    sumscore=0;         liveflag=1;           #总分和点存在标记
    sumnode=0;          foodscore=0;          #总共要加长的节点和点的分数
    
    snake="0000 ";                            #初始化贪吃蛇
    pos=(right right right right right);      #开始节点的方向
    xpt=($xline $xline $xline $xline $xline); #开始的各个节点的x坐标
    ypt=(5 4 3 2 1);                          #开始的各个节点的y坐标
    speed=(0.05 0.1 0.15);  spk=${spk:-1};    #速度 默认速度

    draw_gui $((Lines-1)) $Cols
}

game_pause() {                                #暂定游戏
    echo -en "\033[$Lines;$((Cols-50))H\033[33mGame paused, Use space or enter key to continue\033[0m";
    while read -n 1 space; do
        [[ ${space:-enter} = enter ]] && \
            echo -en "\033[$Lines;$((Cols-50))H\033[33mPress <space> or enter to pause game           \033[0m" && return;
        [[ ${space:-enter} = q ]] && snake_exit;
    done
}

# $1 节点位置 
update() {                                    #更新各个节点坐标
    case ${pos[$1]} in
        right) ((ypt[$1]++));;
         left) ((ypt[$1]--));;
         down) ((xpt[$1]++));;
           up) ((xpt[$1]--));;
    esac
}

ch_speed() {                                  #更新速度
     [[ $# -eq 0 ]] && spk=$(((spk+1)%3));
     case $spk in
         0) temp="Fast  ";;
         1) temp="Medium";;
         2) temp="Slow  ";;
     esac
     echo -ne "\033[$Lines;3H\033[33mSpeed: $temp\033[0m";
}

Gooooo() {                                   #更新方向
    case ${key:-enter} in
        j|J) [[ ${pos[0]} != "up"    ]] && pos[0]="down";;
        k|K) [[ ${pos[0]} != "down"  ]] && pos[0]="up";;
        h|H) [[ ${pos[0]} != "right" ]] && pos[0]="left";;
        l|L) [[ ${pos[0]} != "left"  ]] && pos[0]="right";;
        s|S) ch_speed;;
        q|Q) snake_exit;;
      enter) game_pause;;
    esac
}

add_node() {                                 #增加节点
    snake="0$snake";
    pos=(${pos[0]} ${pos[@]});
    xpt=(${xpt[0]} ${xpt[@]});
    ypt=(${ypt[0]} ${ypt[@]});
    update 0;

    local x=${xpt[0]} y=${ypt[0]}
    (( ((x>=$((Lines-1)))) || ((x<=1)) || ((y>=Cols)) || ((y<=1)) )) && return 1; #撞墙

    for (( i = $((${#snake}-1)); i > 0; i-- )); do
        (( ${xpt[0]} == ${xpt[$i]} && ${ypt[0]} == ${ypt[$i]} )) && return 1; #crashed
    done

    echo -ne "\033[${xpt[0]};${ypt[0]}H\033[32m${snake[@]:0:1}\033[0m";
    return 0;
}

mk_random() {                               #产生随机点和随机数
    xrand=$((RANDOM%(Lines-3)+2));
    yrand=$((RANDOM%(Cols-2)+2));
    foodscore=$((RANDOM%9+1));

    echo -ne "\033[$xrand;${yrand}H$foodscore";
    liveflag=0;
}

new_game() {                                #重新开始新游戏
    snake_init;
    while true; do
        read -t ${speed[$spk]} -n 1 key;
        [[ $? -eq 0 ]] && Gooooo;

        ((liveflag==0)) || mk_random;
        if (( sumnode > 0 )); then
            ((sumnode--));
            add_node; (($?==0)) || return 1;
        else
            update 0; 
            echo -ne "\033[${xpt[0]};${ypt[0]}H\033[32m${snake[@]:0:1}\033[0m";

            for (( i = $((${#snake}-1)); i > 0; i-- )); do
                update $i;
                echo -ne "\033[${xpt[$i]};${ypt[$i]}H\033[32m${snake[@]:$i:1}\033[0m";

                (( ${xpt[0]} == ${xpt[$i]} && ${ypt[0]} == ${ypt[$i]} )) && return 1; #crashed
                [[ ${pos[$((i-1))]} = ${pos[$i]} ]] || pos[$i]=${pos[$((i-1))]};
            done
        fi

        local x=${xpt[0]} y=${ypt[0]}
        (( ((x>=$((Lines-1)))) || ((x<=1)) || ((y>=Cols)) || ((y<=1)) )) && return 1; #撞墙

        (( x==xrand && y==yrand )) && ((liveflag=1)) && ((sumnode+=foodscore)) && ((sumscore+=foodscore));

        echo -ne "\033[$xscore;$((yscore-2))H$sumscore";
    done
}

print_good_game() {
    local x=$((xcent-4)) y=$((ycent-25))
    for (( i = 0; i < 8; i++ )); do
        echo -ne "\033[$((x+i));${y}H\033[45m${good_game[$i]}\033[0m";
    done
    echo -ne "\033[$((x+3));$((ycent+1))H\033[45m${sumscore}\033[0m";
}

print_game_start() {
    snake_init;

    local x=$((xcent-5)) y=$((ycent-25))
    for (( i = 0; i < 10; i++ )); do
        echo -ne "\033[$((x+i));${y}H\033[45m${game_start[$i]}\033[0m";
    done

    while read -n 1 anykey; do
        [[ ${anykey:-enter} = enter ]] && break;
        [[ ${anykey:-enter} = q ]] && snake_exit;
        [[ ${anykey:-enter} = s ]] && ch_speed;
    done
    
    while true; do
        new_game;
        print_good_game;
        while read -n 1 anykey; do
            [[ $anykey = n ]] && break;
            [[ $anykey = q ]] && snake_exit;
        done
    done
}

game_main() {
    trap 'snake_exit;' SIGTERM SIGINT; 
    stty -echo;                               #取消回显
    tput civis;                               #隐藏光标
    tput smcup; clear;                        #保存屏幕并清屏

    print_game_start;                         #开始游戏 
}

game_main;
