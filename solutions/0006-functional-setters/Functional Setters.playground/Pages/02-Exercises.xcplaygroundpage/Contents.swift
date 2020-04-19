/*:
 # Functional Setters Exercises
 
 1. As we saw with free `map` on `Array`, define free `map` on `Optional` and use it to compose setters that traverse into an optional field.
 */
func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> (B?) {
{
    $0.map(f)
    }
}

let mapToString = map { (n: Int) -> String in
    String(n)
}

mapToString(3)
mapToString(nil)
/*:
 2. Take the following `User` struct and write a setter for its `name` property. Add another property, and add a setter for it. What are some potential issues with building these setters?
 */
// Issues
// Not using right property

struct User {
    let name: String
    let age: Int
}

func userName(_ f: @escaping (String) -> String) -> (User) -> User {
    { User(name: f($0.name), age: $0.age) }
}

func userAge(_ f: @escaping (Int) -> Int) -> (User) -> User {
    { User(name: $0.name, age: f($0.age)) }
}

let setterName = userName { _ in "Setter" }
let setterAge = userAge { _ in 15 }

let user = User(name: "Jon", age: 12)

setterName(user)
setterAge(user)
/*:
 3. Add a `location` property to `User`, which holds a `Location`, defined below. Write a setter for `userLocationName`. Now write setters for `userLocation` and `locationName`. How do these setters compose?
 */
struct Location {
    let name: String
}

struct UserWithLocation {
    let name: String
    let age: Int
    let location: Location
}

func userLocationName(_ f: @escaping (String) -> String) -> (UserWithLocation) -> UserWithLocation {
    { user in
        let newLocation = Location(name: f(user.location.name))
        return UserWithLocation(name: user.name, age: user.age, location: newLocation)
    }
}

func userLocation(_ f: @escaping (Location) -> Location) -> (UserWithLocation) -> UserWithLocation {
    {
        UserWithLocation(name: $0.name, age: $0.age, location: f($0.location))
    }
}

func locationName(_ f: @escaping (String) -> String) -> (Location) -> Location {
    {
        Location(name: f($0.name))
    }
}

let userLocationNameSetter = (locationName >>> userLocation) { _ in "test" }
print(type(of: userLocationNameSetter))
/*:
 4. Do `first` and `second` work with tuples of three or more values? Can we write `first`, `second`, `third`, and `nth` for tuples of _n_ values?
 */
// Not worked. No, because you can not traverses a tuple of n values.

func first<A, B, C>(_ f: @escaping (A) -> C) -> ((A, B)) -> (C, B) {
  return { pair in
    (f(pair.0), pair.1)
  }
}

func second<A, B, C>(_ f: @escaping (B) -> C) -> ((A, B)) -> (A, C) {
  return { pair in
    (pair.0, f(pair.1))
  }
}

let threeValues = (1, 2, 3)

//threeValues
//    |> first(incr)

/*:
 5. Write a setter for a dictionary that traverses into a key to set a value.
 */
func dictionaryValeu<Key, Value>(_ f: @escaping (Value?) -> Value?) -> ([Key: Value], Key) -> [Key: Value] {
    { (dict, key) in
        var dict = dict
        dict[key] = f(dict[key])
        return dict
    }
}

let dict = ["test": 1]

(dict, "test") |> dictionaryValeu { $0.map { $0 + 2 } }
/*:
 6. Write a setter for a dictionary that traverses into a key to set a value if and only if that value already exists.
 */
func dictionaryValueIfExists<Key, Value>(_ f: @escaping (Value) -> Value) -> ([Key: Value], Key) -> [Key: Value] {
    { (dict, key) in
        var dict = dict
        dict[key] = dict[key].map(f)
        return dict
    }
}

(dict, "test") |> dictionaryValueIfExists { $0 + 2 }
/*:
 7. What is the difference between a function of the form `((A) -> B) -> (C) -> (D)` and one of the form `(A) -> (B) -> (C) -> D`?
 */


typealias A = Any
typealias B = Any
typealias C = Any
typealias D = Any

func test1() -> ((A) -> B) -> (C) -> (D) {
    fatalError()
}

func test2() -> (A) -> (B) -> (C) -> D {
    fatalError()
}

//test1()(<#T##(A) -> B#>)(<#T##C#>)
//test2()(<#T##A#>)(<#T##B#>)(<#T##C#>)

// First function first parameter is function
// Second function first paramater is value
