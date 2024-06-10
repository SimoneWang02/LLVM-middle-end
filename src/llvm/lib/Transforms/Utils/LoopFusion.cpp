#include "llvm/Transforms/Utils/LoopFusion.h"

using namespace llvm;
using namespace std;

bool isAdjacent(Loop *CurrentLoop, Loop *NextLoop) {
    BasicBlock *ExitBlock = CurrentLoop->getExitBlock();

    // outs() << ExitBlock << " " << *ExitBlock << "\n";
    // outs() << NextLoop->getLoopPreheader() << " " << *NextLoop->getLoopPreheader() << "\n";

    if (NextLoop->isGuarded())
        return ExitBlock == NextLoop->getLoopGuardBranch()->getParent();
    return ExitBlock == NextLoop->getLoopPreheader();
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

const SCEV* getPointerOffsetFromGEP(GetElementPtrInst *GEP, ScalarEvolution &SE) {
    // Ottieni il puntatore di base del GEP
    const SCEV *BasePtr = SE.getSCEV(GEP->getPointerOperand());

    // Ottieni l'espressione di offset del GEP
    const SCEV *Offset = SE.getSCEV(GEP);

    // Calcola la differenza per ottenere solo l'offset
    const SCEV *OffsetFromBase = SE.getMinusSCEV(Offset, BasePtr);

    return OffsetFromBase;
}

bool nonNegativeDistanceDependency(Loop *CurrentLoop, Loop *NextLoop, ScalarEvolution &SE) {
    for (auto BI = CurrentLoop->block_begin(); BI != CurrentLoop->block_end(); ++BI) {
        BasicBlock *BB = *BI;
        for (auto Inst = BB->begin(); Inst != BB->end(); ++Inst) {
            if (Inst->getOpcode() == Instruction::Store) {
                StoreInst *SInst = dyn_cast<StoreInst>(Inst);
                // Recupero il puntatore a cui facciamo la store e lo castiamo a GEPInst
                auto ArrayIndexInst = dyn_cast<GetElementPtrInst>(SInst->getPointerOperand());
                // Recuperiamo il puntatore all'array e l'indice dell'offset
                auto ArrayPtr = ArrayIndexInst->getPointerOperand();
                auto StoreOffsetIndex = ArrayIndexInst->getOperand(1);

                // Calcoliamo le ScalarEvolution dell'offset
                const SCEV *StoreOffset = SE.getSCEV(StoreOffsetIndex);
                
                for (auto Iter = ArrayPtr->user_begin(); Iter != ArrayPtr->user_end(); ++Iter) {
                    if (GetElementPtrInst *Ptr = dyn_cast<GetElementPtrInst>(*Iter)) {
                        if (NextLoop->contains(Ptr->getParent())) {
                            // Probabilmente sarà una load dove viene usato
                            auto LoadOffsetIndex = Ptr->getOperand(1);
                            // Ne calcoliamo lo ScalarEvolution
                            const SCEV *LoadOffset = SE.getSCEV(LoadOffsetIndex);
                            // Lo trasformiamo a ScalarEvolution AddRec
                            const SCEVAddRecExpr *OffsetLoadAR = dyn_cast<SCEVAddRecExpr>(LoadOffset);
                            // Se è nel secondo loop
                            if (OffsetLoadAR && OffsetLoadAR->getLoop() == NextLoop) {
                                // Allora creiamo una ScalarEvolution uguale ma nel primo loop
                                const SCEV *OffsetLoadInCurrentLoop = SE.getAddRecExpr(OffsetLoadAR->getStart(), OffsetLoadAR->getStepRecurrence(SE), CurrentLoop, OffsetLoadAR->getNoWrapFlags());
                                
                                // Per poi poterli comparare e vedere se sono minori o uguali.
                                if (SE.isKnownPredicate(ICmpInst::ICMP_SGE, StoreOffset, OffsetLoadInCurrentLoop))
                                    // outs() << "Result: GE\n";
                                    return true;
                                return false;
                            } else {
                                return false;
                            }
                            
                            /* const SCEV *LoadOffset = getPointerOffsetFromGEP(Ptr, SE);
                            const SCEV *StoreOffset = getPointerOffsetFromGEP(ElementPtr, SE);
                            LoadOffset->print(outs()); //outs());
                            StoreOffset->print(outs());
                            
                            if (SE.isKnownPredicate(ICmpInst::ICMP_SGE, StoreOffset, LoadOffset)) {
                                return true;
                            } else if (SE.isKnownPredicate(ICmpInst::ICMP_SLT, StoreOffset, LoadOffset)) {
                                return false;
                            } else {
                                outs() << "RELATION UNKNOWN\n";
                            } */
                        }
                    }
                }
            }
        }
    }

    return true;
}

bool checkIfLoopsCanBeFused(Loop *CurrentLoop, Loop *NextLoop, Function &F, FunctionAnalysisManager &AM) {

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
                if (nonNegativeDistanceDependency(CurrentLoop, NextLoop, SE)) {

                    outs() << "No Negative Distance Dependancy\n";
                    return true;
                }
            }
        }
    } 

    return false;
}

BasicBlock* findLastBodyBlockOfLoop(Loop *L) {
    BasicBlock *Latch = L->getLoopLatch();
    for (auto I : L->getBlocks()) {
        BasicBlock *BB = I;
        if (BB->getTerminator()->getSuccessor(0) == Latch) {
            return BB;
        }
    }

    return nullptr;
}

bool fuseLoops(Loop *L1, Loop *L2, LoopInfo &LI) {
    PHINode *IndVarL0 = L1->getCanonicalInductionVariable();
    PHINode *IndVarL1 = L2->getCanonicalInductionVariable();
    IndVarL1->replaceAllUsesWith(IndVarL0);

    // L'uscita dell'header di L1 è l'ExitBlock di L2
    Instruction *TerminatorHeaderL1 = L1->getHeader()->getTerminator();
    BasicBlock *ExitL2 = L2->getExitBlock();
    TerminatorHeaderL1->setSuccessor(1, ExitL2);

    // Il successore del body di L1 è il body di L2
    BasicBlock *EndBodyL1 = findLastBodyBlockOfLoop(L1);
    if (!EndBodyL1) return false;
    BasicBlock *BodyL2 = L2->getHeader()->getTerminator()->getSuccessor(0);
    EndBodyL1->getTerminator()->setSuccessor(0, BodyL2);

    // Il successore del body di L2 è il latch di L1
    BasicBlock *EndBodyL2 = findLastBodyBlockOfLoop(L2);
    if (!EndBodyL2) return false;
    BasicBlock *LatchL1 = L1->getLoopLatch();
    EndBodyL1->getTerminator()->setSuccessor(0, LatchL1);

    // Il successore nel loop dell'header di L2 è il latch di L2
    Instruction *TerminatorHeaderL2 = L2->getHeader()->getTerminator();
    BasicBlock *LatchL2 = L2->getLoopLatch();
    TerminatorHeaderL2->setSuccessor(0, LatchL2);

    return true;
}

PreservedAnalyses LoopFusion::run(Function &F, FunctionAnalysisManager &AM) {
    LoopInfo &LI = AM.getResult<LoopAnalysis>(F);
    ScalarEvolution &SE = AM.getResult<ScalarEvolutionAnalysis>(F);

    SmallVector<Loop*> AllLoops = LI.getLoopsInPreorder();
    vector<Loop*> CurrentLevelLoops;
    int CurrentLevel = 1;
    int NumberOfLoops = AllLoops.size();
    bool Exit = false;

    if (NumberOfLoops < 2) {
        outs() << "La funzione contiene meno di 2 loop\n";
        return PreservedAnalyses::all();
    }

    while (!Exit) {
        do {
            // Ricalcolo il numero di loops, se sono diversi da prima allora continuo perché non sono arrivato a convergenza.
            NumberOfLoops = AllLoops.size();
            // Recupero tutti i loop del livello attuale di innestamento
            for (int i = 0; i < AllLoops.size(); i++) {
                if (AllLoops[i]->getLoopDepth() == CurrentLevel) {
                    CurrentLevelLoops.push_back(AllLoops[i]);
                }
            }
            
            // Non ho trovato loop a questo livello di innestamento, quitto
            if (CurrentLevelLoops.size() < 1) {
                Exit = true;
            } else {
                outs() << CurrentLevelLoops.size() << " \n";
                // Prendo tutti i loop a coppie e li controllo
                for (int i = 0; i < CurrentLevelLoops.size() - 1; i++) {
                    Loop *CurrentLoop = CurrentLevelLoops[i];
                    Loop *NextLoop = CurrentLevelLoops[i + 1];

                    if (checkIfLoopsCanBeFused(CurrentLoop, NextLoop, F, AM))
                        fuseLoops(CurrentLoop, NextLoop, LI);
                }

                // Se ho fuso almeno un loop allora il numero di loop dovrebbe essersi ridotto
                AllLoops = LI.getLoopsInPreorder();
                // Svuoto CurrentLevelLoops
                CurrentLevelLoops.clear();
            } 
        } while (NumberOfLoops != AllLoops.size() && !Exit);

        CurrentLevel++;
    }

    return PreservedAnalyses::all();
}