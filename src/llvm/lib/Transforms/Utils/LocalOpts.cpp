//===-- LocalOpts.cpp - Example Transformations --------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Utils/LocalOpts.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/InstrTypes.h"
#include <iostream>
#include <vector>

using namespace llvm;

bool strengthReduction(Instruction &Instr) {
  if (!Instr.isBinaryOp() || Instr.getOpcode() != Instruction::Mul)
    return false;

  // Se entrambi costanti, ignora
  if (dyn_cast<ConstantInt>(Instr.getOperand(0)) && dyn_cast<ConstantInt>(Instr.getOperand(1)))
    return false;

  // Se entrambe variabili, ignora
  if (!dyn_cast<ConstantInt>(Instr.getOperand(0)) && !dyn_cast<ConstantInt>(Instr.getOperand(1)))
    return false;

  // Prende il primo operando costante
  ConstantInt *ConstOp = dyn_cast<ConstantInt>(Instr.getOperand(0)) ? dyn_cast<ConstantInt>(Instr.getOperand(0)) : dyn_cast<ConstantInt>(Instr.getOperand(1));

  // Left shifting dell'altro operando al log2 più vicino alla costante
  APInt ConstVal = ConstOp->getValue();
  int NearestLog = ConstVal.nearestLogBase2();
  ConstantInt *ConstLog = ConstantInt::get(ConstOp->getContext(), APInt(32, NearestLog));
  Instruction *ShiftInst = BinaryOperator::Create(Instruction::Shl, Instr.getOperand(dyn_cast<ConstantInt>(Instr.getOperand(0)) ? 1 : 0), ConstLog);

  ShiftInst->insertAfter(&Instr);

  // Si aggiunge la differenza
  APInt Rest = ConstVal - (1 << NearestLog);

  if (Rest != 0) {
    ConstantInt *ConstRest = ConstantInt::get(ConstOp->getContext(), Rest);
    Instruction *RestInst = BinaryOperator::Create(Instruction::Add, Instr.getOperand(dyn_cast<ConstantInt>(Instr.getOperand(0)) ? 1 : 0), ConstRest);

    RestInst->insertAfter(ShiftInst);

    Instr.replaceAllUsesWith(RestInst);
  } else {
    Instr.replaceAllUsesWith(ShiftInst);
  }

  return true;
}

bool runOnBasicBlock(BasicBlock &B) {
  std::vector<Instruction *> toRemove;
  for (Instruction &Instr : B) {
    if (strengthReduction(Instr))
      toRemove.push_back(&Instr);
  }

  for (Instruction *Instr : toRemove) {
    Instr->eraseFromParent();
  }

  // Preleviamo le prime due istruzioni del BB
  // Instruction &Inst1st = *B.begin(), &Inst2nd = *(++B.begin());

  // // L'indirizzo della prima istruzione deve essere uguale a quello del 
  // // primo operando della seconda istruzione (per costruzione dell'esempio)
  // assert(&Inst1st == Inst2nd.getOperand(0));

  // // Stampa la prima istruzione
  // outs() << "PRIMA ISTRUZIONE: " << Inst1st << "\n";
  // // Stampa la prima istruzione come operando
  // outs() << "COME OPERANDO: ";
  // Inst1st.printAsOperand(outs(), false);
  // outs() << "\n";

  // // User-->Use-->Value
  // outs() << "I MIEI OPERANDI SONO:\n";
  // for (auto *Iter = Inst1st.op_begin(); Iter != Inst1st.op_end(); ++Iter) {
  //   Value *Operand = *Iter;

  //   if (Argument *Arg = dyn_cast<Argument>(Operand)) {
  //     outs() << "\t" << *Arg << ": SONO L'ARGOMENTO N. " << Arg->getArgNo() 
  //       <<" DELLA FUNZIONE " << Arg->getParent()->getName()
  //             << "\n";
  //   }
  //   if (ConstantInt *C = dyn_cast<ConstantInt>(Operand)) {
  //     outs() << "\t" << *C << ": SONO UNA COSTANTE INTERA DI VALORE " << C->getValue()
  //             << "\n";
  //   }
  // }

  // outs() << "LA LISTA DEI MIEI USERS:\n";
  // for (auto Iter = Inst1st.user_begin(); Iter != Inst1st.user_end(); ++Iter) {
  //   outs() << "\t" << *(dyn_cast<Instruction>(*Iter)) << "\n";
  // }

  // outs() << "E DEI MIEI USI (CHE E' LA STESSA):\n";
  // for (auto Iter = Inst1st.use_begin(); Iter != Inst1st.use_end(); ++Iter) {
  //   outs() << "\t" << *(dyn_cast<Instruction>(Iter->getUser())) << "\n";
  // }

  // // Manipolazione delle istruzioni
  // Instruction *NewInst = BinaryOperator::Create(
  //     Instruction::Add, Inst1st.getOperand(0), Inst1st.getOperand(0));

  // NewInst->insertAfter(&Inst1st);
  // // Si possono aggiornare le singole references separatamente?
  // // Controlla la documentazione e prova a rispondere.
  // Inst1st.replaceAllUsesWith(NewInst);

  return true;
}

bool runOnFunction(Function &F) {
  bool Transformed = false;

  for (auto Iter = F.begin(); Iter != F.end(); ++Iter) {
    if (runOnBasicBlock(*Iter)) {
      Transformed = true;
    }
  }

  return Transformed;
}

PreservedAnalyses LocalOpts::run(Module &M, ModuleAnalysisManager &AM) {
  for (auto Fiter = M.begin(); Fiter != M.end(); ++Fiter)
    if (runOnFunction(*Fiter))
      return PreservedAnalyses::none();
  
  return PreservedAnalyses::all();
}
