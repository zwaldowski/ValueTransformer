//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Lustre

public struct ValueTransformer<Value, Result: ResultType>: ValueTransformerType {
    private let transformClosure: Value -> Result

    public init(transformClosure: Value -> Result) {
        self.transformClosure = transformClosure
    }

    public func transform(value: Value) -> Result {
        return transformClosure(value)
    }
}

extension ValueTransformer {
    public init<V: ValueTransformerType where V.Value == Value, V.TransformResult.Value == Result.Value>(_ valueTransformer: V) {
        self.init(transformClosure: { value in
            valueTransformer.transform(value).map { $0 }
        })
    }
}

// MARK: - Compose

public func compose<V: ValueTransformerType, W: ValueTransformerType where V.TransformResult.Value == W.Value>(left: V, right: W) -> ValueTransformer<V.Value, W.TransformResult> {
    return ValueTransformer { value in
        left.transform(value).flatMap(transform(right))
    }
}

infix operator >>> {
    associativity right
    precedence 170
}

public func >>> <V: ValueTransformerType, W: ValueTransformerType where V.TransformResult.Value == W.Value>(lhs: V, rhs: W) -> ValueTransformer<V.Value, W.TransformResult> {
    return compose(lhs, rhs)
}

infix operator <<< {
    associativity right
    precedence 170
}

public func <<< <V: ValueTransformerType, W: ValueTransformerType where V.Value == W.TransformResult.Value>(lhs: V, rhs: W) -> ValueTransformer<W.Value, V.TransformResult> {
    return compose(rhs, lhs)
}

// MARK: - Lift (Optional)

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<V.Value, AnyResult<V.TransformResult.Value?>> {
    return ValueTransformer { value in
        valueTransformer.transform(value).map { .Some($0) }
    }
}

public func lift<V: ValueTransformerType>(valueTransformer: V, #defaultTransformedValue: V.TransformResult.Value) -> ValueTransformer<V.Value?, V.TransformResult> {
    return ValueTransformer {
        $0.map(transform(valueTransformer)) ?? success(defaultTransformedValue)
    }
}

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<V.Value?, AnyResult<V.TransformResult.Value?>> {
    return lift(lift(valueTransformer), defaultTransformedValue: nil)
}

// MARK: - Lift (Array)

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<[V.Value], AnyResult<[V.TransformResult.Value]>> {
    return ValueTransformer { values in
        values.reduce(success([])) { (result, value) in
            result.flatMap { result in
                valueTransformer.transform(value).map { value in
                    result + [ value ]
                }
            }
        }
    }
}
