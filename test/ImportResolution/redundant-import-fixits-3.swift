// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -emit-module -o %t %S/Inputs/inner.swift
// RUN: %target-swift-frontend -emit-module -o %t -I %t %S/Inputs/outer.swift
// RUN: %target-swift-frontend -typecheck %s -I %t -sdk "" -verify

// case where just importing `outer` is the most specific way to do imports
// inner is redundant because it's contents are used, but also provided by `outer`
// specific import `inner.Inner1` is redundant because it is provided by `inner` and `outer` and `outer` is most specific

import inner // expected-error {{Redundant import}} {{0-13=}}
import outer 
import struct inner.Inner1 // expected-error {{Redundant import}} {{0-13=}}

let _ = Inner1()
let _ = Inner2()
let _ = Outer()
