; ModuleID = 'test/foo.optimized.bc'
source_filename = "test/foo.ll"

define dso_local i32 @foo(i32 noundef %0, i32 noundef %1) {
  %3 = add nsw i32 %1, 1
  %4 = shl i32 %3, 6
  %5 = add i32 %4, %3
  %6 = shl i32 %0, 1
  %7 = ashr i32 %6, 2
  %8 = mul nsw i32 %5, %7
  ret i32 %8
}
