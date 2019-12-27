
for i in $(seq -f "%03g" 1 22)
do
    FILENAME="../lattests/good/core$i.lat"
    echo "$FILENAME"
    ./latc_llvm "$FILENAME" > /dev/null
    if [ $? != 0 ];
    then
        echo "failed"
        break
    fi
done
