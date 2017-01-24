import SomeLibrary

class TestClass {
  let testConstant: String = "Test string"
  var testVariable: Int?
  var testGetter: Float {
    get {
      return 5.5
    }
  }

  func testFunction(global local: String) -> [Int] {
    return [5]
  }
}
