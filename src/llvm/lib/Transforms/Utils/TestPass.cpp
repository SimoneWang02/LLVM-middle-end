#include "llvm/Transforms/Utils/TestPass.h"

using namespace llvm;

PreservedAnalyses TestPass::run(Function &F, FunctionAnalysisManager &AM) {
    errs() << "Funzione: " << F.getName() << "\n";

    errs() << "Argomenti: " << F.arg_size();
    if (F.isVarArg())
        errs() << "+*";
    errs() << "\n";

    int k = 0;
    for (Function::iterator i = F.begin(), j = F.end(); i != j; i++) 
        k++;

    errs() << "Basic Blocks: " << k << "\n";

    errs() << "Istruzioni: " << F.getInstructionCount() << "\n";
    return PreservedAnalyses::all();
}