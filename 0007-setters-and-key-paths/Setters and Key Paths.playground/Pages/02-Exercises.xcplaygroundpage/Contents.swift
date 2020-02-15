/*:
 # Setters and Key Paths Exercises

 1. In this episode we used `Dictionary`’s subscript key path without explaining it much. For a `key: Key`, one can construct a key path `\.[key]` for setting a value associated with `key`. What is the signature of the setter `prop(\.[key])`? Explain the difference between this setter and the setter `prop(\.[key]) <<< map`, where `map` is the optional map.
 */
import Foundation

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

public func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
  return { $0.map(f) }
}

type(of: prop(\Dictionary<String, String>.["test"]))

let test: (String?) -> String? = map { _ in "test" }
var dict = ["test": "s"]

let testProp = prop(\[String: String]["test"])

testProp { _ in "test" }(dict)
/// The difference is the prop(\.[key])  <<< map /// only set if the key exist
/*:
 2. The `Set<A>` type in Swift does not have any key paths that we can use for adding and removing values. However, that shouldn't stop us from defining a functional setter! Define a function `elem` with signature `(A) -> ((Bool) -> Bool) -> (Set<A>) -> Set<A>`, which is a functional setter that allows one to add and remove a value `a: A` to a set by providing a transformation `(Bool) -> Bool`, where the input determines if the value is already in the set and the output determines if the value should be included.
 */
func elem<A>(_ element: A)
    -> (@escaping (Bool) -> Bool)
    -> (Set<A>)
    -> Set<A> {
    { include in
        { set in
            var set = set
            let contains = set.contains(element)
            
            if include(contains) {
                set.insert(element)
            } else {
                set.remove(element)
            }
            
            return set
        }
    }
}

let elementString = elem("Test")
let set: Set<String> = ["Bar", "Baz", "Test"]

elementString { !$0 } (set)



/*:
 3. Generalizing exercise #1 a bit, it turns out that all subscript methods on a type get a compiler generated key path. Use array’s subscript key path to uppercase the first favorite food for a user. What happens if the user’s favorite food array is empty?
 */
struct Location {
    var name: String
}

struct Food {
    var name: String
}

struct User {
    var favoriteFoods: [Food]
    var location: Location
    var name: String
}

let users: [User] = [User(favoriteFoods: [], location: Location(name: "bla"), name: "bla")]

let userProp = prop(\User.favoriteFoods[0].name)({ $0.uppercased() })

//dump(users.map(userProp)) //Occur a crash because user’s favorite food array is empty
/*:
 4. Recall from a [previous episode](https://www.pointfree.co/episodes/ep5-higher-order-functions) that the free `filter` function on arrays has the signature `((A) -> Bool) -> ([A]) -> [A]`. That’s kinda setter-like! What does the composed setter `prop(\\User.favoriteFoods) <<< filter` represent?
 */
func filter<A>(_ predicate: @escaping (A) -> Bool) -> ([A]) -> [A] {
    {
        $0.filter(predicate)
    }
}

// ((Food) -> Bool) -> (User) -> User
type(of: (prop(\User.favoriteFoods) <<< filter))
/*:
 5. Define the `Result<Value, Error>` type, and create `value` and `error` setters for safely traversing into those cases.
 */
func value<Value, Error>(_ value: @escaping(Value) -> Value)
    -> (Result<Value, Error>) -> Result<Value, Error> {
    { result in
        result.map(value)
    }
}

func error<Value, Error>(_ error: @escaping(Error) -> Error)
    -> (Result<Value, Error>) -> Result<Value, Error> {
    { result in
        result.mapError(error)
    }
}

let result: Result<String, Error> = .success("bla")

let valueSetter: (Result<String, Error>) -> Result<String, Error> = value { _ in "test" }
let errorSetter: (Result<String, Error>) -> Result<String, Error> = error { _ in CocoaError.error(.coderInvalidValue) }

valueSetter(result)
errorSetter(result)
/*:
 6. Is it possible to make key path setters work with `enum`s?
 */
// Yeah, but we need do a lot of boilercode.

/*:
 7. Redefine some of our setters in terms of `inout`. How does the type signature and composition change?
 */
func mprop<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
    -> (@escaping (Value) -> Value)
    -> (inout Root) -> Void {
        { update in
            { root in
                update(root[keyPath: kp])
            }
        }
}



func mlem<A>(_ element: A)
    -> (@escaping (Bool) -> Bool)
    -> (inout Set<A>) -> Void {
    { include in
        { set in
            let contains = set.contains(element)
            
            if include(contains) {
                set.insert(element)
            } else {
                set.remove(element)
            }
        }
    }
}

let mElementString = mlem("Test")
var mutableSet: Set<String> = ["Bar", "Baz", "Test"]

mElementString { !$0 } (&mutableSet)
