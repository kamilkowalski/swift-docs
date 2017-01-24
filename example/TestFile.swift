import SomeLibrary

class TestClass {
  let testConstant: String = "Test string"
  var testVariable: Int?
  var testGetter: Float {
    get {
      return 5.5
    }
  }

  var testArray: [Int] = [5, 6, 7]

  func testFunction(_ local: String, count cnt: Int) -> [Int] {
    for id in testArray {
      print(id)
    }

    return [5]
  }
}
