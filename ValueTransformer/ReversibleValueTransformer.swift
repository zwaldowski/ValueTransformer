//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Lustre

public struct ReversibleValueTransformer<Value, Result: ResultType, ReverseResult: ResultType>: ReversibleValueTransformerType {
    private let transformClosure: Value -> Result
    private let reverseTransformClosure: Result.Value -> ReverseResult

    public init(transformClosure: Value -> Result, reverseTransformClosure: Result.Value -> ReverseResult) {
        self.transformClosure = transformClosure
        self.reverseTransformClosure = reverseTransformClosure
    }

    public func transform(value: Value) -> Result {
        return transformClosure(value)
    }

    public func reverseTransform(transformedValue: Result.Value) -> ReverseResult {
        return reverseTransformClosure(transformedValue)
    }
}

extension ReversibleValueTransformer {
    public init<V: ReversibleValueTransformerType where V.Value == Value, V.TransformResult.Value == Result.Value, V.ReverseTransformResult.Value == ReverseResult.Value>(_ reversibleValueTransformer: V) {
        self.init(transformClosure: { value in
            reversibleValueTransformer.transform(value).map { $0 }
        }, reverseTransformClosure: { transformedValue in
            reversibleValueTransformer.reverseTransform(transformedValue).map { $0 }
        })
    }
}

// MARK: - Combine

public func combine<V: ValueTransformerType, W: ValueTransformerType where V.Value == W.TransformResult.Value, V.TransformResult.Value == W.Value>(valueTransformer: V, reverseValueTransformer: W) -> ReversibleValueTransformer<V.Value, V.TransformResult, W.TransformResult> {
    return ReversibleValueTransformer(transformClosure: transform(valueTransformer), reverseTransformClosure: transform(reverseValueTransformer))
}

// MARK: - Flip

public func flip<V: ReversibleValueTransformerType where V.Value == V.ReverseTransformResult.Value>(reversibleValueTransformer: V) -> ReversibleValueTransformer<V.TransformResult.Value, V.ReverseTransformResult, V.TransformResult> {
    return ReversibleValueTransformer(transformClosure: reverseTransform(reversibleValueTransformer), reverseTransformClosure: transform(reversibleValueTransformer))
}

// MARK: - Compose

public func compose<V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.TransformResult.Value == W.Value, V.Value == V.ReverseTransformResult.Value, W.Value == W.ReverseTransformResult.Value>(left: V, right: W) -> ReversibleValueTransformer<V.Value, W.TransformResult, V.ReverseTransformResult> {
    return combine(left >>> right as ValueTransformer, flip(right) >>> flip(left) as ValueTransformer)
}

infix operator >>> {
    associativity right
    precedence 170
}


public func >>> <V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.TransformResult.Value == W.Value, V.Value == V.ReverseTransformResult.Value, W.Value == W.ReverseTransformResult.Value>(lhs: V, rhs: W) -> ReversibleValueTransformer<V.Value, W.TransformResult, V.ReverseTransformResult> {
    return compose(lhs, rhs)
}

infix operator <<< {
    associativity right
    precedence 170
}

public func <<< <V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.Value == W.TransformResult.Value, V.Value == V.ReverseTransformResult.Value, W.Value == W.ReverseTransformResult.Value>(lhs: V, rhs: W) -> ReversibleValueTransformer<W.Value, V.TransformResult, W.ReverseTransformResult> {
    return compose(rhs, lhs)
}

// MARK: - Lift (Optional)

public func lift<V: ReversibleValueTransformerType where V.Value == V.ReverseTransformResult.Value>(reversibleValueTransformer: V, #defaultReverseTransformedValue: V.Value) -> ReversibleValueTransformer<V.Value, AnyResult<V.TransformResult.Value?>, V.ReverseTransformResult> {
    return combine(lift(reversibleValueTransformer) as ValueTransformer, lift(flip(reversibleValueTransformer), defaultTransformedValue: defaultReverseTransformedValue) as ValueTransformer)
}

public func lift<V: ReversibleValueTransformerType where V.Value == V.ReverseTransformResult.Value>(reversibleValueTransformer: V, #defaultTransformedValue: V.TransformResult.Value) -> ReversibleValueTransformer<V.Value?, V.TransformResult, AnyResult<V.Value?>> {
    return combine(lift(reversibleValueTransformer, defaultTransformedValue: defaultTransformedValue) as ValueTransformer, lift(flip(reversibleValueTransformer)) as ValueTransformer)
}

public func lift<V: ReversibleValueTransformerType where V.Value == V.ReverseTransformResult.Value>(reversibleValueTransformer: V) -> ReversibleValueTransformer<V.Value?, AnyResult<V.TransformResult.Value?>, AnyResult<V.ReverseTransformResult.Value?>> {
    return combine(lift(reversibleValueTransformer) as ValueTransformer, lift(flip(reversibleValueTransformer)) as ValueTransformer)
}

// MARK: - Lift (Array)

public func lift<V: ReversibleValueTransformerType where V.Value == V.ReverseTransformResult.Value>(reversibleValueTransformer: V) -> ReversibleValueTransformer<[V.Value], AnyResult<[V.TransformResult.Value]>, AnyResult<[V.Value]>> {
    return combine(lift(reversibleValueTransformer) as ValueTransformer, lift(flip(reversibleValueTransformer)) as ValueTransformer)
}

