#include "llvm/Transforms/Utils/LoopFusion.h"

using namespace llvm;
using namespace std;

bool isAdjacent(Loop *CurrentLoop, Loop *NextLoop) {
    BasicBlock *ExitBlock = CurrentLoop->getExitBlock();

    if (NextLoop->isGuarded())
        return ExitBlock->getSingleSuccessor() == NextLoop->getLoopGuardBranch()->getParent();
    return ExitBlock->getSingleSuccessor() == NextLoop->getLoopPreheader();
}

// Bisogna poi controllare anche i nest loops ricorsivamente
bool hasEqualTripCount(ScalarEvolution &SE, Loop *CurrentLoop, Loop *NextLoop) {
    const SCEV *CurrentLoopTripCount = SE.getBackedgeTakenCount(CurrentLoop);
    const SCEV *NextLoopTripCount = SE.getBackedgeTakenCount(NextLoop);

    if (isa<SCEVCouldNotCompute>(CurrentLoopTripCount))
        return false;
    return CurrentLoopTripCount == NextLoopTripCount;
}

bool isControlFlowEquivalent(DominatorTree &DT, PostDominatorTree &PDT, Loop *CurrentLoop, Loop *NextLoop) {
    BasicBlock *CurrentLoopPreheader = CurrentLoop->getLoopPreheader();
    BasicBlock *NextLoopPreheader = NextLoop->getLoopPreheader();

    return DT.dominates(CurrentLoopPreheader, NextLoopPreheader) && PDT.dominates(NextLoopPreheader, CurrentLoopPreheader);
}

PreservedAnalyses LoopFusion::run(Function &F, FunctionAnalysisManager &AM) {
    LoopInfo &LI = AM.getResult<LoopAnalysis>(F);

    SmallVector<Loop*> AllLoops = LI.getLoopsInPreorder();
    vector<Loop*> TopLevelLoops;

    for (int i = 0; i < AllLoops.size(); i++) {
        if (!AllLoops[i]->isInnermost()) {
            TopLevelLoops.push_back(AllLoops[i]);
        }
    }

    outs() << TopLevelLoops.size() << "\n";

    if (TopLevelLoops.size() < 2) {
        outs() << "La funzione contiene meno di 2 loop\n";
        return PreservedAnalyses::all();
    }

    for (int i = 0; i < TopLevelLoops.size() - 1; i++) {
        Loop *CurrentLoop = TopLevelLoops[i];
        Loop *NextLoop = TopLevelLoops[i + 1];

        outs() << CurrentLoop << " " << *CurrentLoop << "\n";
        outs() << NextLoop << " " << *NextLoop << "\n";


        if (isAdjacent(CurrentLoop, NextLoop)) {
            ScalarEvolution &SE = AM.getResult<ScalarEvolutionAnalysis>(F);

            outs() << "Adjacent\n";

            // Ignorare gli array bidimensionali al momento e quindi con nest loops
            if (hasEqualTripCount(SE, CurrentLoop, NextLoop)) {
                DominatorTree &DT = AM.getResult<DominatorTreeAnalysis>(F);
                PostDominatorTree &PDT = AM.getResult<PostDominatorTreeAnalysis>(F);

                outs() << "Equal Trip Count\n";
                if (isControlFlowEquivalent(DT, PDT, CurrentLoop, NextLoop)) {
                    outs() << "Control Flow Equivalent\n";
                }
            }
        } 
    }

    return PreservedAnalyses::all();
}