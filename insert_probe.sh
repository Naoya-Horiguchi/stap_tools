#!/bin/bash

usage() {
    echo "Usage: `basename $BASH_SOURCE` [-shvt] [-o file] [-p path] [-r recipe]"
    echo "  -s: show contents of Systemtap script"
    echo "  -h: show this message"
    echo "  -v: verbose"
    echo "  -o: output file"
    echo "  -t: show timestamp"
    echo "  -p: stap binary path (default: /usr/local/bin/stap)"
    echo "  -r: recipe"
    exit 1
}

SHOW=
VERBOSE=""
OFILE=""
TSTAMP=""
STAP=/usr/local/bin/stap
RECIPE=""
while getopts shvo:tr: OPT
do
    case $OPT in
        "s") SHOW="on" ;;
        "h") usage ;;
        "v") VERBOSE="--vp 11111" ;;
        "o") OFILE="-o $OPTARG" ;;
        "t") TSTAMP=true ;;
        "r") RECIPE=$OPTARG ;;
    esac
done

if [ ! -e "$RECIPE" ] ; then
    echo "No recipe file given (-r)." >&2
    exit 1
fi

shift $[OPTIND - 1]

if ! grep "/sys/kernel/debug" /proc/mounts > /dev/null 2>&1 ; then
    mount -t debugfs none /sys/kernel/debug
fi

TMPF=`mktemp`

if [ "$TSTAMP" ] ; then
    export PBHDR='printf("%28s %12s %5d %2d %d: ", ppfunc(), execname(), pid(), cpu(), gettimeofday_us())'
else
    export PBHDR='printf("%28s %12s %5d %2d: ", ppfunc(), execname(), pid(), cpu())'
fi

cat <<EOF > ${TMPF}.stp
#!/usr/bin/stap

EOF

# routines
source $(dirname $BASH_SOURCE)/ksyms.sh
source $(dirname $BASH_SOURCE)/func_pointer.sh

cat $RECIPE | grep "^# SIMPLE:" | sed -e 's/^# SIMPLE://' | \
    while read line ; do
    echo "$line" | bash $(dirname $BASH_SOURCE)/simple_probe.sh >> ${TMPF}.stp
done

. $RECIPE $@ >> ${TMPF}.stp
if [ $? -ne 0 ] ; then
    echo "Failed to read/execute $RECIPE. abort." >&2
    exit 1
fi

source $(dirname $BASH_SOURCE)/gru_base.stp       >> ${TMPF}.stp
source $(dirname $BASH_SOURCE)/arg.stp            >> ${TMPF}.stp
source $(dirname $BASH_SOURCE)/mm_common.stp      >> ${TMPF}.stp
source $(dirname $BASH_SOURCE)/hugetlb.stp        >> ${TMPF}.stp
source $(dirname $BASH_SOURCE)/fs_common.stp      >> ${TMPF}.stp
source $(dirname $BASH_SOURCE)/member_deref.sh    >> ${TMPF}.stp

[ "$SHOW" ] && less ${TMPF}.stp
$STAP ${TMPF}.stp -g ${VERBOSE} ${OFILE} -t -w --suppress-time-limits -DMAXACTION=10000 # -D MAXSKIPPED=

rm -f ${TMPF}*
