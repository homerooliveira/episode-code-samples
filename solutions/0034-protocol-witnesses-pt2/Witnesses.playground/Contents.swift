
protocol Describable {
  var describe: String { get }
}

struct Describing<A> {
  let describe: (A) -> String

  func contramap<B>(_ f: @escaping (B) -> A) -> Describing<B> {
    return Describing<B> { b in
      self.describe(f(b))
    }
  }
}

struct PostgresConnInfo {
  var database: String
  var hostname: String
  var password: String
  var port: Int
  var user: String
}


let compactWitness = Describing<PostgresConnInfo> { conn in
  return "PostgresConnInfo(database: \"\(conn.database)\", hostname: \"\(conn.hostname)\", password: \"\(conn.password)\", port: \"\(conn.port)\", user: \"\(conn.user)\")"
}

import Overture

let secureCompactWitness = compactWitness.contramap(set(\.password, "*******"))

let localhostPostgres = PostgresConnInfo(
  database: "pointfreeco_development",
  hostname: "localhost",
  password: "",
  port: 5432,
  user: "pointfreeco"
)

print(secureCompactWitness.describe(localhostPostgres))

compactWitness.describe(localhostPostgres)

let prettyWitness = Describing<PostgresConnInfo> {
  """
  PostgresConnInfo(
    database: \"\($0.database)\",
    hostname: \"\($0.hostname)\",
    password: \"\($0.password)\",
    port: \"\($0.port)\",
    user: \"\($0.user)\"
  )
  """
}

let securePrettyWitness = prettyWitness.contramap(set(\.password, "******"))

prettyWitness.describe(localhostPostgres)
print(securePrettyWitness.describe(localhostPostgres))

let connectionWitness = Describing<PostgresConnInfo> {
  "postgres://\($0.user):\($0.password)@\($0.hostname):\($0.port)/\($0.database)"
}

connectionWitness.describe(localhostPostgres)

//extension PostgresConnInfo: Describable {
//  var describe: String {
//    return "PostgresConnInfo(database: \"\(self.database)\", hostname: \"\(self.hostname)\", password: \"\(self.password)\", port: \"\(self.port)\", user: \"\(self.user)\")"
//  }
//}

//extension PostgresConnInfo: Describable {
//  var describe: String {
//    return """
//PostgresConnInfo(
//  database: \"\(self.database)\",
//  hostname: \"\(self.hostname)\",
//  password: \"\(self.password)\",
//  port: \"\(self.port)\",
//  user: \"\(self.user)\"
//)
//"""
//  }
//}

extension PostgresConnInfo: Describable {
  var describe: String {
    return "postgres://\(self.user):\(self.password)@\(self.hostname):\(self.port)/\(self.database)"
  }
}


print(localhostPostgres.describe)

func print<A>(tag: String, _ value: A, _ witness: Describing<A>) {
  print("[\(tag)] \(witness.describe(value))")
}

func print<A: Describable>(tag: String, _ value: A) {
  print("[\(tag)] \(value.describe)")
}

print(tag: "debug", localhostPostgres, connectionWitness)
print(tag: "debug", localhostPostgres, prettyWitness)
print(tag: "debug", localhostPostgres)


extension Int: Describable {
  var describe: String {
    return "\(self)"
  }
}

2.describe


protocol EmptyInitializable {
  init()
}

struct EmptyInitializing<A> {
  let create: () -> A
}

extension String: EmptyInitializable {
}
extension Array: EmptyInitializable {
}
extension Int: EmptyInitializable {
  init() {
    self = 1
  }
}
extension Optional: EmptyInitializable {
  init() {
    self = nil
  }
}

[1, 2, 3].reduce(0, +)

extension Array {
  func reduce<Result: EmptyInitializable>(_ accumulation: (Result, Element) -> Result) -> Result {
    return self.reduce(Result(), accumulation)
  }
}

[1, 2, 3].reduce(+)
[[1, 2], [], [3, 4]].reduce(+)
["Hello", " ", "Blob"].reduce(+)

protocol Combinable {
  func combine(with other: Self) -> Self
}

struct Combining<A> {
  let combine: (A, A) -> A
}

extension Int: Combinable {
  func combine(with other: Int) -> Int {
    return self * other
  }
}
extension String: Combinable {
  func combine(with other: String) -> String {
    return self + other
  }
}
extension Array: Combinable {
  func combine(with other: Array) -> Array {
    return self + other
  }
}
extension Optional: Combinable {
  func combine(with other: Optional) -> Optional {
    return self ?? other
  }
}

extension Array where Element: Combinable {
  func reduce(_ initial: Element) -> Element {
    return self.reduce(initial) { $0.combine(with: $1) }
  }
}

extension Array /* where Element: Combinable */ {
  func reduce(_ initial: Element, _ combining: Combining<Element>) -> Element {
    return self.reduce(initial, combining.combine)
  }
}

[1, 2, 3].reduce(1)
[[1, 2], [], [3, 4]].reduce([])
[nil, nil, 3].reduce(nil)

let sum = Combining<Int>(combine: +)
[1, 2, 3, 4].reduce(0, sum)

let product = Combining<Int>(combine: *)
[1, 2, 3, 4].reduce(1, product)


extension Array where Element: Combinable & EmptyInitializable {
  func reduce() -> Element {
    return self.reduce(Element()) { $0.combine(with: $1) }
  }
}

extension Array {
  func reduce(_ initial: EmptyInitializing<Element>, _ combining: Combining<Element>) -> Element {
    return self.reduce(initial.create(), combining.combine)
  }
}


[1, 2, 3, 4].reduce()
[[1, 2], [], [3, 4]].reduce()
[nil, nil, 3].reduce()

let zero = EmptyInitializing<Int> { 0 }
[1, 2, 3, 4].reduce(zero, sum)
let one = EmptyInitializing<Int> { 1 }
[1, 2, 3, 4].reduce(one, product)



//extension Int: Combinable {
//  func combine(with other: Int) -> Int {
//    return self * other
//  }
//}

struct Equating<A> {
    let equal: (A, A) -> Bool
}

let intEquatable = Equating<Int> {
    $0 == $1
}

extension Combining {
    static func pair<A, B>(_ a: Combining<A>, _ b: Combining<B>) -> Combining<(A, B)> {
        Combining<(A, B)> { (lhs, rhs) -> (A, B) in
            (
                a.combine(lhs.0, rhs.0),
                b.combine(lhs.1, rhs.1)
            )
        }
    }
    
    static func pointwise<A, B>(_ a: Combining<A>, _ b: Combining<B>) -> Combining<(A) -> B> {
        Combining<(A) -> B> { (lhs, rhs) -> ((A) -> B) in
            { input in
                b.combine(
                    lhs(a.combine(input, input)),
                    rhs(a.combine(input, input))
                )
            }
        }
    }
    
    static func array(_ a: Combining<A>) -> Combining<[A]> {
        Combining<[A]> { (lhs, rhs) in
            zip(lhs, rhs).reduce(into: []) { (result, arg) in
                result.append(a.combine(arg.0, arg.1))
            }
        }
    }
}

let concat = Combining<String>(combine: +)

let pair: Combining<(String, Int)> = .pair(concat, sum)
pair.combine(("A", 1), ("B", 2))

let pointwise: Combining<(String) -> Int> = .pointwise(concat, sum)

let parseInt: (String) -> Int = { Int($0)! }

pointwise.combine(parseInt, parseInt)("1")

Combining
    .array(product)
    .combine([1, 2], [1, 3])

struct RawRepresenting<Value, RawValue> {
    let convert: (RawValue) -> Value?
    let rawValue: (Value) -> RawValue
}

extension RawRepresenting where Value: RawRepresentable, Value.RawValue == RawValue {
    static var rawRepresentable: RawRepresenting<Value, RawValue> {
        RawRepresenting(
            convert: Value.init(rawValue:),
            rawValue: get(\.rawValue)
        )
    }
}

enum Foo: String {
    case bar
    case baz
}

let fooRR = RawRepresenting<Foo, String>.rawRepresentable

fooRR.rawValue(.bar)
fooRR.convert("bar")


let stringToInt = RawRepresenting<Int, String>(
    convert: Int.init,
    rawValue: get(\.description)
)

stringToInt.rawValue(1)

struct Test: Comparable {
    let i: Int
    
    static func < (lhs: Test, rhs: Test) -> Bool {
        lhs.i < rhs.i
    }
}

struct Comparing<A> {
    let equating: Equating<A>
    let lessThan: (A, A) -> Bool
    var lessOrEqualThan: (A, A) -> Bool {
        { (lhs, rhs) in
            self.lessThan(lhs, rhs)
                || self.equating.equal(lhs, rhs)
        }
    }
    var greaterThan: (A, A) -> Bool {
        { (lhs, rhs) in
            !self.lessThan(lhs, rhs)
        }
    }
    
    var greaterOrEqualThan: (A, A) -> Bool {
        { (lhs, rhs) in
            !self.lessOrEqualThan(lhs, rhs)
        }
    }
}

let intComparing = Comparing<Int>(
    equating: .init(equal: ==),
    lessThan: <
)

intComparing.equating.equal(1, 2)
intComparing.lessThan(1, 2)
intComparing.lessOrEqualThan(1, 2)
intComparing.greaterThan(1, 2)
intComparing.greaterOrEqualThan(1, 2)

protocol DefaultDescribable {
    static var `default`: Describing<Self> { get }
}

extension DefaultDescribable {
    static var `default`: Describing<Self> {
        Describing<Self>(describe: String.init(describing:))
    }
}

func print<A: DefaultDescribable>(tag: String, _ value: A) {
    let witness = A.default
    print("[\(tag)] \(witness.describe(value))")
}

struct Bar {
    let value: Int
}

extension Bar: DefaultDescribable {}

print(tag: "debug", Bar(value: 12))
