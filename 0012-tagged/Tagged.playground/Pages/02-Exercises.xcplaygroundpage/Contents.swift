/*:
 # Tagged Exercises

 1. Conditionally conform Tagged to ExpressibleByStringLiteral in order to restore the ergonomics of initializing our User’s email property. Note that ExpressibleByStringLiteral requires a couple other prerequisite conformances.
 */
struct Tagged<Tag, RawValue> {
    let rawValue: RawValue
}

extension Tagged: Decodable where RawValue: Decodable {}

extension Tagged: Equatable where RawValue: Equatable {
    static func == (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension Tagged: ExpressibleByStringLiteral where RawValue: ExpressibleByStringLiteral {
    init(stringLiteral value: RawValue.StringLiteralType) {
        self.rawValue = RawValue(stringLiteral: value)
    }
}

extension Tagged: ExpressibleByExtendedGraphemeClusterLiteral where RawValue: ExpressibleByExtendedGraphemeClusterLiteral {
    init(extendedGraphemeClusterLiteral: RawValue.ExtendedGraphemeClusterLiteralType) {
        self.rawValue = RawValue(extendedGraphemeClusterLiteral: extendedGraphemeClusterLiteral)
    }
}

extension Tagged: ExpressibleByUnicodeScalarLiteral where RawValue: ExpressibleByUnicodeScalarLiteral {
    init(unicodeScalarLiteral: RawValue.UnicodeScalarLiteralType) {
        self.rawValue = RawValue(unicodeScalarLiteral: unicodeScalarLiteral)
    }
}

enum EmailTag {}
typealias Email = Tagged<EmailTag, String>

struct User {
    let name: String
    let email: Email
}

User(name: "test", email: "test")
/*:
 2. Conditionally conform Tagged to Comparable and sort users by their id in descending order.
 */
extension Tagged: Comparable where RawValue: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue <= rhs.rawValue
    }
    
    static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue >= rhs.rawValue
    }
    
    static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
}
/*:
 3. Let’s explore what happens when you have multiple fields in a struct that you want to strengthen at the type level. Add an age property to User that is tagged to wrap an Int value. Ensure that it doesn’t collide with User.Id. (Consider how we tagged Email.)
 */
extension Tagged: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
    init(integerLiteral value: RawValue.IntegerLiteralType) {
        self.init(rawValue: RawValue(integerLiteral: value))
    }
}


struct UserWithAge {
    enum AgeTag {}
    typealias Id = Tagged<User, Int>
    typealias Age = Tagged<(User, age: ()), Int>
    
    let id: Id
    let age: Age
}

let userAge = UserWithAge(id: 1, age: 3)
/*:
 4. Conditionally conform Tagged to Numeric and alias a tagged type to Int representing Cents. Explore the ergonomics of using mathematical operators and literals to manipulate these values.
 */
extension Tagged: AdditiveArithmetic where RawValue: AdditiveArithmetic {
    
    static var zero: Self { Tagged(rawValue: RawValue.zero) }

    static func + (lhs: Self, rhs: Self) -> Self {
        Tagged(rawValue: lhs.rawValue + rhs.rawValue)
    }
 
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        Tagged(rawValue: lhs.rawValue - rhs.rawValue)
    }
    
    static func -= (lhs: inout Self, rhs: Self) {
        lhs =  lhs - rhs
    }
}

extension Tagged: Numeric where RawValue: Numeric {
    
    var magnitude: RawValue.Magnitude { rawValue.magnitude }
    
    init?<T>(exactly source: T) where T : BinaryInteger {
        guard let rawValue = RawValue(exactly: source) else { return nil }
        self.rawValue = rawValue
    }
    
    static func * (lhs: Self, rhs: Self) -> Self {
        Tagged(rawValue: lhs.rawValue * rhs.rawValue)
    }
    
    static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
}

enum CentsTag {}

typealias Cents = Tagged<CentsTag, Int>

let one: Cents = 1

let result = one + 3

result.rawValue
/*:
 5. Create a tagged type, Light<A> = Tagged<A, Color>, where A can represent whether the light is on or off. Write turnOn and turnOff functions to toggle this state.
 */
struct Color {}

typealias Light<A> = Tagged<A, Color>

enum On {}
enum Off {}


func turnOn(light: Light<Off>) -> Light<On> {
    Light(rawValue: light.rawValue)
}

func turnOff(light: Light<On>) -> Light<Off> {
    Light(rawValue: light.rawValue)
}


var light = Light<On>(rawValue: Color())
turnOff(light: light)

/*:
 6. Write a function, changeColor, that changes a Light’s color when the light is on. This function should produce a compiler error when passed a Light that is off.
 */
func changeColor(light: Light<On>, newColor: Color) -> Light<On> {
    Light(rawValue: newColor)
}
/*:
 7. Create two tagged types with Double raw values to represent Celsius and Fahrenheit temperatures. Write functions celsiusToFahrenheit and fahrenheitToCelsius that convert between these units.
 */
enum CelsiusTag {}
enum FahrenheitTag {}

typealias Celsius = Tagged<CelsiusTag, Double>
typealias Fahrenheit = Tagged<FahrenheitTag, Double>

func celsiusToFahrenheit(_ value: Celsius) -> Fahrenheit {
    Fahrenheit(rawValue: value.rawValue) // TODO: Implement the logic
}

func fahrenheitToCelsius(_ value: Fahrenheit) -> Celsius {
    Celsius(rawValue: value.rawValue) // TODO: Implement the logic
}
/*:
 8. Create Unvalidated and Validated tagged types so that you can create a function that takes an Unvalidated<User> and returns an Optional<Validated<User>> given a valid user. A valid user may be one with a non-empty name and an email that contains an @.
 */
enum UnvalidatedTag {}
enum ValidatedTag {}

typealias Unvalidated<A> = Tagged<UnvalidatedTag, A>
typealias Validated<A> = Tagged<ValidatedTag, A>

func validate(user: Unvalidated<User>) -> Validated<User>? {
    let user = user.rawValue
    
    guard user.name.isEmpty == false else {
        return nil
    }
    
    guard user.email.rawValue.contains("@") == true else {
        return nil
    }
    
    return Validated(rawValue: user)
}

let userValid = Unvalidated(rawValue: User(name: "Test", email: "test@test.com"))
validate(user: userValid)

let userInvalidName = Unvalidated(rawValue: User(name: "", email: "@"))
validate(user: userInvalidName)

let userInvalidEmail = Unvalidated(rawValue: User(name: "Test", email: "test.com"))
validate(user: userInvalidEmail)
