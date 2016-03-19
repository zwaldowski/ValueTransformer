//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

public struct ValueTransformer<OriginalValue, TransformedValue>: ValueTransformerType {
    public typealias Transform = OriginalValue throws -> TransformedValue

    private let transformClosure: Transform

    public init(transformClosure: Transform) {
        self.transformClosure = transformClosure
    }

    public func transform(value: OriginalValue) throws -> TransformedValue {
        return try transformClosure(value)
    }
}

extension ValueTransformer {
    public init<V: ValueTransformerType where V.OriginalValue == OriginalValue, V.TransformedValue == TransformedValue>(_ valueTransformer: V) {
        self.init(transformClosure: valueTransformer.transform)
    }
}

// MARK: - Compose

extension ValueTransformerType {

    public func compose<Other: ValueTransformerType where Other.OriginalValue == TransformedValue>(with other: Other) -> ValueTransformer<OriginalValue, Other.TransformedValue> {
        return ValueTransformer { value in
            try other.transform(self.transform(value))
        }
    }

}

infix operator >>> {
    associativity right
    precedence 170
}

public func >>> <V: ValueTransformerType, W: ValueTransformerType where V.TransformedValue == W.OriginalValue>(lhs: V, rhs: W) -> ValueTransformer<V.OriginalValue, W.TransformedValue> {
    return lhs.compose(with: rhs)
}

infix operator <<< {
    associativity right
    precedence 170
}

public func <<< <V: ValueTransformerType, W: ValueTransformerType where V.OriginalValue == W.TransformedValue>(lhs: V, rhs: W) -> ValueTransformer<W.OriginalValue, V.TransformedValue> {
    return rhs.compose(with: lhs)
}

// MARK: - Lift (Optional)

extension ValueTransformerType {

    public func lift() -> ValueTransformer<OriginalValue, TransformedValue?> {
        return ValueTransformer(transformClosure: transform)
    }

    public func lift(@autoclosure(escaping) defaultTransformedValue defaultTransformedValue: () throws -> TransformedValue) -> ValueTransformer<OriginalValue?, TransformedValue> {
        return ValueTransformer { value in
            try value.map(self.transform) ?? defaultTransformedValue()
        }
    }

    public func lift() -> ValueTransformer<OriginalValue?, TransformedValue?> {
        return lift().lift(defaultTransformedValue: nil)
    }
    
}

// MARK: - Lift (Array)

extension ValueTransformerType {

    public func lift() -> ValueTransformer<[OriginalValue], [TransformedValue]> {
        return ValueTransformer { values in
            try values.map(self.transform)
        }
    }

}

// MARK: - Deprecated

@available(*, unavailable, message="call the 'compose(with:)' method on the transformer")
public func compose<V: ValueTransformerType, W: ValueTransformerType where V.TransformedValue == W.OriginalValue>(left: V, _ right: W) -> ValueTransformer<V.OriginalValue, W.TransformedValue> {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'lift()' method on the transformer")
public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<V.OriginalValue, V.TransformedValue?> {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'lift(defaultTransformedValue:)' method on the transformer")
public func lift<V: ValueTransformerType>(valueTransformer: V, @autoclosure(escaping) defaultTransformedValue: () throws -> V.TransformedValue) -> ValueTransformer<V.OriginalValue?, V.TransformedValue> {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'lift()' method on the transformer")
public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<V.OriginalValue?, V.TransformedValue?> {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'lift()' method on the transformer")
public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<[V.OriginalValue], [V.TransformedValue]> {
    fatalError("unavailable function can't be called")
}
