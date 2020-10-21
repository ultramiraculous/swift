// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -emit-module -o %t %S/Inputs/asdf.swift
// RUN: %target-swift-frontend -typecheck %s -I %t -sdk "" -verify

// Tests that `asdf` is flagged for not being used

import asdf // expected-error {{Unused import}} {{0-12=}}
