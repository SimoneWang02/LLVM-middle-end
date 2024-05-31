; ModuleID = 'test/loop-fusion/two-loops.base.bc'
source_filename = "test/loop-fusion/two-loops.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@__const.main.b = private unnamed_addr constant [3 x [3 x i32]] [[3 x i32] [i32 1, i32 1, i32 1], [3 x i32] [i32 1, i32 1, i32 1], [3 x i32] [i32 1, i32 1, i32 1]], align 16
@__const.main.c = private unnamed_addr constant [3 x [3 x i32]] [[3 x i32] [i32 1, i32 1, i32 1], [3 x i32] [i32 1, i32 1, i32 1], [3 x i32] [i32 1, i32 1, i32 1]], align 16

define dso_local void @foo(ptr noundef %0, ptr noundef %1) {
  %3 = alloca [3 x [3 x i32]], align 16
  %4 = alloca [3 x [3 x i32]], align 16
  br label %5

5:                                                ; preds = %30, %2
  %.01 = phi i32 [ 0, %2 ], [ %31, %30 ]
  %6 = icmp slt i32 %.01, 3
  br i1 %6, label %7, label %32

7:                                                ; preds = %5
  br label %8

8:                                                ; preds = %27, %7
  %.0 = phi i32 [ 0, %7 ], [ %28, %27 ]
  %9 = icmp slt i32 %.0, 3
  br i1 %9, label %10, label %29

10:                                               ; preds = %8
  %11 = sext i32 %.01 to i64
  %12 = getelementptr inbounds [3 x i32], ptr %0, i64 %11
  %13 = sext i32 %.0 to i64
  %14 = getelementptr inbounds [3 x i32], ptr %12, i64 0, i64 %13
  %15 = load i32, ptr %14, align 4
  %16 = sdiv i32 1, %15
  %17 = sext i32 %.01 to i64
  %18 = getelementptr inbounds [3 x i32], ptr %1, i64 %17
  %19 = sext i32 %.0 to i64
  %20 = getelementptr inbounds [3 x i32], ptr %18, i64 0, i64 %19
  %21 = load i32, ptr %20, align 4
  %22 = mul nsw i32 %16, %21
  %23 = sext i32 %.01 to i64
  %24 = getelementptr inbounds [3 x [3 x i32]], ptr %3, i64 0, i64 %23
  %25 = sext i32 %.0 to i64
  %26 = getelementptr inbounds [3 x i32], ptr %24, i64 0, i64 %25
  store i32 %22, ptr %26, align 4
  br label %27

27:                                               ; preds = %10
  %28 = add nsw i32 %.0, 1
  br label %8, !llvm.loop !6

29:                                               ; preds = %8
  br label %30

30:                                               ; preds = %29
  %31 = add nsw i32 %.01, 1
  br label %5, !llvm.loop !8

32:                                               ; preds = %5
  br label %33

33:                                               ; preds = %57, %32
  %.12 = phi i32 [ 0, %32 ], [ %58, %57 ]
  %34 = icmp slt i32 %.12, 3
  br i1 %34, label %35, label %59

35:                                               ; preds = %33
  br label %36

36:                                               ; preds = %54, %35
  %.1 = phi i32 [ 0, %35 ], [ %55, %54 ]
  %37 = icmp slt i32 %.1, 3
  br i1 %37, label %38, label %56

38:                                               ; preds = %36
  %39 = sext i32 %.12 to i64
  %40 = getelementptr inbounds [3 x [3 x i32]], ptr %3, i64 0, i64 %39
  %41 = sext i32 %.1 to i64
  %42 = getelementptr inbounds [3 x i32], ptr %40, i64 0, i64 %41
  %43 = load i32, ptr %42, align 4
  %44 = sext i32 %.12 to i64
  %45 = getelementptr inbounds [3 x i32], ptr %1, i64 %44
  %46 = sext i32 %.1 to i64
  %47 = getelementptr inbounds [3 x i32], ptr %45, i64 0, i64 %46
  %48 = load i32, ptr %47, align 4
  %49 = mul nsw i32 %43, %48
  %50 = sext i32 %.12 to i64
  %51 = getelementptr inbounds [3 x [3 x i32]], ptr %4, i64 0, i64 %50
  %52 = sext i32 %.1 to i64
  %53 = getelementptr inbounds [3 x i32], ptr %51, i64 0, i64 %52
  store i32 %49, ptr %53, align 4
  br label %54

54:                                               ; preds = %38
  %55 = add nsw i32 %.1, 1
  br label %36, !llvm.loop !9

56:                                               ; preds = %36
  br label %57

57:                                               ; preds = %56
  %58 = add nsw i32 %.12, 1
  br label %33, !llvm.loop !10

59:                                               ; preds = %33
  ret void
}

define dso_local i32 @main() {
  %1 = alloca [3 x [3 x i32]], align 16
  %2 = alloca [3 x [3 x i32]], align 16
  call void @llvm.memcpy.p0.p0.i64(ptr align 16 %1, ptr align 16 @__const.main.b, i64 36, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 16 %2, ptr align 16 @__const.main.c, i64 36, i1 false)
  %3 = getelementptr inbounds [3 x [3 x i32]], ptr %1, i64 0, i64 0
  %4 = getelementptr inbounds [3 x [3 x i32]], ptr %2, i64 0, i64 0
  call void @foo(ptr noundef %3, ptr noundef %4)
  ret i32 0
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #0

attributes #0 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 17.0.6 (++20231209124227+6009708b4367-1~exp1~20231209124336.77)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
!10 = distinct !{!10, !7}
