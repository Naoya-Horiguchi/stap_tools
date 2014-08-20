while read func arg ; do
    [ "$func" == "#" ] && continue
    echo ""
    echo "probe kernel.function(\"${func}\") {"
    echo "    $PBHDR;"
    echo -n "    printf(\""
    if [ "$arg" ] ; then
        for i in $arg ; do echo -n ' %lx' ; done
    fi
    echo -n "\n\""
    if [ "$arg" ] ; then
        for i in $arg ; do echo -n ", arg${i}()" ; done
    fi
    echo ");"
    echo "}"
    echo ""
    echo "probe kernel.function(\"${func}\").return {"
    echo "    $PBHDR;"
    echo "    printf(\" return %lx\n\", returnval());"
    echo "}"
done
