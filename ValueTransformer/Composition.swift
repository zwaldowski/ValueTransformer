//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Lustre

// MARK: - Operators

infix operator >>> {
    associativity right
    precedence 170
}

infix operator <<< {
    associativity right
    precedence 170
}

// MARK: - Combine

public func combine<V: ValueTransformerType, W: ValueTransformerType where V.Input == W.TransformResult.Value, V.TransformResult.Value == W.Input>(valueTransformer: V, reverseValueTransformer: W) -> ReversibleValueTransformer<V.TransformResult, W.TransformResult> {
    return ReversibleValueTransformer(transformClosure: transform(valueTransformer), reverseTransformClosure: transform(reverseValueTransformer))
}

// MARK: - Flip

public func flip<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> ReversibleValueTransformer<V.ReverseTransformResult, V.ForwardTransformResult> {
    return ReversibleValueTransformer(transformClosure: reverseTransform(reversibleValueTransformer), reverseTransformClosure: forwardTransform(reversibleValueTransformer))
}

// MARK: - Compose

public func compose<V: ValueTransformerType, W: ValueTransformerType where V.TransformResult.Value == W.Input>(left: V, right: W) -> ValueTransformer<V.Input, W.TransformResult> {
    return ValueTransformer {
        left.transform($0).flatMap(transform(right))
    }
}

public func compose<V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.ForwardTransformResult.Value == W.ReverseTransformResult.Value>(left: V, right: W) -> ReversibleValueTransformer<W.ForwardTransformResult, V.ReverseTransformResult> {
    return combine(forward(left) >>> forward(right), forward(flip(right)) >>> forward(flip(left)))
}

public func >>> <V: ValueTransformerType, W: ValueTransformerType where V.TransformResult.Value == W.Input>(lhs: V, rhs: W) -> ValueTransformer<V.Input, W.TransformResult> {
    return compose(lhs, rhs)
}

public func >>> <V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.ForwardTransformResult.Value == W.ReverseTransformResult.Value>(lhs: V, rhs: W) -> ReversibleValueTransformer<W.ForwardTransformResult, V.ReverseTransformResult> {
    return compose(lhs, rhs)
}

public func <<< <V: ValueTransformerType, W: ValueTransformerType where V.Input == W.TransformResult.Value>(lhs: V, rhs: W) -> ValueTransformer<W.Input, V.TransformResult> {
    return compose(rhs, lhs)
}

public func <<< <V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where W.ForwardTransformResult.Value == V.ReverseTransformResult.Value>(lhs: V, rhs: W) -> ReversibleValueTransformer<V.ForwardTransformResult, W.ReverseTransformResult> {
    return compose(rhs, lhs)
}

// MARK: - Lift (Optional)

public func lift<V: ValueTransformerType>(toOptional valueTransformer: V) -> ValueTransformer<V.Input, AnyResult<V.TransformResult.Value?>> {
    return ValueTransformer {
        valueTransformer.transform($0).map { .Some($0) }
    }
}

public func lift<V: ValueTransformerType>(fromOptional valueTransformer: V, #defaultTransformedValue: V.TransformResult.Value) -> ValueTransformer<V.Input?, V.TransformResult> {
    return ValueTransformer {
        $0.map(transform(valueTransformer)) ?? success(defaultTransformedValue)
    }
}

public func lift<V: ValueTransformerType>(optionals valueTransformer: V) -> ValueTransformer<V.Input?, AnyResult<V.TransformResult.Value?>> {
    return lift(fromOptional: lift(toOptional: valueTransformer), defaultTransformedValue: nil)
}

public func lift<V: ReversibleValueTransformerType>(fromOptional reversibleValueTransformer: V, #defaultReverseTransformedValue: V.ReverseTransformResult.Value) -> ReversibleValueTransformer<AnyResult<V.ForwardTransformResult.Value?>, V.ReverseTransformResult> {
    return combine(lift(toOptional: forward(reversibleValueTransformer)), lift(fromOptional: forward(flip(reversibleValueTransformer)), defaultTransformedValue: defaultReverseTransformedValue))
}

public func lift<V: ReversibleValueTransformerType>(toOptional reversibleValueTransformer: V, #defaultTransformedValue: V.ForwardTransformResult.Value) -> ReversibleValueTransformer<V.ForwardTransformResult, AnyResult<V.ReverseTransformResult.Value?>> {
    return combine(lift(fromOptional: forward(reversibleValueTransformer), defaultTransformedValue: defaultTransformedValue), lift(toOptional: forward(flip(reversibleValueTransformer))))
}

public func lift<V: ReversibleValueTransformerType>(optionals reversibleValueTransformer: V) -> ReversibleValueTransformer<AnyResult<V.ForwardTransformResult.Value?>, AnyResult<V.ReverseTransformResult.Value?>> {
    return combine(lift(optionals: forward(reversibleValueTransformer)), lift(optionals: forward(flip(reversibleValueTransformer))))
}

// MARK: - Lift (Array)

public func lift<V: ValueTransformerType, S: SequenceType, C: ExtensibleCollectionType, R: ResultType where S.Generator.Element == V.Input, C.Generator.Element == V.TransformResult.Value, C.Index.Distance: SignedIntegerType, R.Value == C>(collection valueTransformer: V) -> ValueTransformer<S, R> {
    return ValueTransformer {
        var initialArray = C()
        initialArray.reserveCapacity(numericCast(underestimateCount($0)))
        return reduce($0, success(initialArray)) { (result, value) in
            result.flatMap { result in
                valueTransformer.transform(value).map { value in
                    result + CollectionOfOne(value)
                }
            }
        }
    }
}

public func lift<V: ValueTransformerType, S: SequenceType, R: ResultType where S.Generator.Element == V.Input, R.Value == Array<V.TransformResult.Value>>(toArray valueTransformer: V) -> ValueTransformer<S, R> {
    return lift(collection: valueTransformer)
}

public func lift<V: ValueTransformerType>(arrays valueTransformer: V) -> ValueTransformer<[V.Input], AnyResult<[V.TransformResult.Value]>> {
    return lift(collection: valueTransformer)
}

public func lift<V: ReversibleValueTransformerType, L: ResultType, LC: ExtensibleCollectionType, R: ResultType, RC: ExtensibleCollectionType where RC.Generator.Element == V.ForwardTransformResult.Value, LC.Generator.Element == V.ReverseTransformResult.Value, LC.Index.Distance: SignedIntegerType, RC.Index.Distance: SignedIntegerType, L.Value == RC, R.Value == LC>(collection reversibleValueTransformer: V) -> ReversibleValueTransformer<L, R> {
    return combine(lift(collection: forward(reversibleValueTransformer)), lift(collection: forward(flip(reversibleValueTransformer))))
}

public func lift<V: ReversibleValueTransformerType, L: ResultType, LC: ExtensibleCollectionType, R: ResultType, RC: ExtensibleCollectionType where L.Value == Array<V.ForwardTransformResult.Value>, R.Value == Array<V.ReverseTransformResult.Value>>(toArray reversibleValueTransformer: V) -> ReversibleValueTransformer<L, R> {
    return lift(collection: reversibleValueTransformer)
}

public func lift<V: ReversibleValueTransformerType>(arrays reversibleValueTransformer: V) -> ReversibleValueTransformer<AnyResult<[V.ForwardTransformResult.Value]>, AnyResult<[V.ReverseTransformResult.Value]>> {
    return lift(collection: reversibleValueTransformer)
}
