#include "llvm/Transforms/Utils/LoopWalk.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Dominators.h"

using namespace llvm;
using namespace std;

bool checkIfOperandIsLoopInvariant(Value *Operand, Loop &L) {
    // Per ogni istruzione del tipo A = B + C marcare l’istruzione come Loop-INVARIANT se

    // 1. Se l'operando è costante
    if (auto *Const = dyn_cast<Constant>(Operand)) {
        // outs() <<"Value is constant"<<"\n";
        return true;
    }

    if (auto *Inst = dyn_cast<Instruction>(Operand)) {        
        BasicBlock *Parent = dyn_cast<BasicBlock>(Inst->getParent());

        // 2. Se le definizioni che raggiungono l’istruzione binaria si trovano fuori dal loop
        if (L.contains(Parent)) {
            // 3. C’è esattamente una reaching definition e si tratta di un’istruzione del loop che è stata marcata loop-invariant
            return Inst->getMetadata("loop-invariant");
        }
    }

    return true;
}

bool checkIfBlockDominatesAllExits(BasicBlock *BB, vector<BasicBlock*> ExitBlocks, DominatorTree &DT) {
    for (auto iter = begin(ExitBlocks); iter != end(ExitBlocks); ++iter) {
        // outs() << BB->getName() << "\n";
        if (!DT.dominates(BB, *iter)) {
            return false;
        }
    }

    return true;
}

bool isVariableDeadAfterLoop(Instruction *Inst, Loop &L) {
    // outs() << *Inst << " is";
    for (auto iter = Inst->user_begin(); iter != Inst->user_end(); ++iter) {
        if (Instruction *val = dyn_cast<Instruction>(*iter)) {
            if (!L.contains(val->getParent())) {
                return false;
            }
        }
    }
    // outs() <<"\n";
    return true;
}

bool checkIfOperandIsCodeMotion(Value *Operand, Loop &L) {
    if (auto *Inst = dyn_cast<Instruction>(Operand)) {        
        BasicBlock *Parent = dyn_cast<BasicBlock>(Inst->getParent());

        //2. Se le definizioni che raggiungono l’istruzione binaria si trovano fuori dal loop
        if (L.contains(Parent)) {

            //3. C’è esattamente una reaching definition e si tratta di un’istruzione del loop che è stata marcata loop-invariant
            if (Inst->getMetadata("loop-invariant") && Inst->getMetadata("code-motion"))
                return true;
            return false;
        }
    }

    // Se è una costante, allora è code-motion
    return true;
}

PreservedAnalyses LoopWalk::run(Loop &L, LoopAnalysisManager &LAM, LoopStandardAnalysisResults &LAR, LPMUpdater &LU) {
    if (!L.isLoopSimplifyForm()) {
        outs() << "\nIl loop non è in forma NORMALE.\n";
        return PreservedAnalyses::all();
    }
    
    vector<BasicBlock*> ExitBlocks;
    vector<BinaryOperator*> CodeMotions;
    
    // Recupero le uscite del loop
    for (auto BI = L.block_begin(); BI != L.block_end(); ++BI) {
        BasicBlock *BB = *BI;
        for (int i = 0; i < BB->getTerminator()->getNumSuccessors(); i++) {
            if (BasicBlock *Successor = dyn_cast<BasicBlock>(BB->getTerminator()->getSuccessor(i))) {
                // outs() << *Successor << "\n";
                if (!L.contains(Successor))
                    ExitBlocks.push_back(Successor);
            }
        }
    }

    // outs() << "EXIT BLOCK IS: " << *ExitBlocks[0];

    // Recupero il dominance tree del loop
    DominatorTree &DT = LAR.DT;
    for (auto BI = L.block_begin(); BI != L.block_end(); ++BI) {
        BasicBlock *BB = *BI;
        for (auto iter = BB->begin(); iter != BB->end(); ++iter) {
            if (auto *binaryInst = dyn_cast<BinaryOperator>(iter)) {
                // Recupero i miei operandi
                Value *firstOperand = binaryInst->getOperand(0);
                Value *secondOperand = binaryInst->getOperand(1);

                // Le istruzioni sono candidate alla code motion se

                // 1. Sono loop invariant
                if (checkIfOperandIsLoopInvariant(firstOperand, L) && checkIfOperandIsLoopInvariant(secondOperand, L)) {
                    LLVMContext& C = binaryInst->getContext();
                    MDNode* N = MDNode::get(C, MDString::get(C, "true"));
                    binaryInst->setMetadata("loop-invariant", N);
                    
                    // 2. Si trovano in blocchi che dominano tutte le uscite del loop OPPURE la variabile definita dall’istruzione è dead all’uscita del loop
                    if (checkIfBlockDominatesAllExits(BB, ExitBlocks, DT) || isVariableDeadAfterLoop(binaryInst, L)) {

                        // 3. Assegnano un valore a variabili non assegnate altrove nel loop
                        if (checkIfOperandIsCodeMotion(firstOperand, L) && checkIfOperandIsCodeMotion(secondOperand, L)) {
                            LLVMContext& C = binaryInst->getContext();
                            MDNode* N = MDNode::get(C, MDString::get(C, "true"));
                            binaryInst->setMetadata("code-motion", N);
                            
                            CodeMotions.push_back(binaryInst);
                            // outs() << *binaryInst <<"\n";
                        } 
                    }                       
                }
            }
        }
    }

    BasicBlock *Start = L.getLoopPreheader();
    for (auto iter = begin(CodeMotions); iter != end(CodeMotions); ++iter) {
        Instruction * Instr = *iter;
        if (Instr->getNumUses() == 0) {
            Instr->eraseFromParent();
            continue;
        }

        if (Instr->getMetadata("code-motion")) {
            Instruction *NewInstr = Instr->clone();
            NewInstr->insertBefore(Start->getTerminator());
            Instr->replaceAllUsesWith(NewInstr);
            Instr->eraseFromParent();
        }
    }

    return PreservedAnalyses::all();        
}