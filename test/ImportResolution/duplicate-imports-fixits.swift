// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -emit-module -o %t %S/Inputs/asdf.swift
// RUN: %target-swift-frontend -typecheck %s -I %t -sdk "" -verify

// Tests that `asdf` is imported more than once.
// The first import in the file should be untouched.

import asdf
import asdf // expected-error {{Duplicate import}} {{0-12=}}
import asdf // expected-error {{Redundant import}} {{0-12=}}
