import Apollo

/// The input object sent when passing in a color
struct ColorInputNoModifier: Codable, Equatable, Hashable {
  var red: Int
  var green: Int
  var blue: Int
  
  init(red: Int,
       green: Int,
       blue: Int) {
    self.red = red
    self.green = green
    self.blue = blue
  }
}
