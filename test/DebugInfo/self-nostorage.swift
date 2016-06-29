// RUN: %target-swift-frontend -primary-file %s -emit-ir -g -o - | FileCheck %s

public struct S {
  func f() {
    // CHECK: define {{.*}}_TFV4main1S1ffT_T_
    // CHECK: call void @llvm.dbg.value(metadata i{{.*}} 0,
    // CHECK-SAME:                      metadata ![[SELF:[0-9]+]]
    // CHECK: ![[SELF]] = !DILocalVariable(name: "self", arg: 1,
  }
}
