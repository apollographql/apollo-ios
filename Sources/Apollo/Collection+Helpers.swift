import Foundation

// MARK: - Unzipping
// MARK: Arrays of tuples to tuples of arrays

public func unzip<Element1, Element2>(_ array: [(Element1, Element2)]) -> ([Element1], [Element2]) {
  var array1: [Element1] = []
  var array2: [Element2] = []

  for element in array {
    array1.append(element.0)
    array2.append(element.1)
  }

  return (array1, array2)
}

public func unzip<Element1, Element2, Element3>(_ array: [(Element1, Element2, Element3)]) -> ([Element1], [Element2], [Element3]) {
  var array1: [Element1] = []
  var array2: [Element2] = []
  var array3: [Element3] = []

  for element in array {
    array1.append(element.0)
    array2.append(element.1)
    array3.append(element.2)
  }

  return (array1, array2, array3)
}
