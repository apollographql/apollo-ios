import Apollo

public enum Episode: String {
  case newhope = "NEWHOPE"
  case empire = "EMPIRE"
  case jedi = "JEDI"
}

extension Episode: JSONDecodable, JSONEncodable {}
