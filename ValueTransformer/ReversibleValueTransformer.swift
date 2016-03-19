//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

public struct ReversibleValueTransformer<OriginalValue, TransformedValue>: ReversibleValueTransformerType {
    public typealias Transform = OriginalValue throws -> TransformedValue
    public typealias ReverseTransform = TransformedValue throws -> OriginalValue

    private let transformClosure: Transform
    private let reverseTransformClosure: ReverseTransform

    public init(transformClosure: Transform, reverseTransformClosure: ReverseTransform) {
        self.transformClosure = transformClosure
        self.reverseTransformClosure = reverseTransformClosure
    }

    public func transform(value: OriginalValue) throws -> TransformedValue {
        return try transformClosure(value)
    }

    public func reverseTransform(transformedValue: TransformedValue) throws -> OriginalValue {
        return try reverseTransformClosure(transformedValue)
    }
}

extension ReversibleValueTransformer {
    public init<V: ReversibleValueTransformerType where V.OriginalValue == OriginalValue, V.TransformedValue == TransformedValue>(_ reversibleValueTransformer: V) {
        self.init(transformClosure: reversibleValueTransformer.transform, reverseTransformClosure: reversibleValueTransformer.reverseTransform)
    }
}

// MARK: - Combine

public func combine<V: ValueTransformerType, W: ValueTransformerType where V.OriginalValue == W.TransformedValue, V.TransformedValue == W.OriginalValue>(valueTransformer: V, _ reverseValueTransformer: W) -> ReversibleValueTransformer<V.OriginalValue, V.TransformedValue> {
    return .init(transformClosure: valueTransformer.transform, reverseTransformClosure: reverseValueTransformer.transform)
}

// MARK: - Flip

public func flip<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> ReversibleValueTransformer<V.TransformedValue, V.OriginalValue> {
    return ReversibleValueTransformer(transformClosure: reversibleValueTransformer.reverseTransform, reverseTransformClosure: reversibleValueTransformer.transform)
}

// MARK: - Compose

public func compose<V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.TransformedValue == W.OriginalValue>(left: V, _ right: W) -> ReversibleValueTransformer<V.OriginalValue, W.TransformedValue> {
    return combine(left >>> right as ValueTransformer, flip(right) >>> flip(left) as ValueTransformer)
}

infix operator >>> {
    associativity right
    precedence 170
}

public func >>> <V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.TransformedValue == W.OriginalValue>(lhs: V, rhs: W) -> ReversibleValueTransformer<V.OriginalValue, W.TransformedValue> {
    return compose(lhs, rhs)
}

infix operator <<< {
    associativity right
    precedence 170
}

public func <<< <V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.OriginalValue == W.TransformedValue>(lhs: V, rhs: W) -> ReversibleValueTransformer<W.OriginalValue, V.TransformedValue> {
    return compose(rhs, lhs)
}

// MARK: - Lift (Optional)

public func lift<V: ReversibleValueTransformerType>(reversibleValueTransformer: V, defaultReverseTransformedValue: V.OriginalValue) -> ReversibleValueTransformer<V.OriginalValue, V.TransformedValue?> {
    return combine(lift(reversibleValueTransformer) as ValueTransformer, lift(flip(reversibleValueTransformer), defaultTransformedValue: defaultReverseTransformedValue) as ValueTransformer)
}

public func lift<V: ReversibleValueTransformerType>(reversibleValueTransformer: V, defaultTransformedValue: V.TransformedValue) -> ReversibleValueTransformer<V.OriginalValue?, V.TransformedValue> {
    return combine(lift(reversibleValueTransformer, defaultTransformedValue: defaultTransformedValue) as ValueTransformer, lift(flip(reversibleValueTransformer)) as ValueTransformer)
}

public func lift<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> ReversibleValueTransformer<V.OriginalValue?, V.TransformedValue?> {
    return combine(lift(reversibleValueTransformer) as ValueTransformer, lift(flip(reversibleValueTransformer)) as ValueTransformer)
}

// MARK: - Lift (Array)

public func lift<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> ReversibleValueTransformer<[V.OriginalValue], [V.TransformedValue]> {
    return combine(lift(reversibleValueTransformer) as ValueTransformer, lift(flip(reversibleValueTransformer)) as ValueTransformer)
}
