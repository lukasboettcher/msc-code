/*
this program calculates stats for each bitcode sample

for i in bitcode-samples/* ;do build/ptagpu/ptagpu_stats $i;done
columns: filename, node count, edge count, filesize, density, avg out degree

*/
#include "SVF-FE/LLVMUtil.h"
#include "Graphs/SVFG.h"
#include "WPA/Andersen.h"
#include "SVF-FE/SVFIRBuilder.h"
#include "Util/Options.h"
#include <cmath>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <chrono>
namespace fs = std::filesystem;

using namespace llvm;
using namespace std;
using namespace SVF;

static llvm::cl::opt<std::string> InputFilename(llvm::cl::Positional,
                                                llvm::cl::desc("<input bitcode>"), llvm::cl::init("-"));

int main(int argc, char **argv)
{
    std::chrono::high_resolution_clock::time_point before, after, start, end;
    std::chrono::duration<double, std::milli> wavediff, total;
    start = std::chrono::high_resolution_clock::now();
    int arg_num = 0;
    char **arg_value = new char *[argc];
    std::vector<std::string> moduleNameVec;
    LLVMUtil::processArguments(argc, argv, arg_num, arg_value, moduleNameVec);
    cl::ParseCommandLineOptions(arg_num, arg_value,
                                "Whole Program Points-to Analysis\n");

    SVFModule *svfModule = LLVMModuleSet::getLLVMModuleSet()->buildSVFModule(moduleNameVec);
    svfModule->buildSymbolTableInfo();

    /// Build Program Assignment Graph (SVFIR)
    SVFIRBuilder builder;
    SVFIR *pag = builder.build(svfModule);

    before = std::chrono::high_resolution_clock::now();
    Andersen *ander = AndersenWaveDiff::createAndersenWaveDiff(pag);
    after = std::chrono::high_resolution_clock::now();
    wavediff = std::chrono::duration_cast<std::chrono::duration<double, std::milli>>(after - before);

    SVFIR::releaseSVFIR();
    SVF::LLVMModuleSet::releaseLLVMModuleSet();
    llvm::llvm_shutdown();
    end = std::chrono::high_resolution_clock::now();
    total = std::chrono::duration_cast<std::chrono::duration<double, std::milli>>(end - start);

    fprintf(stderr, "\nlooking at %s\n", moduleNameVec[0].c_str());
    printf("\nanalysis time: %.3f ms\n", wavediff.count());
    printf("total time: %.3f ms\n", total.count());

    return 0;
}
