; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-none-none-eabi -mattr=+mve.fp -enable-arm-maskedldst -verify-machineinstrs %s -o - | FileCheck %s

define arm_aapcs_vfpcc void @thres_i32(ptr %data, i16 zeroext %N, i32 %T) {
; CHECK-LABEL: thres_i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it eq
; CHECK-NEXT:    popeq {r7, pc}
; CHECK-NEXT:  .LBB0_1: @ %vector.ph
; CHECK-NEXT:    mvn r3, #3
; CHECK-NEXT:    add.w r1, r3, r1, lsl #2
; CHECK-NEXT:    movs r3, #1
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    add.w lr, r3, r1, lsr #2
; CHECK-NEXT:    rsbs r1, r2, #0
; CHECK-NEXT:  .LBB0_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrw.u32 q1, [r0]
; CHECK-NEXT:    vpte.s32 ge, q1, r2
; CHECK-NEXT:    vcmpt.s32 le, q1, r1
; CHECK-NEXT:    vstrwe.32 q0, [r0], #16
; CHECK-NEXT:    le lr, .LBB0_2
; CHECK-NEXT:  @ %bb.3: @ %for.cond.cleanup
; CHECK-NEXT:    pop {r7, pc}
entry:
  %conv = zext i16 %N to i32
  %mul = shl nuw nsw i32 %conv, 2
  %cmp15 = icmp eq i16 %N, 0
  br i1 %cmp15, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %sub = sub nsw i32 0, %T
  %broadcast.splatinsert17 = insertelement <4 x i32> undef, i32 %T, i32 0
  %broadcast.splat18 = shufflevector <4 x i32> %broadcast.splatinsert17, <4 x i32> undef, <4 x i32> zeroinitializer
  %broadcast.splatinsert19 = insertelement <4 x i32> undef, i32 %sub, i32 0
  %broadcast.splat20 = shufflevector <4 x i32> %broadcast.splatinsert19, <4 x i32> undef, <4 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %0 = getelementptr inbounds i32, ptr %data, i32 %index
  %wide.load = load <4 x i32>, ptr %0, align 4
  %1 = icmp slt <4 x i32> %wide.load, %broadcast.splat18
  %2 = icmp sgt <4 x i32> %wide.load, %broadcast.splat20
  %3 = or <4 x i1> %1, %2
  call void @llvm.masked.store.v4i32.p0(<4 x i32> zeroinitializer, ptr %0, i32 4, <4 x i1> %3)
  %index.next = add i32 %index, 4
  %4 = icmp eq i32 %index.next, %mul
  br i1 %4, label %for.cond.cleanup, label %vector.body

for.cond.cleanup:                                 ; preds = %vector.body, %entry
  ret void
}

define arm_aapcs_vfpcc void @thresh_i16(ptr %data, i16 zeroext %N, i16 signext %T) {
; CHECK-LABEL: thresh_i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it eq
; CHECK-NEXT:    popeq {r7, pc}
; CHECK-NEXT:  .LBB1_1: @ %vector.ph
; CHECK-NEXT:    mvn r3, #7
; CHECK-NEXT:    add.w r1, r3, r1, lsl #3
; CHECK-NEXT:    movs r3, #1
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    add.w lr, r3, r1, lsr #3
; CHECK-NEXT:    rsbs r1, r2, #0
; CHECK-NEXT:  .LBB1_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrh.u16 q1, [r0]
; CHECK-NEXT:    vpte.s16 ge, q1, r2
; CHECK-NEXT:    vcmpt.s16 le, q1, r1
; CHECK-NEXT:    vstrhe.16 q0, [r0], #16
; CHECK-NEXT:    le lr, .LBB1_2
; CHECK-NEXT:  @ %bb.3: @ %for.cond.cleanup
; CHECK-NEXT:    pop {r7, pc}
entry:
  %conv2 = zext i16 %N to i32
  %mul = shl nuw nsw i32 %conv2, 3
  %cmp22 = icmp eq i16 %N, 0
  br i1 %cmp22, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %sub = sub i16 0, %T
  %broadcast.splatinsert24 = insertelement <8 x i16> undef, i16 %T, i32 0
  %broadcast.splat25 = shufflevector <8 x i16> %broadcast.splatinsert24, <8 x i16> undef, <8 x i32> zeroinitializer
  %broadcast.splatinsert26 = insertelement <8 x i16> undef, i16 %sub, i32 0
  %broadcast.splat27 = shufflevector <8 x i16> %broadcast.splatinsert26, <8 x i16> undef, <8 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %0 = getelementptr inbounds i16, ptr %data, i32 %index
  %wide.load = load <8 x i16>, ptr %0, align 2
  %1 = icmp slt <8 x i16> %wide.load, %broadcast.splat25
  %2 = icmp sgt <8 x i16> %wide.load, %broadcast.splat27
  %3 = or <8 x i1> %1, %2
  call void @llvm.masked.store.v8i16.p0(<8 x i16> zeroinitializer, ptr %0, i32 2, <8 x i1> %3)
  %index.next = add i32 %index, 8
  %4 = icmp eq i32 %index.next, %mul
  br i1 %4, label %for.cond.cleanup, label %vector.body

for.cond.cleanup:                                 ; preds = %vector.body, %entry
  ret void
}

define arm_aapcs_vfpcc void @thresh_i8(ptr %data, i16 zeroext %N, i8 signext %T) {
; CHECK-LABEL: thresh_i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it eq
; CHECK-NEXT:    popeq {r7, pc}
; CHECK-NEXT:  .LBB2_1: @ %vector.ph
; CHECK-NEXT:    mvn r3, #15
; CHECK-NEXT:    add.w r1, r3, r1, lsl #4
; CHECK-NEXT:    movs r3, #1
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    add.w lr, r3, r1, lsr #4
; CHECK-NEXT:    rsbs r1, r2, #0
; CHECK-NEXT:  .LBB2_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrb.u8 q1, [r0]
; CHECK-NEXT:    vpte.s8 ge, q1, r2
; CHECK-NEXT:    vcmpt.s8 le, q1, r1
; CHECK-NEXT:    vstrbe.8 q0, [r0], #16
; CHECK-NEXT:    le lr, .LBB2_2
; CHECK-NEXT:  @ %bb.3: @ %for.cond.cleanup
; CHECK-NEXT:    pop {r7, pc}
entry:
  %conv2 = zext i16 %N to i32
  %mul = shl nuw nsw i32 %conv2, 4
  %cmp20 = icmp eq i16 %N, 0
  br i1 %cmp20, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %sub = sub i8 0, %T
  %broadcast.splatinsert22 = insertelement <16 x i8> undef, i8 %T, i32 0
  %broadcast.splat23 = shufflevector <16 x i8> %broadcast.splatinsert22, <16 x i8> undef, <16 x i32> zeroinitializer
  %broadcast.splatinsert24 = insertelement <16 x i8> undef, i8 %sub, i32 0
  %broadcast.splat25 = shufflevector <16 x i8> %broadcast.splatinsert24, <16 x i8> undef, <16 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %0 = getelementptr inbounds i8, ptr %data, i32 %index
  %wide.load = load <16 x i8>, ptr %0, align 1
  %1 = icmp slt <16 x i8> %wide.load, %broadcast.splat23
  %2 = icmp sgt <16 x i8> %wide.load, %broadcast.splat25
  %3 = or <16 x i1> %1, %2
  call void @llvm.masked.store.v16i8.p0(<16 x i8> zeroinitializer, ptr %0, i32 1, <16 x i1> %3)
  %index.next = add i32 %index, 16
  %4 = icmp eq i32 %index.next, %mul
  br i1 %4, label %for.cond.cleanup, label %vector.body

for.cond.cleanup:                                 ; preds = %vector.body, %entry
  ret void
}

define arm_aapcs_vfpcc void @thresh_f32(ptr %data, i16 zeroext %N, float %T) {
; CHECK-LABEL: thresh_f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it eq
; CHECK-NEXT:    popeq {r7, pc}
; CHECK-NEXT:  .LBB3_1: @ %vector.ph
; CHECK-NEXT:    mvn r2, #3
; CHECK-NEXT:    add.w r1, r2, r1, lsl #2
; CHECK-NEXT:    movs r2, #1
; CHECK-NEXT:    add.w lr, r2, r1, lsr #2
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    eor r2, r1, #-2147483648
; CHECK-NEXT:  .LBB3_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrw.u32 q1, [r0]
; CHECK-NEXT:    vpte.f32 ge, q1, r1
; CHECK-NEXT:    vcmpt.f32 le, q1, r2
; CHECK-NEXT:    vstrwe.32 q0, [r0], #16
; CHECK-NEXT:    le lr, .LBB3_2
; CHECK-NEXT:  @ %bb.3: @ %for.cond.cleanup
; CHECK-NEXT:    pop {r7, pc}
entry:
  %conv = zext i16 %N to i32
  %mul = shl nuw nsw i32 %conv, 2
  %cmp15 = icmp eq i16 %N, 0
  br i1 %cmp15, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %fneg = fneg fast float %T
  %broadcast.splatinsert17 = insertelement <4 x float> undef, float %T, i32 0
  %broadcast.splat18 = shufflevector <4 x float> %broadcast.splatinsert17, <4 x float> undef, <4 x i32> zeroinitializer
  %broadcast.splatinsert19 = insertelement <4 x float> undef, float %fneg, i32 0
  %broadcast.splat20 = shufflevector <4 x float> %broadcast.splatinsert19, <4 x float> undef, <4 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %0 = getelementptr inbounds float, ptr %data, i32 %index
  %wide.load = load <4 x float>, ptr %0, align 4
  %1 = fcmp fast olt <4 x float> %wide.load, %broadcast.splat18
  %2 = fcmp fast ogt <4 x float> %wide.load, %broadcast.splat20
  %3 = or <4 x i1> %1, %2
  call void @llvm.masked.store.v4f32.p0(<4 x float> zeroinitializer, ptr %0, i32 4, <4 x i1> %3)
  %index.next = add i32 %index, 4
  %4 = icmp eq i32 %index.next, %mul
  br i1 %4, label %for.cond.cleanup, label %vector.body

for.cond.cleanup:                                 ; preds = %vector.body, %entry
  ret void
}

define arm_aapcs_vfpcc void @thresh_f16(ptr %data, i16 zeroext %N, float %T.coerce) {
; CHECK-LABEL: thresh_f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it eq
; CHECK-NEXT:    popeq {r7, pc}
; CHECK-NEXT:  .LBB4_1: @ %vector.ph
; CHECK-NEXT:    mvn r3, #7
; CHECK-NEXT:    add.w r1, r3, r1, lsl #3
; CHECK-NEXT:    vmov r2, s0
; CHECK-NEXT:    vneg.f16 s0, s0
; CHECK-NEXT:    movs r3, #1
; CHECK-NEXT:    add.w lr, r3, r1, lsr #3
; CHECK-NEXT:    vmov.f16 r1, s0
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:  .LBB4_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrh.u16 q1, [r0]
; CHECK-NEXT:    vpte.f16 ge, q1, r2
; CHECK-NEXT:    vcmpt.f16 le, q1, r1
; CHECK-NEXT:    vstrhe.16 q0, [r0], #16
; CHECK-NEXT:    le lr, .LBB4_2
; CHECK-NEXT:  @ %bb.3: @ %for.cond.cleanup
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = bitcast float %T.coerce to i32
  %tmp.0.extract.trunc = trunc i32 %0 to i16
  %1 = bitcast i16 %tmp.0.extract.trunc to half
  %conv = zext i16 %N to i32
  %mul = shl nuw nsw i32 %conv, 3
  %cmp17 = icmp eq i16 %N, 0
  br i1 %cmp17, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %fneg = fneg fast half %1
  %broadcast.splatinsert19 = insertelement <8 x half> undef, half %1, i32 0
  %broadcast.splat20 = shufflevector <8 x half> %broadcast.splatinsert19, <8 x half> undef, <8 x i32> zeroinitializer
  %broadcast.splatinsert21 = insertelement <8 x half> undef, half %fneg, i32 0
  %broadcast.splat22 = shufflevector <8 x half> %broadcast.splatinsert21, <8 x half> undef, <8 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %2 = getelementptr inbounds half, ptr %data, i32 %index
  %wide.load = load <8 x half>, ptr %2, align 2
  %3 = fcmp fast olt <8 x half> %wide.load, %broadcast.splat20
  %4 = fcmp fast ogt <8 x half> %wide.load, %broadcast.splat22
  %5 = or <8 x i1> %3, %4
  call void @llvm.masked.store.v8f16.p0(<8 x half> zeroinitializer, ptr %2, i32 2, <8 x i1> %5)
  %index.next = add i32 %index, 8
  %6 = icmp eq i32 %index.next, %mul
  br i1 %6, label %for.cond.cleanup, label %vector.body

for.cond.cleanup:                                 ; preds = %vector.body, %entry
  ret void
}



define arm_aapcs_vfpcc void @thres_rev_i32(ptr %data, i16 zeroext %N, i32 %T) {
; CHECK-LABEL: thres_rev_i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it eq
; CHECK-NEXT:    popeq {r7, pc}
; CHECK-NEXT:  .LBB5_1: @ %vector.ph
; CHECK-NEXT:    mvn r3, #3
; CHECK-NEXT:    add.w r1, r3, r1, lsl #2
; CHECK-NEXT:    movs r3, #1
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    add.w lr, r3, r1, lsr #2
; CHECK-NEXT:    rsbs r1, r2, #0
; CHECK-NEXT:  .LBB5_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrw.u32 q1, [r0]
; CHECK-NEXT:    vpte.s32 ge, q1, r2
; CHECK-NEXT:    vcmpt.s32 le, q1, r1
; CHECK-NEXT:    vstrwe.32 q0, [r0], #16
; CHECK-NEXT:    le lr, .LBB5_2
; CHECK-NEXT:  @ %bb.3: @ %for.cond.cleanup
; CHECK-NEXT:    pop {r7, pc}
entry:
  %conv = zext i16 %N to i32
  %mul = shl nuw nsw i32 %conv, 2
  %cmp15 = icmp eq i16 %N, 0
  br i1 %cmp15, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %sub = sub nsw i32 0, %T
  %broadcast.splatinsert17 = insertelement <4 x i32> undef, i32 %T, i32 0
  %broadcast.splat18 = shufflevector <4 x i32> %broadcast.splatinsert17, <4 x i32> undef, <4 x i32> zeroinitializer
  %broadcast.splatinsert19 = insertelement <4 x i32> undef, i32 %sub, i32 0
  %broadcast.splat20 = shufflevector <4 x i32> %broadcast.splatinsert19, <4 x i32> undef, <4 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %0 = getelementptr inbounds i32, ptr %data, i32 %index
  %wide.load = load <4 x i32>, ptr %0, align 4
  %1 = icmp sgt <4 x i32> %broadcast.splat18, %wide.load
  %2 = icmp slt <4 x i32> %broadcast.splat20, %wide.load
  %3 = or <4 x i1> %1, %2
  call void @llvm.masked.store.v4i32.p0(<4 x i32> zeroinitializer, ptr %0, i32 4, <4 x i1> %3)
  %index.next = add i32 %index, 4
  %4 = icmp eq i32 %index.next, %mul
  br i1 %4, label %for.cond.cleanup, label %vector.body

for.cond.cleanup:                                 ; preds = %vector.body, %entry
  ret void
}

define arm_aapcs_vfpcc void @thresh_rev_i16(ptr %data, i16 zeroext %N, i16 signext %T) {
; CHECK-LABEL: thresh_rev_i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it eq
; CHECK-NEXT:    popeq {r7, pc}
; CHECK-NEXT:  .LBB6_1: @ %vector.ph
; CHECK-NEXT:    mvn r3, #7
; CHECK-NEXT:    add.w r1, r3, r1, lsl #3
; CHECK-NEXT:    movs r3, #1
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    add.w lr, r3, r1, lsr #3
; CHECK-NEXT:    rsbs r1, r2, #0
; CHECK-NEXT:  .LBB6_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrh.u16 q1, [r0]
; CHECK-NEXT:    vpte.s16 ge, q1, r2
; CHECK-NEXT:    vcmpt.s16 le, q1, r1
; CHECK-NEXT:    vstrhe.16 q0, [r0], #16
; CHECK-NEXT:    le lr, .LBB6_2
; CHECK-NEXT:  @ %bb.3: @ %for.cond.cleanup
; CHECK-NEXT:    pop {r7, pc}
entry:
  %conv2 = zext i16 %N to i32
  %mul = shl nuw nsw i32 %conv2, 3
  %cmp22 = icmp eq i16 %N, 0
  br i1 %cmp22, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %sub = sub i16 0, %T
  %broadcast.splatinsert24 = insertelement <8 x i16> undef, i16 %T, i32 0
  %broadcast.splat25 = shufflevector <8 x i16> %broadcast.splatinsert24, <8 x i16> undef, <8 x i32> zeroinitializer
  %broadcast.splatinsert26 = insertelement <8 x i16> undef, i16 %sub, i32 0
  %broadcast.splat27 = shufflevector <8 x i16> %broadcast.splatinsert26, <8 x i16> undef, <8 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %0 = getelementptr inbounds i16, ptr %data, i32 %index
  %wide.load = load <8 x i16>, ptr %0, align 2
  %1 = icmp sgt <8 x i16> %broadcast.splat25, %wide.load
  %2 = icmp slt <8 x i16> %broadcast.splat27, %wide.load
  %3 = or <8 x i1> %1, %2
  call void @llvm.masked.store.v8i16.p0(<8 x i16> zeroinitializer, ptr %0, i32 2, <8 x i1> %3)
  %index.next = add i32 %index, 8
  %4 = icmp eq i32 %index.next, %mul
  br i1 %4, label %for.cond.cleanup, label %vector.body

for.cond.cleanup:                                 ; preds = %vector.body, %entry
  ret void
}

define arm_aapcs_vfpcc void @thresh_rev_i8(ptr %data, i16 zeroext %N, i8 signext %T) {
; CHECK-LABEL: thresh_rev_i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it eq
; CHECK-NEXT:    popeq {r7, pc}
; CHECK-NEXT:  .LBB7_1: @ %vector.ph
; CHECK-NEXT:    mvn r3, #15
; CHECK-NEXT:    add.w r1, r3, r1, lsl #4
; CHECK-NEXT:    movs r3, #1
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    add.w lr, r3, r1, lsr #4
; CHECK-NEXT:    rsbs r1, r2, #0
; CHECK-NEXT:  .LBB7_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrb.u8 q1, [r0]
; CHECK-NEXT:    vpte.s8 ge, q1, r2
; CHECK-NEXT:    vcmpt.s8 le, q1, r1
; CHECK-NEXT:    vstrbe.8 q0, [r0], #16
; CHECK-NEXT:    le lr, .LBB7_2
; CHECK-NEXT:  @ %bb.3: @ %for.cond.cleanup
; CHECK-NEXT:    pop {r7, pc}
entry:
  %conv2 = zext i16 %N to i32
  %mul = shl nuw nsw i32 %conv2, 4
  %cmp20 = icmp eq i16 %N, 0
  br i1 %cmp20, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %sub = sub i8 0, %T
  %broadcast.splatinsert22 = insertelement <16 x i8> undef, i8 %T, i32 0
  %broadcast.splat23 = shufflevector <16 x i8> %broadcast.splatinsert22, <16 x i8> undef, <16 x i32> zeroinitializer
  %broadcast.splatinsert24 = insertelement <16 x i8> undef, i8 %sub, i32 0
  %broadcast.splat25 = shufflevector <16 x i8> %broadcast.splatinsert24, <16 x i8> undef, <16 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %0 = getelementptr inbounds i8, ptr %data, i32 %index
  %wide.load = load <16 x i8>, ptr %0, align 1
  %1 = icmp sgt <16 x i8> %broadcast.splat23, %wide.load
  %2 = icmp slt <16 x i8> %broadcast.splat25, %wide.load
  %3 = or <16 x i1> %1, %2
  call void @llvm.masked.store.v16i8.p0(<16 x i8> zeroinitializer, ptr %0, i32 1, <16 x i1> %3)
  %index.next = add i32 %index, 16
  %4 = icmp eq i32 %index.next, %mul
  br i1 %4, label %for.cond.cleanup, label %vector.body

for.cond.cleanup:                                 ; preds = %vector.body, %entry
  ret void
}

define arm_aapcs_vfpcc void @thresh_rev_f32(ptr %data, i16 zeroext %N, float %T) {
; CHECK-LABEL: thresh_rev_f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it eq
; CHECK-NEXT:    popeq {r7, pc}
; CHECK-NEXT:  .LBB8_1: @ %vector.ph
; CHECK-NEXT:    mvn r2, #3
; CHECK-NEXT:    add.w r1, r2, r1, lsl #2
; CHECK-NEXT:    movs r2, #1
; CHECK-NEXT:    add.w lr, r2, r1, lsr #2
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    eor r2, r1, #-2147483648
; CHECK-NEXT:  .LBB8_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrw.u32 q1, [r0]
; CHECK-NEXT:    vpte.f32 ge, q1, r1
; CHECK-NEXT:    vcmpt.f32 le, q1, r2
; CHECK-NEXT:    vstrwe.32 q0, [r0], #16
; CHECK-NEXT:    le lr, .LBB8_2
; CHECK-NEXT:  @ %bb.3: @ %for.cond.cleanup
; CHECK-NEXT:    pop {r7, pc}
entry:
  %conv = zext i16 %N to i32
  %mul = shl nuw nsw i32 %conv, 2
  %cmp15 = icmp eq i16 %N, 0
  br i1 %cmp15, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %fneg = fneg fast float %T
  %broadcast.splatinsert17 = insertelement <4 x float> undef, float %T, i32 0
  %broadcast.splat18 = shufflevector <4 x float> %broadcast.splatinsert17, <4 x float> undef, <4 x i32> zeroinitializer
  %broadcast.splatinsert19 = insertelement <4 x float> undef, float %fneg, i32 0
  %broadcast.splat20 = shufflevector <4 x float> %broadcast.splatinsert19, <4 x float> undef, <4 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %0 = getelementptr inbounds float, ptr %data, i32 %index
  %wide.load = load <4 x float>, ptr %0, align 4
  %1 = fcmp fast ogt <4 x float> %broadcast.splat18, %wide.load
  %2 = fcmp fast olt <4 x float> %broadcast.splat20, %wide.load
  %3 = or <4 x i1> %1, %2
  call void @llvm.masked.store.v4f32.p0(<4 x float> zeroinitializer, ptr %0, i32 4, <4 x i1> %3)
  %index.next = add i32 %index, 4
  %4 = icmp eq i32 %index.next, %mul
  br i1 %4, label %for.cond.cleanup, label %vector.body

for.cond.cleanup:                                 ; preds = %vector.body, %entry
  ret void
}

define arm_aapcs_vfpcc void @thresh_rev_f16(ptr %data, i16 zeroext %N, float %T.coerce) {
; CHECK-LABEL: thresh_rev_f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it eq
; CHECK-NEXT:    popeq {r7, pc}
; CHECK-NEXT:  .LBB9_1: @ %vector.ph
; CHECK-NEXT:    mvn r3, #7
; CHECK-NEXT:    add.w r1, r3, r1, lsl #3
; CHECK-NEXT:    vmov r2, s0
; CHECK-NEXT:    vneg.f16 s0, s0
; CHECK-NEXT:    movs r3, #1
; CHECK-NEXT:    add.w lr, r3, r1, lsr #3
; CHECK-NEXT:    vmov.f16 r1, s0
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:  .LBB9_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrh.u16 q1, [r0]
; CHECK-NEXT:    vpte.f16 ge, q1, r2
; CHECK-NEXT:    vcmpt.f16 le, q1, r1
; CHECK-NEXT:    vstrhe.16 q0, [r0], #16
; CHECK-NEXT:    le lr, .LBB9_2
; CHECK-NEXT:  @ %bb.3: @ %for.cond.cleanup
; CHECK-NEXT:    pop {r7, pc}
entry:
  %0 = bitcast float %T.coerce to i32
  %tmp.0.extract.trunc = trunc i32 %0 to i16
  %1 = bitcast i16 %tmp.0.extract.trunc to half
  %conv = zext i16 %N to i32
  %mul = shl nuw nsw i32 %conv, 3
  %cmp17 = icmp eq i16 %N, 0
  br i1 %cmp17, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %fneg = fneg fast half %1
  %broadcast.splatinsert19 = insertelement <8 x half> undef, half %1, i32 0
  %broadcast.splat20 = shufflevector <8 x half> %broadcast.splatinsert19, <8 x half> undef, <8 x i32> zeroinitializer
  %broadcast.splatinsert21 = insertelement <8 x half> undef, half %fneg, i32 0
  %broadcast.splat22 = shufflevector <8 x half> %broadcast.splatinsert21, <8 x half> undef, <8 x i32> zeroinitializer
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %2 = getelementptr inbounds half, ptr %data, i32 %index
  %wide.load = load <8 x half>, ptr %2, align 2
  %3 = fcmp fast ogt <8 x half> %broadcast.splat20, %wide.load
  %4 = fcmp fast olt <8 x half> %broadcast.splat22, %wide.load
  %5 = or <8 x i1> %3, %4
  call void @llvm.masked.store.v8f16.p0(<8 x half> zeroinitializer, ptr %2, i32 2, <8 x i1> %5)
  %index.next = add i32 %index, 8
  %6 = icmp eq i32 %index.next, %mul
  br i1 %6, label %for.cond.cleanup, label %vector.body

for.cond.cleanup:                                 ; preds = %vector.body, %entry
  ret void
}




declare void @llvm.masked.store.v4i32.p0(<4 x i32>, ptr, i32 immarg, <4 x i1>)
declare void @llvm.masked.store.v8i16.p0(<8 x i16>, ptr, i32 immarg, <8 x i1>)
declare void @llvm.masked.store.v16i8.p0(<16 x i8>, ptr, i32 immarg, <16 x i1>)
declare void @llvm.masked.store.v4f32.p0(<4 x float>, ptr, i32 immarg, <4 x i1>)
declare void @llvm.masked.store.v8f16.p0(<8 x half>, ptr, i32 immarg, <8 x i1>)