// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -emit-module -o %t %S/Inputs/inner.swift
// RUN: %target-swift-frontend -emit-module -o %t -I %t %S/Inputs/outer.swift
// RUN: %target-swift-frontend -typecheck %s -I %t -sdk "" -verify

// case where just importing `inner` is the most succinct way to do imports
// outer is redundant because none of its contents are used, but it provides `inner`
// specific import `inner.Inner1` is redundant because multple things in `inner` are used

import inner
import outer // expected-error {{Redundant import}} {{0-13=}}
import struct inner.Inner1 // expected-error {{Redundant import}} {{0-27=}}

let _ = Inner1()
let _ = Inner2() 
let _ = Inner1() // Duplicate this useage to verify that duplicate uses do not influence the "utility" of a given import
