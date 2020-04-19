/*:
 # A Tale of Two Flat-Maps, Exercises

 1. Define `filtered` as a function from `[A?]` to `[A]`.
 */
func filtered<A>(_ array: [A?]) -> [A] {
    array.compactMap { $0 }
}

filtered([1, nil, 3])
/*:
 2. Define `partitioned` as a function from `[Either<A, B>]` to `(left: [A], right: [B])`. What does this function have in common with `filtered`?
 */
enum Either<A, B> {
    case left(A)
    case right(B)
}

func partitioned<A, B>(_ array: [Either<A, B>]) -> (left: [A], right: [B]) {
    var result = (left: [A](), right: [B]())

    for either in array {
        switch either {
        case .left(let a):
            result.left.append(a)
        case .right(let b):
            result.right.append(b)
        }
    }

    return result
}


partitioned([.left(1), .right("1")])

/*:
 3. Define `partitionMap` on `Optional`.
 */
extension Optional {
    func partitionMap<A, B>(_ p: (Wrapped) -> Either<A, B>) -> (left: A?, right: B?) {
        guard let wrapped = self else { return (nil, nil) }
        
        switch p(wrapped) {
        case .left(let a):
            return (a, nil)
        case .right(let b):
            return (nil, b)
        }
    }
}

let t: Int? = 2

t.partitionMap { (number) in
    number.isMultiple(of: 2) ? .left(number) : .right(number)
}


/*:
 4. Dictionary has `mapValues`, which takes a transform function from `(Value) -> B` to produce a new dictionary of type `[Key: B]`. Define `filterMapValues` on `Dictionary`.
 */
extension Dictionary {
    func filterMapValues<B>(_ tranform: (Value) -> B?) -> [Key: B] {
        var dict: [Key: B] = [:]
        
        for (key, value) in self {
            dict[key] = tranform(value)
        }
        
        return dict
    }
}

let dict = ["test": "r", "t": "5"]

dict.filterMapValues(Int.init)
 
/*:
 5. Define `partitionMapValues` on `Dictionary`.
 */


extension Dictionary {
    func partitionMapValues<A, B>( p: @escaping (Value) -> Either<A, B>) -> (left: [Key: A], right: [Key: B]) {
        var result = (left: [Key: A](), right: [Key: B]())
        
        for (key, value) in self {
            switch p(value) {
            case .left(let a):
                result.left[key] = a
            case .right(let b):
                result.right[key] = b
            }
        }
        
        return result
    }
}

let dict2 = ["test": 4, "t": 5]

dict2.partitionMapValues { (number) in
    number.isMultiple(of: 2) ? .left(number) : .right(number)
}


/*:
 6. Rewrite `filterMap` and `filter` in terms of `partitionMap`.
 */


extension Array {
    func filterMap<A>(_ f: (Element) -> A?) {
        
    }
    
    func filter<A>(_ f: (Element) -> Bool) {
        
    }
}


/*:
 7. Is it possible to define `partitionMap` on `Either`?
 */

// No
