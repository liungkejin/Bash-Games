#!/bin/bash
# filename: tetris.sh
#
# Author: LKJ
# Date: 2013.5.14
# Email: liungkejin@gmail.com
#

# const value
#======================================固定值================================#
BXLINES=3;  BXCOLNS=6;  # 小方块的高和宽
MAPX=20;    MAPY=10;
NAME=('I' 'S' 'Z' 'L' 'J' 'T' 'O');
FLAG=('2' '2' '2' '4' '4' '4' '1');

declare -A mapflag mapname;
mapflag=([I]=2 [S]=2 [Z]=2 [L]=4 [J]=4 [T]=4 [O]=1);
mapname=([I]=1 [S]=2 [Z]=3 [L]=4 [J]=5 [T]=6 [O]=7);
colorone=(31 32 33 34 35 36 37);
colortwo=(31 32 33 34 35 36 37);

Iax=( 0 0 0 0); Iay=(-1 0 1 2);
Ibx=(-1 0 1 2); Iby=( 0 0 0 0);

Sax=( 1 1 0 0); Say=(-1 0 0 1);
Sbx=(-1 0 0 1); Sby=( 0 0 1 1);

Zax=( 0 0 1 1); Zay=(-1 0 0 1);
Zbx=(-1 0 0 1); Zby=( 1 1 0 0);

Lax=(-1 0 1 1); Lay=( 0 0 0 -1);
Lbx=(-1 0 0 0); Lby=(-1 -1 0 1);
Lcx=(-1 -1 0 1);Lcy=( 1 0 0 0);
Ldx=( 0 0 0 1); Ldy=(-1 0 1 1);

Jax=(-1 0 1 1); Jay=( 0 0 0 1);
Jbx=( 1 0 0 0); Jby=(-1 -1 0 1);
Jcx=(-1 -1 0 1);Jcy=(-1 0 0 0);
Jdx=( 0 0 0 -1);Jdy=(-1 0 1 1);

Tax=(0 0 0 -1); Tay=(-1 0 1 0);
Tbx=(-1 0 1 0); Tby=( 0 0 0 1);
Tcx=( 0 0 0 1); Tcy=(-1 0 1 0);
Tdx=(-1 0 1 0); Tdy=(0 0 0 -1);

Oax=( 0 0 1 1); Oay=( 0 1 0 1);

good_game=(
    '                                                 '
    '                G A M E  O V E R !               '
    '                                                 '
    '                   Score:                        '
    '                                                 '
    '          press   Q   to quit                    '
    '          press   N   to start a new game        '
    '          press   S   to change the level        '
    '          press   R   to replay your game        '
    '                                                 '
);

start_game=(
    '                                                 '
    '               ~~~ T E T R I S ~~~               '
    '                                                 '
    '                  Author:  LKJ                   '
    '                                                 '
    '          press   S   to change the level        '
    '                                                 '
    '             C H O O S E  L E V E L:             '
    '                        1                        '
    '                                                 '
    '         Press <Enter> to start the game         '
    '                                                 '
);

blockarr=(); #记录name 和 flag
keyarray=(); #记录按键
#------------------------------------------------------------------------#

#========================================================================#
game_init() { # game_init
    SCLINES=`tput lines`;       # 屏幕的高
    SCCOLNS=`tput cols`;        # 屏幕的宽

#主框的属性
    mainw=59;               mainh=60;                   # 主框的宽和高
    mainctx=0;              maincty=4;                  # 主框中心打印点
    upx=$((SCLINES-62));    dnx=$((SCLINES-1));         # 界面的上下 x
    lty=$((SCCOLNS/2-50));  rty=$((lty+61));            # 界面的左右 y

#next的属性
    nextw=40;           nexth=16;                 # next框的高和宽
    ntx=$((upx));       nty=$((rty+2));           # next框的位置
    ntctx=$((ntx+5));   ntcty=$((nty+12));        # next框的中心打印位置

#score的属性
    scorw=$nextw;       scorh=5;
    scx=$((ntx+20));    scy=$((nty));
    scctx=$((scx+4));   sccty=$((scy+19));

#level的属性
    levew=$nextw;       leveh=5;
    lvx=$((scx+9));     lvy=$((scy));
    lvctx=$((lvx+4));   lvcty=$((lvy+20));

#help的属性
    helpw=$nextw;       helph=21;
    hpx=$((lvx+10));    hpy=$((nty));
    hpctx=$((hpx+4));   hpcty=$((hpy+10));

#map
MAP=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    ); #所有的格子

#paint_gui
    clear; paint_gui;

    local x=$((RANDOM%7));
    name=${NAME[$((x))]};  
    flag=$((RANDOM%FLAG[$x]+1)); 

    nname='I'; nflag=2; #下一个方块

    centerx=$mainctx; #每个图形的中心打印点
    centery=$maincty;

#各个方块的相对坐标
    ax="Iax"; ay="Iay";
}
#------------------------------------------------------------------------#

game_exit() {
    tput rmcup;
    tput cvvis;
    stty echo;
    
    (($#==1)) && echo "window is too small";
    exit 0;
}

#============================三个原子函数paint_block, erase_block, paint_box=================
#打印一个小方块, 四个参数， 两个位置和两个颜色
paint_block() {
    local x=$1 y=$2 crone=$3 crtwo=$4 i

    x=$((upx+x*BXLINES+1));
    y=$((lty+y*BXCOLNS+1));

    echo -ne "\033[$((x));$((y))H\033[${crone}m+---+\033[0m";
    echo -ne "\033[$((x+1));$((y))H\033[${crone}m|\033[${crtwo}m###\033[0m\033[${crone}m|\033[0m";
    echo -ne "\033[$((x+2));$((y))H\033[${crone}m+---+\033[0m";
}

#删除一个小方块, 两个参数，即位置
erase_block() {
    local x=$1 y=$2

    x=$((upx+x*BXLINES+1));
    y=$((lty+y*BXCOLNS+1));

    echo -ne "\033[$(( x ));$((y))H     ";
    echo -ne "\033[$((x+1));$((y))H     ";
    echo -ne "\033[$((x+2));$((y))H     ";
}

#画一个盒子$1 $2 $3 $4 $5
paint_box() {
    local x=$1 y=$2 w=$3 h=$4 color=$5 i

    echo -ne "\033[$x;$((y))H\033[${color}m+\033[0m";
    echo -ne "\033[$x;$((y+w+1))H\033[${color}m+\033[0m";
    for (( i = 1; i <= w; i++ )); do
        echo -ne "\033[$x;$((y+i))H\033[${color}m-\033[0m";
        echo -ne "\033[$((x+h+1));$((y+i))H\033[${color}m-\033[0m";
    done
    echo -ne "\033[$((x+h+1));$((y))H\033[${color}m+\033[0m";
    echo -ne "\033[$((x+h+1));$((y+w+1))H\033[${color}m+\033[0m";

    for (( i = 1; i <= h; i++ )); do
        echo -ne "\033[$((x+i));$((y))H\033[${color}mI\033[0m";
        echo -ne "\033[$((x+i));$((y+w+1))H\033[${color}mI\033[0m";
    done
}
#---------------------------------------------------------------------------------------

#打印界面
paint_gui() {
    ((upx<=0 || lty<=0)) && game_exit 1;

    paint_box $upx $lty $mainw $mainh 34; #画主框
    paint_box $ntx $nty $nextw $nexth 33; #画next框
    paint_box $lvx $lvy $levew $leveh 32; #画level框
    paint_box $scx $scy $scorw $scorh 36; #画分数框
    paint_box $hpx $hpy $helpw $helph 31; #画帮助框

#打印score, help 等提示字符
    echo -ne "\033[$((ntx+2));$((nty+17))H\033[34mN E X T\033[0m";

    echo -ne "\033[$((scx+2));$((scy+16))H\033[31mS C O R E\033[0m";
    echo -ne "\033[$((scx+4));$((scy+20))H\033[31m0\033[0m";

    echo -ne "\033[$((lvx+2));$((lvy+16))H\033[31mL E V E L\033[0m";
    echo -ne "\033[$((lvctx));$((lvcty))H\033[31m1\033[0m";

    echo -ne "\033[$((hpx+2));$((hpy+17))H\033[33mH E L P\033[0m";
    echo -ne "\033[$((hpctx));$((hpcty))H\033[34mH --- Move Left\033[0m";
    echo -ne "\033[$((hpctx+2));$((hpcty))H\033[34mL --- Move Right\033[0m";
    echo -ne "\033[$((hpctx+4));$((hpcty))H\033[34mJ --- Soft Drop\033[0m";
    echo -ne "\033[$((hpctx+6));$((hpcty))H\033[34mK --- Rotate\033[0m";
    echo -ne "\033[$((hpctx+8));$((hpcty))H\033[34mSpace or Enter --- Hard Drop\033[0m";

    echo -ne "\033[$((hpctx+11));$((hpcty))H\033[34mP --- Pause Game\033[0m";
    echo -ne "\033[$((hpctx+13));$((hpcty))H\033[34mQ --- Quit Game\033[0m";
    echo -ne "\033[$((hpctx+15));$((hpcty))H\033[34mE --- Exit Replay\033[0m";
}

#---------------------------------------------------------

#在next框中打印下一个方块图形
paint_next() {
    (($#==0)) && mk_random;
    local oflag=$flag oname=$name

    ((centerx=mainctx+2)); ((centery=maincty+9));
    erase_x;
    flag=$nflag;  name=$nname;

    paint_x;
    flag=$oflag;  name=$oname;
    centerx=$mainctx; centery=$maincty;
}

# 打印分数和level
paint_score() {
    level=0;
    echo -ne "\033[$((scctx));$((sccty))H\033[31m$score\033[0m";
    ((score>2000 )) && ((level=1)); ((score>5000 )) && ((level=2));
    ((score>9000 )) && ((level=3)); ((score>14000)) && ((level=4));
    ((score>20000)) && ((level=5)); ((score>27000)) && ((level=6));
    ((score>35000)) && ((level=7)); ((score>44000)) && ((level=8));
    ((level=olevel+level)); 
    ((level>9)) && ((level=9));

    ((TIME=10-level));
    echo -ne "\033[$((lvctx));$((lvcty))H\033[31m$level\033[0m";
}

#根据name选择要打印的方块
paint_x() {
    local x=$centerx y=$centery i
    local n=$((${mapname[$name]}-1));

    find_array;
    for (( i = 0; i < 4; i++ )); do
        paint_block $((x+${ax}[$i])) $((y+${ay}[$i])) ${colorone[$n]} ${colortwo[$n]}
    done
}

#根据name选择要删除的方块
erase_x() {
    local x=$centerx y=$centery i

    find_array;
    for (( i = 0; i < 4; i++ )); do
        erase_block $((x+${ax}[$i])) $((y+${ay}[$i]));
    done
}

rotate_x() {
    ((flag+=1));
    ((flag>mapflag[$name])) && flag=1;
}
#------------------------------------------------------------------------#

#========================================================================#
update() { #update the map
    local x=$1 n=0 i j
    for (( i = 0; i < MAPY; i++ )); do
        erase_block $x $i;              #消掉一行
        MAP[$((x*MAPY+i))]=0;           #更新为0
    done

    #将上面的格子向下移动一行
    for (( i = 0; i < MAPY; i++ )); do
        for (( j = x; j > 0; j-- )); do
            ((n=MAP[$(((j-1)*MAPY+i))])); 
            if ((n!=0)); then
                erase_block $((j-1)) $i;
                paint_block $j $i ${colorone[$((n-1))]} ${colortwo[$((n-1))]};
            fi
        done
    done

    # 更新MAP的值
    for (( i = 0; i < MAPY; i++ )); do
        for (( j = x; j >0; j-- )); do
            MAP[$((j*MAPY+i))]=$((MAP[$(((j-1)*MAPY+i))]));
        done
    done
}

# 检测是否可以消掉一行
have_score() {
    local n=0 i j;
    for (( i = 0; i < MAPX; i++ )); do
        for (( j = 0; j < MAPY; j++ )); do
            ((MAP[$((10*i+j))]==0)) && break; #有空格就退出
        done
        ((j==MAPY)) && ((n+=1)) && update $i;    #可以消掉一行
    done

    case $n in
        1) ((score+=100)); ;;
        2) ((score+=200)); ;;
        3) ((score+=400)); ;;
        4) ((score+=800)); ;;
    esac
}

#根据flag 和 name找到其的坐标数组
find_array() {
    case $flag in
        1) ax="${name}ax"; ay="${name}ay";
            ;;
        2) ax="${name}bx"; ay="${name}by";
            ;;
        3) ax="${name}cx"; ay="${name}cy";
            ;;
        4) ax="${name}dx"; ay="${name}dy";
            ;;
    esac
}

# 检测方块首次出现时,是否会越界,并作出矫正或者游戏结束
check_first() { 
    local x=$centerx y=$centery minx=0 i

    find_array;
# 检测是否越界
    for (( i = 0; i < 4; i++ )); do
        (((x+${ax}[$i])<minx)) && ((minx=(x+${ax}[$i])));
    done
    ((centerx-=minx));
    paint_x;  #开始打印方块
    paint_score;

# 检测是否会结束游戏
    for (( i = 0; i < 4; i++ )); do
        ((x=centerx+${ax}[$i])); ((y=centery+${ay}[$i]))
        ((MAP[$((x*10+y))]!=0)) && return 1; #游戏结束
    done
 
    return 0;
}

#检测是否可以固定方块
check_stop() {
    local sx=$centerx sy=$centery
    local x=0 y=0 n=0 i=0
   
    find_array;
    for (( i = 0; i < 4; i++ )); do
        ((x=(sx+${ax}[$i]))); ((y=(sy+${ay}[$i])));
        ((x+1>19)) && break; #到底
        ((MAP[$((10*(x+1)+y))] != 0)) && break; #有方块挡住
    done
    
    if ((i!=4)); then #不能在动了，则记录
        for (( i = 0; i < 4; i++ )); do
            ((x=(sx+${ax}[$i]))); ((y=(sy+${ay}[$i])));
            n=$((10*x+y)); MAP[$n]=${mapname[$name]};
        done
        have_score;

        return 1;
    fi
 
    return 0;
}

#检测是否可以移到$1 $2这个格子
check_next() {
    local sx=$1 sy=$2 
    local x=0 y=0 n=0 i=0
    
    find_array;
    for (( i = 0; i < 4; i++ )); do
        ((x=(sx+${ax}[$i]))); ((y=(sy+${ay}[$i])));

        ((x<0 || x>19 || y<0 || y>9)) && return 1; 
        ((MAP[$((10*x+y))] != 0)) && return 1; #不能移到这个格子
    done

    return 0;
}
#------------------------------------------------------------------------#

#========================================================================#
go_left() { #向左移一个
    check_next $centerx $((centery-1));
    (($?==1)) && return 1;

    erase_x; ((centery-=1));
    return 0;
}
    
go_right() { #向右移一格
    check_next $centerx $((centery+1));
    (($?==1)) && return 1;

    erase_x; ((centery+=1));
    return 0;
}

go_down() { #加速向下
    check_next $((centerx+1)) $centery
    (($?==1)) && return 1;

    erase_x; ((centerx+=1));
    return 0;
}

go_rotate() { #旋转
    local oflag=$flag #保存原来的flag值

    rotate_x;
    check_next $centerx $centery;
    (($?==1)) && ((flag=oflag)) && return 1;

    flag=$oflag;
    erase_x; rotate_x;

    return 0;
}

go_fast() { #快速固定
    erase_x;
    check_next $((centerx+1)) $centery
    local res=$?;

    while ((res==0)); do
        ((centerx+=1));
        check_next $((centerx+1)) $centery
        res=$?;
    done
}

game_pause() {
    echo -ne "\033[$((hpctx+17));$((hpcty+5))H\033[31mGame Paused\033[0m";
    local pkey;
    while true; do
        read -n 1 pkey;
        [[ $pkey = 'q' ]] || [[ $pkey == 'Q' ]] && game_exit;
        [[ $pkey = 'p' ]] || [[ $pkey == 'P' ]] && break;
    done
    echo -ne "\033[$((hpctx+17));$((hpcty+5))H\033[31m           \033[0m";
}
        
# 根据按键作出选择
keypress() {
    local result=0;
    case ${key:-space} in
        H|h) go_left;   result=$?; # 向左一个格子
            ;;
        J|j) go_down;   result=$?; # 向下, 加速向下一个格子
            ;;
        K|k) go_rotate; result=$?; # 向上, 旋转90度
            ;;
        L|l) go_right;  result=$?; # 向右一个格子
            ;;
        Q|q) game_exit; # 退出游戏
            ;;
        P|p) game_pause;
            ;;
        space)  
            go_fast;    nextbk=1;
            ;;
    esac
    ((result==0)) && paint_x;
}
#----------------------------------------------------------------#

#================================================================#
mk_random() { # 产生下一个随机方块
    local x=$((RANDOM%7))

    nname=${NAME[$x]};
    nflag=$((RANDOM%FLAG[$x]+1));
}

#开始一个新游戏
new_game() {
    local i gmover=0 nextbk=0;

    game_init; #初始化游戏
    while true; do
        paint_next; #在next框中打印下一个方块
        blockarr+=($name $flag $nname $nflag);

        check_first; (($?==1)) && return; #检查是否游戏结束

        while true; do
            for (( i = 0; i < TIME; i++ )); do
                read -n 1 -t 0.1 key; #等待按键
                (($?==0)) && keypress; 
                (($?==0)) && keyarray+=(${key:-space});
                (($?==0)) || keyarray+=("nothing");

                ((nextbk==1)) && !((nextbk=0)) && break;
            done

            check_stop; (($?==1)) && break;
            erase_x; ((centerx+=1)); paint_x;
        done
        
        name=$nname; flag=$nflag;
        ((score+=10));
    done
}

replay() {
    score=0; level=$olevel;
    local gmover=0 nextbk=0 i=0 j=0;
    local blocklen=$((${#blockarr[@]})) keylen=${#keyarray[@]};

    game_init;
    for ((i=0; i<blocklen; i+=4)); do
        name=${blockarr[i]}; flag=${blockarr[i+1]};
        nname=${blockarr[i+2]}; nflag=${blockarr[i+3]};

        paint_next -n;
        check_first; (($?==1)) && return 0;

        while true; do
            local k=0 anykey;
            while true; do
                key=${keyarray[j++]}; [[ $key = [pP] ]] && continue;
                keypress; 
                #((j+=1));

                read -n 1 -t 0.1 anykey; 
                if (($?==0)); then 
                    [[ $anykey = [pP] ]] && game_pause;
                    [[ $anykey = [qQ] ]] && game_exit;
                    [[ $anykey = [eE] ]] && level=1 && return 0;
                fi

                ((nextbk==1)) && !((nextbk=0)) && break;
                ((k+=1)) && ((k==TIME)) && break;
            done
 
            check_stop; (($?==1)) && break;
            erase_x; ((centerx+=1)); paint_x;
        done
        ((score+=10));
    done

    score=0; level=1;
    return 0;
}

paint_game_over() {
    local xcent=$((`tput lines`/2)) ycent=$((`tput cols`/2))
    local x=$((xcent-4)) y=$((ycent-25))
    for (( i = 0; i < 10; i++ )); do
        echo -ne "\033[$((x+i));${y}H\033[44m${good_game[$i]}\033[0m";
    done
    echo -ne "\033[$((x+3));$((ycent+1))H\033[44m${score}\033[0m";
}

game_over() {
    paint_game_over;

    level=1; local pkey;
    while true; do
        read -n 1 pkey;
        [[ $pkey = 'q' ]] || [[ $pkey = 'Q' ]] && game_exit;
        [[ $pkey = 'n' ]] || [[ $pkey = 'N' ]] && break;
        [[ $pkey = 's' ]] || [[ $pkey = 'S' ]] && ((level=level%9+1));
        [[ $pkey = 'r' ]] || [[ $pkey = 'R' ]] && replay && paint_game_over;
        echo -ne "\033[$((lvctx));$((lvcty))H\033[31m$level\033[0m";
    done
    olevel=$level;
    blockarr=();
    keyarray=();
}

game_start() {
    tput civis; stty -echo;
    tput smcup; clear;
    trap 'game_exit;' SIGINT SIGTERM

    score=0; #总分数
    level=1; #等级
    TIME=9;

    local xcent=$(tput lines) ycent=$(tput cols)
    local n=$((xcent/BXLINES)) m=$((ycent/BXCOLNS)) i j;
    for (( i = 3; i < n-2; i++ )); do
        for (( j = 3; j < m-3; ++j)); do
            paint_block $i $j $((RANDOM%7+31)) $((RANDOM%7+31))
        done
    done

    local x=$((xcent/2-4)) y=$((ycent/2-25))
    for (( i = 0; i < 12; i++ )); do
        echo -ne "\033[$((x+i));${y}H\033[40m${start_game[$i]}\033[0m";
    done

    local pkey='x';
    while true; do
        read -n 1 pkey;
        [[ ${pkey:-enter} = 'enter' ]] && break;
        [[ $pkey = 'q' ]] || [[ $pkey = 'Q' ]] && game_exit;
        [[ $pkey = 's' ]] || [[ $pkey = 'S' ]] && ((level=level%9+1));
        echo -ne "\033[$((x+8));$((ycent/2-1))H\033[40m$level\033[0m";
    done
    olevel=$level;
}

game_main() {
    game_start;
    while true; do
        new_game;
        game_over;
    done
}
#----------------------------------------------------------------------#

game_main;

