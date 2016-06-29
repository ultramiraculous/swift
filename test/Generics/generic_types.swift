// RUN: %target-parse-verify-swift

protocol MyFormattedPrintable {
  func myFormat() -> String
}

func myPrintf(_ format: String, _ args: MyFormattedPrintable...) {}

extension Int : MyFormattedPrintable {
  func myFormat() -> String { return "" }
}

struct S<T : MyFormattedPrintable> {
  var c : T
  static func f(_ a: T) -> T {
    return a
  }
  func f(_ a: T, b: Int) {
    return myPrintf("%v %v %v", a, b, c)
  }
}

func makeSInt() -> S<Int> {}

typealias SInt = S<Int>
var a : S<Int> = makeSInt()
a.f(1,b: 2)
var b : Int = SInt.f(1)

struct S2<T> {
  @discardableResult
  static func f() -> T {
    S2.f()
  }
}

struct X { }

var d : S<X> // expected-error{{type 'X' does not conform to protocol 'MyFormattedPrintable'}}

enum Optional<T> {
  case element(T)
  case none

  init() { self = .none }
  init(_ t: T) { self = .element(t) }
}
typealias OptionalInt = Optional<Int>
var uniontest1 : (Int) -> Optional<Int> = OptionalInt.element
var uniontest2 : Optional<Int> = OptionalInt.none
var uniontest3 = OptionalInt(1)

// FIXME: Stuff that should work, but doesn't yet.
// var uniontest4 : OptInt = .none
// var uniontest5 : OptInt = .Some(1)

func formattedTest<T : MyFormattedPrintable>(_ a: T) {
  myPrintf("%v", a)
}
struct formattedTestS<T : MyFormattedPrintable> {
  func f(_ a: T) {
    formattedTest(a)
  }
}

struct GenericReq<T : IteratorProtocol, U : IteratorProtocol>
  where T.Element == U.Element {
}

func getFirst<R : IteratorProtocol>(_ r: R) -> R.Element {
  var r = r
  return r.next()!
}

func testGetFirst(ir: CountableRange<Int>) {
  _ = getFirst(ir.makeIterator()) as Int
}

struct XT<T> {
  init(t : T) {
    prop = (t, t)
  }

  static func f() -> T {}
  func g() -> T {}

  var prop : (T, T)
}

class YT<T> {
  init(_ t : T) {
    prop = (t, t)
  }
  deinit {}

  class func f() -> T {}
  func g() -> T {}

  var prop : (T, T)
}

struct ZT<T> {
  var x : T, f : Float
}

struct Dict<K, V> {
  subscript(key: K) -> V { get {} set {} }
}

class Dictionary<K, V> { // expected-note{{generic type 'Dictionary' declared here}}
  subscript(key: K) -> V { get {} set {} }
}

typealias XI = XT<Int>
typealias YI = YT<Int>
typealias ZI = ZT<Int>

var xi = XI(t: 17)
var yi = YI(17)
var zi = ZI(x: 1, f: 3.0)

var i : Int = XI.f()
i = XI.f()
i = xi.g()
i = yi.f() // expected-error{{static member 'f' cannot be used on instance of type 'YI' (aka 'YT<Int>')}}
i = yi.g()

var xif : (XI) -> () -> Int = XI.g
var gif : (YI) -> () -> Int = YI.g

var ii : (Int, Int) = xi.prop
ii = yi.prop
xi.prop = ii
yi.prop = ii

var d1 : Dict<String, Int>
var d2 : Dictionary<String, Int>
d1["hello"] = d2["world"]
i = d2["blarg"]

struct RangeOfPrintables<R : Sequence>
  where R.Iterator.Element : MyFormattedPrintable {
  var r : R

  func format() -> String {
    var s : String
    for e in r {
      s = s + e.myFormat() + " "
    }
    return s
  }
}

struct Y {}
struct SequenceY : Sequence, IteratorProtocol {
  typealias Iterator = SequenceY
  typealias Element = Y

  func next() -> Element? { return Y() }
  func makeIterator() -> Iterator { return self }
}

func useRangeOfPrintables(_ roi : RangeOfPrintables<[Int]>) {
  var rop : RangeOfPrintables<X> // expected-error{{type 'X' does not conform to protocol 'Sequence'}}
  var rox : RangeOfPrintables<SequenceY> // expected-error{{type 'Element' (aka 'Y') does not conform to protocol 'MyFormattedPrintable'}}
}

struct HasNested<T> {
  init<U>(_ t: T, _ u: U) {}
  func f<U>(_ t: T, u: U) -> (T, U) {}

  struct InnerGeneric<U> { // expected-error{{generic type 'InnerGeneric' nested}}
    init() {}
    func g<V>(_ t: T, u: U, v: V) -> (T, U, V) {}
  }

  struct Inner { // expected-error{{nested in generic type}}
    init (_ x: T) {}
    func identity(_ x: T) -> T { return x }
  }
}

func useNested(_ ii: Int, hni: HasNested<Int>,
               xisi : HasNested<Int>.InnerGeneric<String>,
               xfs: HasNested<Float>.InnerGeneric<String>) {
  var i = ii, xis = xisi
  typealias InnerI = HasNested<Int>.Inner
  var innerI = InnerI(5)
  typealias InnerF = HasNested<Float>.Inner
  var innerF : InnerF = innerI // expected-error{{cannot convert value of type 'InnerI' (aka 'HasNested<Int>.Inner') to specified type 'InnerF' (aka 'HasNested<Float>.Inner')}}

  _ = innerI.identity(i)
  i = innerI.identity(i)

  // Generic function in a generic class
  typealias HNI = HasNested<Int>
  var id = hni.f(1, u: 3.14159)
  id = (2, 3.14159)
  hni.f(1.5, 3.14159) // expected-error{{missing argument label 'u:' in call}}
  hni.f(1.5, u: 3.14159) // expected-error{{cannot convert value of type 'Double' to expected argument type 'Int'}}

  // Generic constructor of a generic struct
  HNI(1, 2.71828) // expected-warning{{unused}}
  HNI(1.5, 2.71828) // expected-error{{'Double' is not convertible to 'Int'}}

  // Generic function in a nested generic struct
  var ids = xis.g(1, u: "Hello", v: 3.14159)
  ids = (2, "world", 2.71828)

  xis = xfs // expected-error{{cannot assign value of type 'HasNested<Float>.InnerGeneric<String>' to type 'HasNested<Int>.InnerGeneric<String>'}}
}

var dfail : Dictionary<Int> // expected-error{{generic type 'Dictionary' specialized with too few type parameters (got 1, but expected 2)}}
var notgeneric : Int<Float> // expected-error{{cannot specialize non-generic type 'Int'}}{{21-28=}}

// Check unqualified lookup of inherited types.
class Foo<T> {
  typealias Nested = T
}

class Bar : Foo<Int> {
  func f(_ x: Int) -> Nested {
    return x
  }

  struct Inner {
    func g(_ x: Int) -> Nested {
      return x
    }

    func withLocal() {
      struct Local {
        func h(_ x: Int) -> Nested {
          return x
        }
      }
    }
  }
}

extension Bar {
  func g(_ x: Int) -> Nested {
    return x
  }

  /* This crashes for unrelated reasons: <rdar://problem/14376418>
  struct Inner2 {
    func f(_ x: Int) -> Nested {
      return x
    }
  }
  */
}

// Make sure that redundant typealiases (that map to the same
// underlying type) don't break protocol conformance or use.
class XArray : ArrayLiteralConvertible {
  typealias Element = Int
  init() { }

  required init(arrayLiteral elements: Int...) { }
}

class YArray : XArray {
  typealias Element = Int
  required init(arrayLiteral elements: Int...) {
    super.init()
  }
}

var yarray : YArray = [1, 2, 3]
var xarray : XArray = [1, 2, 3]

// Type parameters can be referenced only via unqualified name lookup
struct XParam<T> {
  func foo(_ x: T) {
    _ = x as T
  }

  static func bar(_ x: T) {
    _ = x as T
  }
}

var xp : XParam<Int>.T = Int() // expected-error{{'T' is not a member type of 'XParam<Int>'}}

// Diagnose failure to meet a superclass requirement.
class X1 { }
class X2<T : X1> { } // expected-note{{requirement specified as 'T' : 'X1' [with T = X3]}}
class X3 { }

var x2 : X2<X3> // expected-error{{'X2' requires that 'X3' inherit from 'X1'}}

protocol P {
  associatedtype AssocP
}

protocol Q {
  associatedtype AssocQ
}

struct X4 : P, Q {
  typealias AssocP = Int
  typealias AssocQ = String
}

struct X5<T, U> where T: P, T: Q, T.AssocP == T.AssocQ { } // expected-note{{requirement specified as 'T.AssocP' == 'T.AssocQ' [with T = X4]}}

var y: X5<X4, Int> // expected-error{{'X5' requires the types 'AssocP' (aka 'Int') and 'AssocQ' (aka 'String') be equivalent}}

// Recursive generic signature validation.
class Top {}
class Bottom<T : Bottom<Top>> {} // expected-error {{type may not reference itself as a requirement}}

class X6<T> {
  let d: D<T>
  init(_ value: T) {
    d = D(value)
  }
  class D<T2> { // expected-error{{generic type 'D' nested in type 'X6' is not allowed}}
    init(_ value: T2) {}
  }
}

// Invalid inheritance clause

struct UnsolvableInheritance1<T : T.A> {}
// expected-error@-1 {{inheritance from non-protocol, non-class type 'T.A'}}

struct UnsolvableInheritance2<T : U.A, U : T.A> {}
// expected-error@-1 {{inheritance from non-protocol, non-class type 'U.A'}}
// expected-error@-2 {{inheritance from non-protocol, non-class type 'T.A'}}

enum X7<T> where X7.X : G { case X } // expected-error{{'X' is not a member type of 'X7<T>'}}
