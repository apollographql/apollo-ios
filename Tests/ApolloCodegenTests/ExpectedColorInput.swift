import Apollo

/// The input object sent when passing in a color
public struct ColorInput: Codable {
    var red: Int
    var green: Int
    var blue: Int
    
    public init(red: Int,
                green: Int,
                blue: Int) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}
