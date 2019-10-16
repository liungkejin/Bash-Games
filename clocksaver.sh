#!/usr/bin/env bash
# filename: clock.sh
# wrote by LKJ, 2013,5,14
# base on ANSI/VT100 terminal

asciinumber=(
    '    .XEEEEb           ,:LHL          :LEEEEEG        .CNEEEEE8                bMNj       NHKKEEEEEX           1LEEE1    KEEEEEEEKNMHH       8EEEEEL.         cEEEEEO    '
    '   MEEEUXEEE8       jNEEEEE         EEEEHMEEEEU      EEEELLEEEEc             NEEEU      7EEEEEEEEEK        :EEEEEEN,    EEEEEEEEEEEEE     OEEEGC8EEEM      1EEELOLEEE3  '
    '  NEE.    OEEC      EY" MEE         OC      LEEc     :"      EEE            EEGEE3      8EN               MEEM.                  :EE.    1EEj     :EEO    1EE3     DEEc '
    ' ,EEj      EEE          HEE                  EEE             cEE:          EEU EEJ      NEC              EEE                     EEJ     EEE       EEE    EEN       KEE '
    ' HEE       jEE1         NEE                  EEE             EEE          EEM  EEJ      EE              LEE   ..                EEK      DEEj     :EE7   ,EE1       jEE '
    ' EEH        EEZ         KEE                 :EE1       .::jZEEG          EEU   EEJ     .EEEEEENC        EE77EEEEEEL            NEE        UEENj  bEE7    .EEX       :EE.'
    '.EEZ        EEM         KEE                 EEK        EEEEEEC         .EEc    EEC     :X3DGMEEEEU     3EEEED.".GEEE.         CEE.          EEEEEEE       EEEj     :EEE '
    ' EEZ        EEM         KEE               :EEK            "jNEEZ      :EE      EE7             MEEU    LEEb       EEE        .EE8         DEEL:.8EEEM      NEEENMEEEHEE '
    ' EEN       .EEG         KEE              bEEG                7EEM    jEEN738ODDEEM3b            EEE    MEE        8EE,       EEE         EEE      ,EEE      .bEEEEC XEE '
    ' LEE       3EE:         KEE            .EEE,                  EEE    LEEEEEEEEEEEEEE            XEE    8EE        cEE:      NEE         7EE1       jEE1            :EE: '
    ' .EEc      EEE          KEE           bEED                    EEE              EE1              EEE     EEX       EEE      3EE:         cEEc       7EEj           CEEG  '
    '  MEE7    NEE.          EEE         jEEK             C       EEE1              EEC     j      :EEE      CEEG     LEEj     .EEU           EEE:     .EEE          1EEEJ   '
    '   bEEEEEEEE.           EEE        NEEEEEEEEEEEE    bEEEEEEEEEE7               EEd    JEEEEEEEEEN        jEEEEEEEEE7     .EEE             KEEEEHEEEEL      8EEEEEEX     '
    '     DEEEL7             CGD        3GD3DOGGGGGUX     :DHEEEN8.                 bUd     7GNEEEMc            7LEEEX:       1XG                JHEEEM1        COLIN"       '
);

asciidot=(
    ' @@ '
    ' @@ '
);

#共有三个参数, 
#第一个是所要打印的数字, 
#第二个是之前打印的数字个数，
#第三个是之前打印的点的个数
function print_number {
    start=`expr $1 \* 17 + 1`;
    start_y=`expr $2 \* 17 + 1 + $3 \* 4 + $beg_y`;

    len=${#asciinumber[@]};

    for (( i = 0; i < $len; i++ )); do
        #echo "${asciinumber[$i]}";
        tput cup `expr $beg_x + $i` $start_y;

        str=`expr substr "${asciinumber[$i]}" $start 17`;
        echo -ne "\033[1;32m${str}\033[0m";
    done
}

#print_dot有两个参数
#第一个参数是之前打印的数字个数
#第二个参数是之前打印的点的个数
function print_dot {
    for (( j = 0; j < 2; j++ )); do
        tput cup `expr $beg_x + 3 + $j` `expr $1 \* 17 + $2 \* 4 + $beg_y + 1`
        echo -ne "\033[1;32m${asciidot[$j]}\033[0m";
    done

    for (( j = 0; j < 2; j++ )); do
        tput cup `expr $beg_x + 10 + $j` `expr $1 \* 17 + $2 \* 4 + $beg_y + 1`
        echo -ne "\033[1;32m${asciidot[$j]}\033[0m";
    done
}

function old_value {
    orows=`tput lines`; beg_x=`expr $orows / 2 - 7`;
    ocols=`tput cols`;  beg_y=`expr $ocols / 2 - 55`;

    ohur=`date +%H`;
    ohft=`expr $ohur / 10`; ohsd=`expr $ohur % 10`;
    print_number $ohft 0 0; print_number $ohsd 1 0;

    print_dot 2 0;

    omin=`date +%M`;
    omft=`expr $omin / 10`; omsd=`expr $omin % 10`;
    print_number $omft 2 1; print_number $omsd 3 1;

    print_dot 4 1;

    osec=`date +%S`;
    osft=`expr $osec / 10`; ossd=`expr $osec % 10`;
    print_number $osft 4 2; print_number $ossd 5 2;
}

function print_all {
    t_rows=`tput lines`; beg_x=`expr $t_rows / 2 - 7`;
    t_cols=`tput cols`;  beg_y=`expr $t_cols / 2 - 55`;

    if [[ $t_rows -ne $orows || $t_cols -ne $ocols ]]; then
        orows=$t_rows;
        ocols=$t_cols;
        check_win $orows $ocols;
        old_value;
    fi

    hur=`date +%H`;
    hft=`expr $hur / 10`; hsd=`expr $hur % 10`;
    if [[ $ohft -ne $hft ]]; then
        print_number $hft 0 0;
        ohft=$hft;
    fi
    if [[ $ohsd -ne $hsd ]]; then
        print_number $hsd 1 0;
        ohsd=$hsd;
    fi

    min=`date +%M`;
    mft=`expr $min / 10`; msd=`expr $min % 10`;
    if [[ $omft -ne $mft ]]; then
        print_number $mft 2 1;
        omft=$mft;
    fi
    if [[ $omsd -ne $msd ]]; then
        print_number $msd 3 1;
        omsd=$msd;
    fi

    sec=`date +%S`;
    sft=`expr $sec / 10`; ssd=`expr $sec % 10`;
    if [[ $osft -ne $sft ]]; then
        print_number $sft 4 2;
        osft=$sft;
    fi
    if [[ $ossd -ne $ssd ]]; then
        print_number $ssd 5 2;
        ossd=$ssd;
    fi

}

function check_win {
    if [[ $1 -lt 14 || $2 -lt 110 ]]; then
        clear;
        echo -ne "\033[8;15;120t";
    fi
    clear; #若窗口改变则重新刷新
}

function print_init {
    check_win `tput lines` `tput cols`;
    tput civis; #设置光标不可见
    old_value;
}

function print_exit {
    tput cvvis; #恢复光标
}

function init_all {
    if [[ -n `pidof logkeys` ]]; then
        logkeys -k; #重新运行logkeys
    fi

    templog=`mktemp`; #生成临时log文件
    sudo logkeys -s -o $templog ; #指定要监视的设备

    onum=`tail -n 1 $templog`; #取得最新的输入
    otim=`date +%s`; #取得时间

    trap 'logkeys -k; exit 0;' SIGTERM; 
}

function error {
    case $1 in
        0) echo "Permission denied;";;
        1) echo "Usage: #./clock.sh TIME_OUT &";;
        2) echo -n "The program 'logkeys' is currently not installed. ";
           echo "You can install it by typing: "
           echo "sudo apt-get install suckless-tools";;
    esac

    exit -1;
}

if [[ $UID -ne 0 ]]; then
    error 0;
elif [[ -z `which logkeys` ]]; then
    error 2;
elif [[ $# -eq 0 ]]; then
    TIMEOUT=60;
elif [[ $# -eq 1 && -z `echo $1 | tr -d '[0-9]'` ]]; then
    TIMEOUT=$1;
else
    error 1;
fi

init_all;
while true; do
    cnum=`tail -n 1 $templog`; #取得最最新的输入
    ctim=`date +%s`;

    #检测是否两次都一样，若一样则检测是否超时
    if [[ $onum = $cnum && `expr $ctim - $otim` -gt $TIMEOUT ]]; then
        print_init;
        while [[ $cnum = `tail -n 1 $templog` ]]; do
            print_all;
            sleep 0.3;
        done
        print_exit;

        cnum=`tail -n 1 $templog`;
        ctim=`date +%s`;
        onum=$cnum;
        otim=$ctim;
    elif [[ $onum != $cnum ]]; then #更新时间和输入
        onum=$cnum;
        otim=$ctim;
    fi
    sleep 1;
done

exit 0;
