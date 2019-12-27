
for i in $(seq -f "%03g" 1 27)
do
    FILENAME="../lattests/bad/bad$i.lat"
    if [ ! -f "$FILENAME" ]; then
        echo "$FILENAME doesnt exist"
        continue
    fi
    echo "$FILENAME"
    output=$(./latc_llvm "$FILENAME")
    if [ $? == 0 ];
    then
        echo "returned 0 !!!!"
        #break
    fi
    echo "$output"
done
