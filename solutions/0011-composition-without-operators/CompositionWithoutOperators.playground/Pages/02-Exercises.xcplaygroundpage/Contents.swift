/*:
 # Composition without Operators

 1. Write concat for functions (inout A) -> Void.
 */
func concat<A>(_ f: @escaping (inout A) -> Void,
               _ g: @escaping (inout A) -> Void,
               _ fs: ((inout A) -> Void)...) -> (inout A) -> Void {
    { a in
        f(&a)
        g(&a)
        fs.forEach { $0(&a) }
    }
}

func mInc(_ n: inout Int) {
    n = n + 1
}

func mSquare(_ n: inout Int) {
    n = n * n
}

let inoutIncAndSquare = concat(mInc, mSquare)

var number = 1

inoutIncAndSquare(&number)

number


/*:
 2. Write concat for functions (A) -> A.
 */
func concat<A>(_ f: @escaping (A) -> A,
               _  g: @escaping (A) -> A,
               _ fs: ((A) -> A)...) -> (A) -> A {
    { a in
        ([f, g] + fs).reduce(a) { $1($0) }
    }
}

let incrAndSquare = concat(incr, square)

incrAndSquare(1)
/*:
 3. Write compose for backward composition. Recreate some of the examples from our functional setters episodes (part 1 and part 2) using compose and pipe.
 */
func compose<A, B, C>(_ f: @escaping (B) -> C, _ g: @escaping (A) -> B) -> (A) -> C {
    { f(g($0)) }
}

func pipe<A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    { g(f($0)) }
}

func with<A, B>(_ value: A, _ f: (A) -> B) -> B {
    f(value)
}

struct Food {
  var name: String
}

struct Location {
  var name: String
}

struct User {
  var favoriteFoods: [Food]
  var location: Location
  var name: String
}

let user = User(
  favoriteFoods: [Food(name: "Tacos"), Food(name: "Nachos")],
  location: Location(name: "Brooklyn"),
  name: "Blob"
)

func first<A, B, C>(_ f: @escaping (A) -> B) -> ((A, C)) -> (B, C) {
  return { pair in
    (f(pair.0), pair.1)
  }
}

func userLocationName(_ f: @escaping (String) -> String) -> (User) -> User {
  return { user in
    User(
      favoriteFoods: user.favoriteFoods,
      location: Location(name: f(user.location.name)),
      name: user.name
    )
  }
}

func prop<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
  -> (@escaping (Value) -> Value)
  -> (Root)
  -> Root {

    return { update in
      { root in
        var copy = root
        copy[keyPath: kp] = update(copy[keyPath: kp])
        return copy
      }
    }
}

prop(\User.name) // ((String) -> String) -> (User) -> User

compose(prop(\User.location), prop(\.name))
prop(\User.location.name)

user
  |> (prop(\.name)) { $0.uppercased() }
  |> (prop(\.location.name)) { _ in "Los Angeles" }

with(user,
     concat(
        (prop(\.name)) { $0.uppercased() },
        (prop(\.location.name)) { _ in "Los Angeles" }
    )
)


with(
    (user, 42),
    (
        compose(
            first,
            (prop(\User.name))
        )
    ) { $0.uppercased() }
)
