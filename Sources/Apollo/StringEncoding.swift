//
//  File.swift
//  
//
//  Created by abdi maye on 16/12/2020.
//

import Foundation

#if os(Linux)
enum APITextEncoding : String
{
    case ascii = "us-ascii"
    case iso2022JP = "iso-2022-jp"
    case isoLatin1 = "iso-8859-1"
    case isoLatin2 = "iso-8859-2"
    case japaneseEUC = "euc-jp"
    case macOSRoman = "macintosh"
    case utf8 = "utf8"
    case utf16 = "utf16"
    case utf32 = "utf32"

    var encoding: String.Encoding? {
        switch self
        {
        case .ascii:
            return .ascii
        case .iso2022JP:
            return .iso2022JP
        case .isoLatin1:
           return .isoLatin1
        case .isoLatin2:
            return .isoLatin2
        case .japaneseEUC:
            return .japaneseEUC
        case .macOSRoman:
            return .macOSRoman
        case .utf8:
            return .utf8
        case .utf16:
            return .utf16
        case .utf32:
            return .utf32
        }
    }
}

struct StringEncoding: Encoding {
    static func rawValue(encodingName: String) -> String.Encoding? {
        let mappedEncoding = APITextEncoding(rawValue: encodingName)
        return mappedEncoding?.encoding
    }
}
#else
struct StringEncoding: Encoding {
    static func rawValue(encodingName: String) -> String.Encoding? {
        return String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName as CFString)))
    }
}
#endif

protocol Encoding {
    static func rawValue(encodingName: String) -> String.Encoding?
}
