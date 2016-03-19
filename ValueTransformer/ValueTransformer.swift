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

public func compose<V: ValueTransformerType, W: ValueTransformerType where V.TransformedValue == W.OriginalValue>(left: V, _ right: W) -> ValueTransformer<V.OriginalValue, W.TransformedValue> {
    return ValueTransformer { value in
        try right.transform(left.transform(value))
    }
}

infix operator >>> {
    associativity right
    precedence 170
}

public func >>> <V: ValueTransformerType, W: ValueTransformerType where V.TransformedValue == W.OriginalValue>(lhs: V, rhs: W) -> ValueTransformer<V.OriginalValue, W.TransformedValue> {
    return compose(lhs, rhs)
}

infix operator <<< {
    associativity right
    precedence 170
}

public func <<< <V: ValueTransformerType, W: ValueTransformerType where V.OriginalValue == W.TransformedValue>(lhs: V, rhs: W) -> ValueTransformer<W.OriginalValue, V.TransformedValue> {
    return compose(rhs, lhs)
}

// MARK: - Lift (Optional)

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<V.OriginalValue, V.TransformedValue?> {
    return ValueTransformer { value in
        return try valueTransformer.transform(value)
    }
}

public func lift<V: ValueTransformerType>(valueTransformer: V, @autoclosure(escaping) defaultTransformedValue: () throws -> V.TransformedValue) -> ValueTransformer<V.OriginalValue?, V.TransformedValue> {
    return ValueTransformer { value in
        try value.map(valueTransformer.transform) ?? defaultTransformedValue()
    }
}

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<V.OriginalValue?, V.TransformedValue?> {
    return lift(lift(valueTransformer), defaultTransformedValue: nil)
}

// MARK: - Lift (Array)

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<[V.OriginalValue], [V.TransformedValue]> {
    return ValueTransformer { values in
        try values.map(valueTransformer.transform)
    }
}
