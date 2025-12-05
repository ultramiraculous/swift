// RUN: %target-typecheck-verify-swift

// https://github.com/swiftlang/swift/issues/85837

@resultBuilder public enum BasicTupleBuilder {
    public static func buildBlock<each T>(_ content: repeat each T) -> (repeat each T) {
        return (repeat each content)
    }
}

@resultBuilder public enum TupleBuilder {
    public static func buildPartialBlock<T>(first: T) -> (T) {
        return first
    }

    public static func buildPartialBlock<each A, B>(accumulated: (repeat each A), next: B) -> (repeat each A, B) {
        return (repeat each accumulated, next)
    }
}

func builder<each A>(@TupleBuilder content: ()->(repeat each A)) -> (repeat each A) {
    return content()
}


// MARK: Builder calls

// MARK: - Multi-value

let builderFlat: (String, Int, String) = builder {
        "a"
        2
        "c"
    }

let builderNested: ((String, Int), String) = builder {
        "a"
        2
        "c"
    }

// Implicitly: (String, Int, String)
let builderUntyped = builder {
        "a"
        2
        "c"
    }

// MARK: - Single value

let builderSingleRaw: String = builder {
        "a"
    }

let builderSingleTuple: (String) = builder {
        "a"
    }

// Implicitly: `String`
let builderSingleUntyped = builder {
        "a"
    }


/*========
Manual Construction
==========*/

// MARK: Manual builder calls

// MARK: - Multi-value

let manualBuildFlat: (String, Int, String) = {
    let a = TupleBuilder.buildPartialBlock(first: "a")
    let b = TupleBuilder.buildPartialBlock(accumulated: a, next: 2)
    return TupleBuilder.buildPartialBlock(accumulated: b, next: "c")
}()

let manualBuilNested: ((String, Int), String) = {
    let a = TupleBuilder.buildPartialBlock(first: "a")
    let b = TupleBuilder.buildPartialBlock(accumulated: a, next: 2)
    return TupleBuilder.buildPartialBlock(accumulated: b, next: "c")
}()

// Implicitly: (String, Int, String)
let manualBuildUntyped = {
    let a = TupleBuilder.buildPartialBlock(first: "a")
    let b = TupleBuilder.buildPartialBlock(accumulated: a, next: 2)
    return TupleBuilder.buildPartialBlock(accumulated: b, next: "c")
}()

// MARK: - Single value

let manualBuildSingleRaw: String = {
    return TupleBuilder.buildPartialBlock(first: "a")
}()

let manualBuildSingleTuple: (String) = {
    return TupleBuilder.buildPartialBlock(first: "a")

}()

// Implicitly: `String`
let manualBuildSingleUntyped = {
    return TupleBuilder.buildPartialBlock(first: "a")
}()
