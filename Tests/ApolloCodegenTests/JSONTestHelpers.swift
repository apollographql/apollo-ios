import Foundation

enum ConvenienceEncodingError: Error {
    case couldntConvertDataToString
    case couldntConvertStringToData
}

public extension Encodable {
    
    func toJSONData(with encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }
    
    func toJSONString(with encoder: JSONEncoder = JSONEncoder()) throws -> String {
        let encoded = try self.toJSONData()
        guard let jsonString = String(bytes: encoded, encoding: .utf8) else {
            throw ConvenienceEncodingError.couldntConvertDataToString
        }
        
        return jsonString
    }
}

public extension Decodable {
    
    init(fromJSONString jsonString: String, with decoder: JSONDecoder = JSONDecoder()) throws {
        guard let data = jsonString.data(using: .utf8) else {
            throw ConvenienceEncodingError.couldntConvertStringToData
        }
        
        self = try decoder.decode(Self.self, from: data)
    }
    
    init(dictionary: [String: Any?], with decoder: JSONDecoder = JSONDecoder()) throws {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        self = try decoder.decode(Self.self, from: data)
    }
}
