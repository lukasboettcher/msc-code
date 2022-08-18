#include <llvm/Transforms/Utils/Cloning.h>

// llvm::CallInst* call;
// llvm::InlineFunctionInfo ifi;

// InlineFunction(call, ifi);

// PreservedAnalyses FunctionIn::run(Function &F,
//                                       FunctionAnalysisManager &AM) {
//   errs() << F.getName() << "\n";
//   return PreservedAnalyses::all();
// }

#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instructions.h"

using namespace llvm;

namespace
{
    struct Hello : public FunctionPass
    {
        static char ID;
        Hello() : FunctionPass(ID) {}

        bool runOnFunction(Function &F) override
        {
            // for (inst_iterator I = inst_begin(F), E = inst_end(F); I != E; ++I)
            //     errs() << *I << "\n";

            for (BasicBlock &B : F)
            {
                for (Instruction &I : B)
                {
                    if (auto *CB = dyn_cast<CallBase>(&I))
                    {
                        // llvm::CallInst *call;
                        llvm::InlineFunctionInfo ifi;
                        // InlineFunction(*CB, ifi);
                        errs() << CB->getCalledFunction() << '\n';
                        InlineFunction(*CB, ifi);
                    }
                }
            }

            // errs() << "Hello: ";
            // errs().write_escaped(F.getName()) << '\n';
            return false;
        }
    }; // end of struct Hello
} // end of anonymous namespace

char Hello::ID = 0;
static RegisterPass<Hello> X("hello", "Hello World Pass",
                             false /* Only looks at CFG */,
                             false /* Analysis Pass */);

static RegisterStandardPasses Y(
    PassManagerBuilder::EP_EarlyAsPossible,
    [](const PassManagerBuilder &Builder,
       legacy::PassManagerBase &PM)
    { PM.add(new Hello()); });