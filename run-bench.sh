# COUNTER=0
cmake --build build/ --target ptagpu_time;
for i in bitcode-samples/*.{ll,bc};
do 
build/ptagpu/ptagpu_time $i > bench-results/$(cut -d'/' -f2 <<<$i);
done