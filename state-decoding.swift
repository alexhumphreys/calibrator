import Foundation

enum State : String {
    case pending
    case overdue
    case correct
    case incorrect
}

extension State: Decodable {
    init(rawValue: String) {
        // TODO call super?
        switch rawValue {
        case "pending": self = .pending
        case "overdue": self = .overdue
        case "correct": self = .correct
        case "incorrect": self = .incorrect
        default: self = .pending
        }
    }

    init(from decoder: Decoder) throws {
        enum MyStructKeys: String, CodingKey { // declaring our keys
            case state = "state"
        }

        let container = try decoder.container(keyedBy: MyStructKeys.self) // defining our (keyed) container
        let state: String = try container.decode(String.self, forKey: .state) // extracting the state
        //let twitter: URL = try container.decode(URL.self, forKey: .twitter) // extracting the data

        print(state)
        self.init(rawValue: state)
    }
}

struct Prediction {
    let content: String
    let probability: Int
    let state: State
}

extension Prediction: Decodable, Encodable {
    enum MyStructKeys: String, CodingKey { // declaring our keys
        case content = "content"
        case probability = "probability"
        case state = "state"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MyStructKeys.self)

        try container.encode(content, forKey: .content)
        try container.encode(probability, forKey: .probability)
        try container.encode(state.rawValue, forKey: .state)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MyStructKeys.self) // defining our (keyed) container
        let content: String = try container.decode(String.self, forKey: .content) // extracting the data
        let probability: Int = try container.decode(Int.self, forKey: .probability) // extracting the data
        let state: String = try container.decode(String.self, forKey: .state) // extracting the state
        let state_obj = State.init(rawValue: state)
        //let twitter: URL = try container.decode(URL.self, forKey: .twitter) // extracting the data

        self.init(content: content, probability: probability, state: state_obj) //, twitter: twitter) // initializing our struct
    }
}

let json = """
{
 "content": "x will win",
 "probability": 45,
 "state": "overdue"
}
""".data(using: .utf8)! // our native (JSON) data
let myStruct = try JSONDecoder().decode(Prediction.self, from: json) // decoding our data
print(myStruct.state) // decoded!

var encoder = JSONEncoder()
let encoded = try? encoder.encode(myStruct)

let string1 = String(data: encoded!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
print(string1)


