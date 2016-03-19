//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Quick
import Nimble
@testable import ValueTransformer

struct ReversibleValueTransformers {
    static let string = ValueTransformers.string.combine(with: ValueTransformers.int)
}

class ReversibleValueTransformerSpecs: QuickSpec {
    override func spec() {
        describe("A (combined) ReversibleValueTransformer") {
            let valueTransformer = ReversibleValueTransformers.string

            it("should transform a value") {
                let result = try? valueTransformer.transform("1")

                expect(result) == 1
            }

            it("should fail if its value transformation fails") {
                let result = try? valueTransformer.transform("1.5")

                expect(result).to(beNil())
            }

            it("should reverse transform a value") {
                let result = try? valueTransformer.reverseTransform(2)

                expect(result) == "2"
            }

            it("should fail if its reverse value transformation fails") {
                let result = try? valueTransformer.flip().reverseTransform("2.5")

                expect(result).to(beNil())
            }
        }

        describe("A flipped ReversibleValueTransformer") {
            let valueTransformer = ReversibleValueTransformers.string.flip()

            it("should transform a value") {
                let result = try? valueTransformer.transform(3)

                expect(result) == "3"
            }

            it("should fail if its value transformation fails") {
                let result = try? valueTransformer.flip().transform("3.5")

                expect(result).to(beNil())
            }

            it("should reverse transform a value") {
                let result = try? valueTransformer.reverseTransform("4")
                
                expect(result) == 4
            }

            it("should fail if its reverse value transformation fails") {
                let result = try? valueTransformer.reverseTransform("4.5")

                expect(result).to(beNil())
            }
        }

        describe("Composed reversible value transformes") {
            let valueTransformer = ReversibleValueTransformers.string >>> ReversibleValueTransformers.string.flip()

            it("should transform a value") {
                let result = try? valueTransformer.transform("3")

                expect(result) == "3"
            }

            it("should fail if any of its value transformation fails") {
                let result = try? valueTransformer.transform("3.5")

                expect(result).to(beNil())
            }

            it("should reverse transform a value") {
                let result = try? valueTransformer.reverseTransform("4")

                expect(result) == "4"
            }

            it("should fail if its reverse value transformation fails") {
                let result = try? valueTransformer.reverseTransform("4.5")

                expect(result).to(beNil())
            }
        }

        describe("Lifted reversible value transformers") {
            context("with optional value") {
                let valueTransformer: ReversibleValueTransformer<String?, Int> = ReversibleValueTransformers.string.lift(defaultTransformedValue: 0)

                context("if given some value") {
                    it("should transform a value") {
                        let result = try? valueTransformer.transform("5")

                        expect(result) == 5
                    }

                    it("should fail if its value transformation fails") {
                        let result = try? valueTransformer.transform("5.5")

                        expect(result).to(beNil())
                    }
                }

                context("if not given some value") {
                    it("should transform to the default transformed value") {
                        let result = try? valueTransformer.transform(nil)

                        expect(result) == 0
                    }
                }

                it("should reverse transform a value") {
                    let result = try? valueTransformer.reverseTransform(6)

                    expect(result!) == "6"
                }

                it("should fail if its reverse value transformation fails") {
                    let result = try? valueTransformer.flip().reverseTransform("6.5")

                    expect(result).to(beNil())
                }
            }

            context("with optional transformed value") {
                let valueTransformer: ReversibleValueTransformer<String, Int?> = ReversibleValueTransformers.string.lift(defaultReverseTransformedValue: "zero")

                it("should transform a value") {
                    let result = try? valueTransformer.transform("7")

                    expect(result!) == 7
                }

                it("should fail if its value transformation fails") {
                    let result = try? valueTransformer.transform("7.5")

                    expect(result).to(beNil())
                }

                context("if given some transformed value") {
                    it("should reverse transform a value") {
                        let result = try? valueTransformer.reverseTransform(8)

                        expect(result) == "8"
                    }

                    it("should fail if its value transformation fails") {
                        let result = try? valueTransformer.flip().reverseTransform("8.5")

                        expect(result).to(beNil())
                    }
                }

                context("if not given some transformed value") {
                    it("should transform to the default value") {
                        let result = try? valueTransformer.reverseTransform(nil)

                        expect(result) == "zero"
                    }
                }
            }

            context("with optional value and transformed value") {
                let valueTransformer: ReversibleValueTransformer<String?, Int?> = ReversibleValueTransformers.string.lift()

                context("if given some value") {
                    it("should transform a value") {
                        let result = try? valueTransformer.transform("9")

                        expect(result!) == 9
                    }

                    it("should fail if its value transformation fails") {
                        let result = try? valueTransformer.transform("9.5")

                        expect(result).to(beNil())
                    }
                }

                context("if not given some value") {
                    it("should transform to nil") {
                        let result = try? valueTransformer.transform(nil)

                        expect(result!).to(beNil())
                    }
                }

                context("if given some transformed value") {
                    it("should reverse transform a value") {
                        let result = try? valueTransformer.reverseTransform(10)

                        expect(result!).to(equal("10"))
                    }

                    it("should fail if its value transformation fails") {
                        let result = try? valueTransformer.flip().reverseTransform("10.5")

                        expect(result).to(beNil())
                    }
                }

                context("if not given some transformed value") {
                    it("should transform to nil") {
                        let result = try? valueTransformer.reverseTransform(nil)

                        expect(result!).to(beNil())
                    }
                }
            }

            context("with array value and transformed value") {
                let valueTransformer: ReversibleValueTransformer<[String], [Int]> = ReversibleValueTransformers.string.lift()

                it("should transform a value") {
                    let result = try? valueTransformer.transform([ "11", "12" ])

                    expect(result).to(equal([ 11, 12 ]))
                }

                it("should fail if any of its value transformation fails") {
                    let result = try? valueTransformer.transform([ "11", "12.5" ])

                    expect(result).to(beNil())
                }

                it("should reverse transform a value") {
                    let result = try? valueTransformer.reverseTransform([ 13, 14 ])

                    expect(result).to(equal([ "13", "14" ]))
                }

                it("should fail if its reverse value transformation fails") {
                    let result = try? valueTransformer.flip().reverseTransform([ "13", "14.5" ])
                    
                    expect(result).to(beNil())
                }
            }
        }
    }
}
