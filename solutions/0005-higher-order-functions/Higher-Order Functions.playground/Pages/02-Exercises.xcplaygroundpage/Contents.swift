/*:
 # Higher-Order Functions Exercises

 1. Write `curry` for functions that take 3 arguments.
 */
func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D  {
    { a in
        { b in
            { c in
                f(a, b, c)
            }
        }
    }
}

struct Person {
    let firstName: String
    let lastName: String
    let age: Int
}

curry(Person.init)
/*:
 2. Explore functions and methods in the Swift standard library, Foundation, and other third party code, and convert them to free functions that compose using `curry`, `zurry`, `flip`, or by hand.
 */
func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    { a in
        { b in
            f(a, b)
        }
    }
}

func zurry<A>(_ f: @escaping () -> (A)) -> A {
    f()
}

func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    { b in
        { a in
            f(a)(b)
        }
    }
}

func flip<A, C>(_ f: @escaping (A) -> () -> C) -> () -> (A) -> C {
    {
        { a in
            f(a)()
        }
    }
}


zurry(flip(String.uppercased))("test")
/*:
 3. Explore the associativity of function arrow `->`. Is it fully associative, _i.e._ is `((A) -> B) -> C` equivalent to `(A) -> ((B) -> C)`, or does it associate to only one side? Where does it parenthesize as you build deeper, curried functions?
 */
// Not possible because is not fully associative.

/*:
 4. Write a function, `uncurry`, that takes a curried function and returns a function that takes two arguments. When might it be useful to un-curry a function?
 */
func uncurry<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (A, B) -> C {
    { (a, b) in
        f(a)(b)
    }
}

uncurry(curry(Person.init))
/*:
 5. Write `reduce` as a curried, free function. What is the configuration _vs._ the data?
 */

var test = [1, 2, 3, 4, 5]

func reduce<Result, A>(_ initialResult: Result, _ nextPartialResult: @escaping (Result, A) -> Result) -> ([A]) -> Result {
    { $0.reduce(initialResult, nextPartialResult) }
}

let reduceInt = reduce(0, +)
reduceInt(test)

// Correct awswer
func reduce<A, R>(
  _ accumulator: @escaping (R, A) -> R
) -> (R) -> ([A]) -> R {

  return { initialValue in
    return { collection in
      return collection.reduce(initialValue, accumulator)
    }
  }
}

let add: (Int, Int) -> Int = { $0 + $1 }
reduce(add)(1)([1,2,3])
/*:
 6. In programming languages that lack sum/enum types one is tempted to approximate them with pairs of optionals. Do this by defining a type `struct PseudoEither<A, B>` of a pair of optionals, and prevent the creation of invalid values by providing initializers.

    This is “type safe” in the sense that you are not allowed to construct invalid values, but not “type safe” in the sense that the compiler is proving it to you. You must prove it to yourself.
 */
struct PseudoEither<A, B> {
    let left: A?
    let right: B?
    
    init(left: A) {
        self.left = left
        self.right = nil
    }
    
    init(right: B) {
        self.left = nil
        self.right = right
    }
}

PseudoEither<Int, String>(left: 2)
PseudoEither<Int, String>(right: "test")
/*:
 7. Explore how the free `map` function composes with itself in order to transform a nested array. More specifically, if you have a doubly nested array `[[A]]`, then `map` could mean either the transformation on the inner array or the outer array. Can you make sense of doing `map >>> map`?
 */
func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> ([B]) {
  return { $0.map(f) }
}

let product: (Int) -> Int = { $0 * $0 }

let innerMap = map(product)

let outerMap = map(innerMap)

outerMap([[1, 2, 3]])

