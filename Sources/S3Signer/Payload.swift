import Vapor
import Crypto


/// Payload object
public enum Payload {
    /// Data payload
    case bytes(Data)
    
    /// No payload
    case none
    
    /// Unsigned payload
    case unsigned
}

extension Payload {
    
    var bytes: Data {
        switch self {
        case .bytes(let bytes):
            return bytes
        default:
            return Data("".utf8)
        }
    }
    
    func hashed() throws -> String {
        switch self {
        case .bytes(let bytes):
            return SHA256.hash(data: bytes).hexEncodedString()
        case .none:
            return SHA256.hash(data: Data()).hexEncodedString()
        case .unsigned:
            return "UNSIGNED-PAYLOAD"
        }
    }
    
    var isBytes: Bool {
        switch self {
        case .bytes(_), .none:
            return true
        default:
            return false
        }
    }
    
    func size() -> String {
        switch self {
        case .unsigned:
            return "UNSIGNED-PAYLOAD"
        default:
            return bytes.count.description
        }
    }
    
    var isUnsigned: Bool {
        switch self {
        case .unsigned:
            return true
        default:
            return false
        }
    }
    
}
