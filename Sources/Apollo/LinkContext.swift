public struct LinkContext {
  private var data = [AnyHashable: Any]()
  
  public subscript(_ key: AnyHashable) -> Any? {
    get {
      return data[key]
    }
    set {
      data[key] = newValue
    }
  }
  
  public subscript<T>(_ key: AnyHashable, default defaultValue: T) -> T {
    get {
      return data[key, default: defaultValue] as! T
    }
    set {
      data[key] = newValue
    }
  }
  
  public var signal = CancelController().signal
}
