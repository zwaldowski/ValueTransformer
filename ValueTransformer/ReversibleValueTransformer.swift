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

extension ValueTransformerType {

    public func combine<Other: ValueTransformerType where OriginalValue == Other.TransformedValue, TransformedValue == Other.OriginalValue>(with other: Other) -> ReversibleValueTransformer<OriginalValue, TransformedValue> {
        return .init(transformClosure: transform, reverseTransformClosure: other.transform)
    }

}

infix operator >>> {
    associativity right
    precedence 170
}

public func >>> <V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.TransformedValue == W.OriginalValue>(lhs: V, rhs: W) -> ReversibleValueTransformer<V.OriginalValue, W.TransformedValue> {
    return lhs.compose(with: rhs)
}

infix operator <<< {
    associativity right
    precedence 170
}

public func <<< <V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.OriginalValue == W.TransformedValue>(lhs: V, rhs: W) -> ReversibleValueTransformer<W.OriginalValue, V.TransformedValue> {
    return rhs.compose(with: lhs)
}

// MARK: - Flip

extension ReversibleValueTransformerType {

    public func flip() -> ReversibleValueTransformer<TransformedValue, OriginalValue> {
        return .init(transformClosure: reverseTransform, reverseTransformClosure: transform)
    }

}

// MARK: - Compose

extension ReversibleValueTransformerType {

    public func compose<Other: ReversibleValueTransformerType where TransformedValue == Other.OriginalValue>(with other: Other) -> ReversibleValueTransformer<OriginalValue, Other.TransformedValue> {
        return (compose(with: other) as ValueTransformer).combine(with: other.flip().compose(with: flip()) as ValueTransformer)
    }

}

// MARK: - Lift (Optional)

extension ReversibleValueTransformerType {

    public func lift(@autoclosure(escaping) defaultReverseTransformedValue defaultReverseTransformedValue: () throws -> OriginalValue) -> ReversibleValueTransformer<OriginalValue, TransformedValue?> {
        return (lift() as ValueTransformer).combine(with: flip().lift(defaultTransformedValue: defaultReverseTransformedValue) as ValueTransformer)
    }

    public func lift(@autoclosure(escaping) defaultTransformedValue defaultTransformedValue: () throws -> TransformedValue) -> ReversibleValueTransformer<OriginalValue?, TransformedValue> {
        return (lift(defaultTransformedValue: defaultTransformedValue) as ValueTransformer).combine(with: flip().lift() as ValueTransformer)
    }

    public func lift() -> ReversibleValueTransformer<OriginalValue?, TransformedValue?> {
        return (lift() as ValueTransformer).combine(with: flip().lift() as ValueTransformer)
    }

}

// MARK: - Lift (Array)

extension ReversibleValueTransformerType {

    public func lift() -> ReversibleValueTransformer<[OriginalValue], [TransformedValue]> {
        return (lift() as ValueTransformer).combine(with: flip().lift() as ValueTransformer)
    }

}

// MARK: - Deprecated

@available(*, unavailable, message="call the 'combine(with:)' method on the transformer")
public func combine<V: ValueTransformerType, W: ValueTransformerType where V.OriginalValue == W.TransformedValue, V.TransformedValue == W.OriginalValue>(valueTransformer: V, _ reverseValueTransformer: W) -> ReversibleValueTransformer<V.OriginalValue, V.TransformedValue> {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'flip()' method on the transformer")
public func flip<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> ReversibleValueTransformer<V.TransformedValue, V.OriginalValue> {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'compose(with:)' method on the transformer")
public func compose<V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.TransformedValue == W.OriginalValue>(left: V, _ right: W) -> ReversibleValueTransformer<V.OriginalValue, W.TransformedValue> {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'lift(defaultReverseTransformedValue:)' method on the transformer")
public func lift<V: ReversibleValueTransformerType>(reversibleValueTransformer: V, defaultReverseTransformedValue: V.OriginalValue) -> ReversibleValueTransformer<V.OriginalValue, V.TransformedValue?> {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'lift(defaultTransformedValue:)' method on the transformer")
public func lift<V: ReversibleValueTransformerType>(reversibleValueTransformer: V, defaultTransformedValue: V.TransformedValue) -> ReversibleValueTransformer<V.OriginalValue?, V.TransformedValue> {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'lift()' method on the transformer")
public func lift<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> ReversibleValueTransformer<V.OriginalValue?, V.TransformedValue?> {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'lift()' method on the transformer")
public func lift<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> ReversibleValueTransformer<[V.OriginalValue], [V.TransformedValue]> {
    fatalError("unavailable function can't be called")
}
