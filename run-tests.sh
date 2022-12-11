# COUNTER=0
for i in Test-Suite/test_cases_bc/basic_c**/*; 
do build/ptagpu/runptagpu -stat=0 $i ; 
# do echo $i; build/bin/wpa -ander -stat=0 $i ; 
if [ $? -ne 0 ]; then
    break
    # let COUNTER++
fi
done

# echo $COUNTER