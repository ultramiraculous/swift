// RUN: rm -rf %t && mkdir -p %t
// RUN: %target-build-swift -lswiftSwiftReflectionTest %s -o %t/reflect_Int16
// RUN: %target-run %target-swift-reflection-test %t/reflect_Int16 2>&1 | FileCheck %s --check-prefix=CHECK-%target-ptrsize
// REQUIRES: objc_interop

import SwiftReflectionTest

class TestClass {
    var t: Int16
    init(t: Int16) {
        self.t = t
    }
}

var obj = TestClass(t: 123)

reflect(object: obj)

// CHECK-64: Reflecting an object.
// CHECK-64: Instance pointer in child address space: 0x{{[0-9a-fA-F]+}}
// CHECK-64: Type reference:
// CHECK-64: (class reflect_Int16.TestClass)

// CHECK-64: Type info:
// CHECK-64: (class_instance size=18 alignment=16 stride=32 num_extra_inhabitants=0
// CHECK-64:   (field name=t offset=16
// CHECK-64:     (struct size=2 alignment=2 stride=2 num_extra_inhabitants=0
// CHECK-64:       (field name=_value offset=0
// CHECK-64:         (builtin size=2 alignment=2 stride=2 num_extra_inhabitants=0)))))

// CHECK-32: Reflecting an object.
// CHECK-32: Instance pointer in child address space: 0x{{[0-9a-fA-F]+}}
// CHECK-32: Type reference:
// CHECK-32: (class reflect_Int16.TestClass)

// CHECK-32: Type info:
// CHECK-32: (class_instance size=14 alignment=16 stride=16 num_extra_inhabitants=0
// CHECK-32:   (field name=t offset=12
// CHECK-32:     (struct size=2 alignment=2 stride=2 num_extra_inhabitants=0
// CHECK-32:       (field name=_value offset=0
// CHECK-32:         (builtin size=2 alignment=2 stride=2 num_extra_inhabitants=0)))))

reflect(any: obj)

// CHECK-64: Reflecting an existential.
// CHECK-64: Instance pointer in child address space: 0x{{[0-9a-fA-F]+}}
// CHECK-64: Type reference:
// CHECK-64: (class reflect_Int16.TestClass)

// CHECK-64: Type info:
// CHECK-64: (reference kind=strong refcounting=native)

// CHECK-32: Reflecting an existential.
// CHECK-32: Instance pointer in child address space: 0x{{[0-9a-fA-F]+}}
// CHECK-32: Type reference:
// CHECK-32: (class reflect_Int16.TestClass)

// CHECK-32: Type info:
// CHECK-32: (reference kind=strong refcounting=native)

doneReflecting()

// CHECK-64: Done.

// CHECK-32: Done.
