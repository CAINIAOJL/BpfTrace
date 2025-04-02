#!/bin/bash

declare -A map

map["cbq_in"]="cbq_enqueue"
map["cbq_out"]="cbq_dequeue"
map["cbs_in"]="cbs_enqueue"
map["cbs_out"]="cbs_dequeue"
map["codel_in"]="codel_qdisc_enqueue"
map["code1_out"]="codel_qdisc_dequeue"
map["fq_codel_in"]="fq_codel_enqueue"
map["fq_codel_out"]="fq_codel_dequeue"
map["red_in"]="red_enqueue"
map["red_out"]="red_dequeue"
map["tbf_in"]="tbf_enqueue"
map["tbf_out"]="tbf_dequeue"

qdisc_prefix=""
qdisc_func_in=""
qdisc_func_out=""

#do_bpftrace()
#{
#    BEGIN
#    {
#        printf("Tracing qdisc fq latency. Hit Ctrl-C to end.\n");
#        printf("The qdisc is ${map[$qdisc_prefix]}\n");
#    }

#    k:${map[$1]}
#    {
#        @start[arg0] = nsecs;
#    }

#    kr:${map[$2]}
#    /@start[retval]/
#    {
#        @us = hist((nsecs - @start[retval]) / 1000);
#        delete(@start[retval]);
#    }

#    END
#    {
#        clear(@start);
#    }
#}

do_bpftrace() {
    local script=$(cat <<EOF
BEGIN
{
    printf("Tracing qdisc $1 latency. Hit Ctrl-C to end.\n");
    printf("The qdisc is ${map[$1]}\n");
}

k:${map[$1]}
{
    @start[arg0] = nsecs;
}

kr:${map[$2]}
/@start[retval]/
{
    @us = hist((nsecs - @start[retval]) / 1000);
    delete(@start[retval]);
}

END
{
    clear(@start);
}
EOF
)
    echo "$script" | bpftrace -
}



#echo_info()
#{
#    echo 
#    while getopts :qscfrt opt
#    do
#        case $opt in
#            q)
#                qdisc_prefix="cbq";;
#            s)
#                qdisc_prefix="cbs";;
#            c)
#                qdisc_prefix="codel";;
#            f)
#                qdisc_prefix="fq_codel";;
#            r)
#                qdisc_prefix="red";;
#            t)
#                qdisc_prefix="tbf";;
#            -help)
#                echo "Usage: [sudo] bash qdisclat.sh [-q|-s|-c|-f|-r|-t]"
#                echo "-q:   qdisc-cbq           基于类的队列"
#                echo "-s:   qdisc-cbs           基于信用的整形器"
#                echo "-c:   qdisc-codel         延迟可控的主动队列管理器"
#                echo "-f:   qdisc-fq_codel      延迟可控的公平队列"
#                echo "-r:   qdisc-red           随机早期检测"
#                echo "-t:   qdisc-tbf           令牌桶过滤器"
#                exit 1;;
#            *)
#                echo "Usage: [sudo] bash qdisclat.sh [-q|-s|-c|-f|-r|-t]"
#                echo "-q:   qdisc-cbq           基于类的队列"
#                echo "-s:   qdisc-cbs           基于信用的整形器"
#                echo "-c:   qdisc-codel         延迟可控的主动队列管理器"
#                echo "-f:   qdisc-fq_codel      延迟可控的公平队列"
#                echo "-r:   qdisc-red           随机早期检测"
#                echo "-t:   qdisc-tbf           令牌桶过滤器"
#                exit 1;;
#        esac
#    done
#}

echo 
while getopts :qscfrt opt
do
    case $opt in
        q)
            qdisc_prefix="cbq";;
        s)
            qdisc_prefix="cbs";;
        c)
            qdisc_prefix="codel";;
        f)
            qdisc_prefix="fq_codel";;
        r)
            qdisc_prefix="red";;
        t)
            qdisc_prefix="tbf";;
        -help)
            echo "Usage: [sudo] bash qdisclat.sh [-q|-s|-c|-f|-r|-t]"
            echo "-q:   qdisc-cbq           基于类的队列"
            echo "-s:   qdisc-cbs           基于信用的整形器"
            echo "-c:   qdisc-codel         延迟可控的主动队列管理器"
            echo "-f:   qdisc-fq_codel      延迟可控的公平队列"
            echo "-r:   qdisc-red           随机早期检测"
            echo "-t:   qdisc-tbf           令牌桶过滤器"
            exit 1;;
        *)
            echo "Usage: [sudo] bash qdisclat.sh [-q|-s|-c|-f|-r|-t]"
            echo "-q:   qdisc-cbq           基于类的队列"
            echo "-s:   qdisc-cbs           基于信用的整形器"
            echo "-c:   qdisc-codel         延迟可控的主动队列管理器"
            echo "-f:   qdisc-fq_codel      延迟可控的公平队列"
            echo "-r:   qdisc-red           随机早期检测"
            echo "-t:   qdisc-tbf           令牌桶过滤器"
            exit 1;;
    esac
done


qdisc_func_in="$qdisc_prefix"_in
qdisc_func_out="$qdisc_prefix"_out

do_bpftrace "$qdisc_func_in" "$qdisc_func_out"