/*:
 # Algebraic Data Types: Exponents, Exercises

 1. Explore the equivalence of `1^a = a`.
 */

let a = 5

pow(1, a) != a
pow(1, 6) != 6

// Not has equivalence.

//1 ^ a != a
// 1 <- a != a
// a -> 1 != a

// A -> Void != A

//func to<A>(_ a: A) -> (A) -> Void {
//    { a in }
//}
//
//func from<A>(_ f: (A) -> Void) -> A {
//    f(<#A#>)
//}
/*:
 2. Explore the properties of `0^a`. Consider the cases where `a = 0` and `a != 0` separately.
 */
// case a != 0

pow(0, 1) == 0
pow(0, 2) == 0

// 0 ^ a = 0
// 0 <- a = 0
// a -> 0 = 0
// (A) -> Never = Never

func to<A>(_ f: (A) -> Never) -> Never {
    fatalError()
}

func from<A>(_ never: Never) -> (A) -> Never {
    { a in
        switch never {
            
        }
    }
}

// case a = 0
pow(0,  0)

// 0 ^ 0 = 1
// 0 <- 0 = 1
// 0 -> 0 = 1
// (Never) -> Never = Void

func to(_ f: (Never) -> Never) -> Void {
    ()
}

func from() -> (Never) -> Never {
    { never in never }
}
/*:
 3. How do you think generics fit into algebraic data types? We've seen a bit of this with thinking of `Optional<A>` as `A + 1 = A + Void`.
 */
// A + 1 = A + Void
// It is like a placeholder for other expression.
/*:
 4. Show that the set type over a type `A` can be represented as `2^A`. What does union and intersection look like in this formulation?
 */
// TODO

// 2 ^ a
// 2 <- a
// a -> 2

struct Pair<A> {
    let a1: A
    let a2: A
}



/*:
 5. Show that the dictionary type with keys in `K`  and values in `V` can be represented by `V^K`. What does union of dictionaries look like in this formulation?
 */
// v ^ k
// v <- k
// k -> v
// (K) -> V

/*:
 6. Implement the following equivalence:
 */
func to<A, B, C>(_ f: @escaping (Either<B, C>) -> A) -> ((B) -> A, (C) -> A) {
    (
        { b in
            f(.left(b))
        },
        { c in
            f(.right(c))
        }
    )
}

func from<A, B, C>(_ f: ((B) -> A, (C) -> A)) -> (Either<B, C>) -> A {
    { either in
        switch either {
        case .left(let b):
            return f.0(b)
        case .right(let c):
            return f.1(c)
        }
    }
}
/*:
 7. Implement the following equivalence:
 */
func to<A, B, C>(_ f: @escaping (C) -> (A, B)) -> ((C) -> A, (C) -> B) {
    (
        { c in
            f(c).0
        },
        { c in
            f(c).1
        }
    )
}

func from<A, B, C>(_ f: ((C) -> A, (C) -> B)) -> (C) -> (A, B) {
    { c in
        (f.0(c), f.1(c))
    }
}
