make -j 24
BITCODE=out.bc
# BITCODE=/home/lukas/Documents/Test-Suite/test_cases_bc/basic_c_tests/structcopy1.c.bc
time bin/wpa -ander --stat=0 --dump-constraint-graph $BITCODE ; dot -T svg consCG_final.dot > final-ander.svg && xdg-open final-ander.svg
time ./main -stat=0 --dump-constraint-graph $BITCODE ; dot -T svg consCG_final.dot > final.svg && xdg-open final.svg

exit
COUNTER=0
for i in ~/Documents/Test-Suite/test_cases_bc/basic_c_tests/*; 
do echo $i; ./main -stat=0 $i ; 
# do echo $i; bin/wpa -ander -stat=0 $i ; 
if [ $? -ne 0 ]; then
    break
    # let COUNTER++
fi
done

echo $COUNTER