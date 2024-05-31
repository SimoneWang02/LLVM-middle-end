#include "llvm/Transforms/Utils/LoopFusion.h"

using namespace llvm;
using namespace std;

bool isAdjacent(Loop *CurrentLoop, Loop *NextLoop) {
    // (DOMANDA --> ha usato il plurale, quindi entrambi devono essere concordanti?)
    if (CurrentLoop->isGuarded() != NextLoop->isGuarded())
        return false;

    if (CurrentLoop->isGuarded()) {
        auto GuardBranch = CurrentLoop->getLoopGuardBranch();

        auto iter = NextLoop->block_begin();
        BasicBlock *NextLoopEntryBlock = *iter;

        // (DOMANDA --> Ma funziona? Come faccio a testare il guard branch?)
        return GuardBranch->getSuccessor(0) == NextLoopEntryBlock;
    }

    // auto LastIter = CurrentLoop->block_end() - 1;
    // BasicBlock *ExitBlock = *LastIter;
    BasicBlock *ExitBlock = CurrentLoop->getExitBlock();

    // (DOMANDA --> Ha solamente uno o più successori?)
    // BasicBlock *SingleSuccessor = dyn_cast<BasicBlock>(ExitBlock->getTerminator()->getSuccessor(0));
    BasicBlock *SingleSuccessor = ExitBlock->getSingleSuccessor();

    // (NOTA --> Ho provato e non sono uguali bruh)
    outs() << *CurrentLoop->getLoopPreheader() << "\n" << *NextLoop->getLoopPreheader() << "\n";

    return SingleSuccessor == NextLoop->getLoopPreheader();
}

// (NOTA --> Non è testato, è pura teoria)
// (DOMANDA --> Forse bisogna guardare confrontare il depth dei loop e controllare ricorsivamente i trip count dei nest loops)
bool hasEqualTripCount(ScalarEvolution &SE, Loop *CurrentLoop, Loop *NextLoop) {
    // (DOMANDA --> getBackedgeTakenCount è giusto? Secondo la documentazione è più corretto perché conta le volte in cui il 
    // programma passa per il back edge e quindi evita il caso la condizione del loop non si avveri, a differenza di getTripCountFromExitCount)
    const SCEV *CurrentLoopTripCount = SE.getBackedgeTakenCount(CurrentLoop);
    const SCEV *NextLoopTripCount = SE.getBackedgeTakenCount(NextLoop);

    if (isa<SCEVCouldNotCompute>(CurrentLoopTripCount))
        return false;
    return CurrentLoopTripCount == NextLoopTripCount;
}

bool isControlFlowEquivalent(DominatorTree &DT, PostDominatorTree &PDT, Loop *CurrentLoop, Loop *NextLoop) {

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