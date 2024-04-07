; ModuleID = 'test/foo.optimized.bc'
source_filename = "test/foo.ll"

define dso_local i32 @foo(i32 noundef %0, i32 noundef %1) {
  %3 = shl i32 %1, 6
  %4 = add i32 %3, %1
  %5 = shl i32 %0, 1
  %6 = ashr i32 %5, 2
  %7 = mul nsw i32 %4, %6
  %8 = add nsw i32 %1, 4
  ret i32 %7
}
