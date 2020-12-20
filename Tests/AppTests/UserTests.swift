@testable import App
import XCTVapor

final class UserTests: XCTestCase {
  let usersName = "Alice"
  let usersUsername = "alicea"
  let usersURI = "/api/users/"
  var app: Application!

  override func setUpWithError() throws {
    app = try Application.testable()
  }
  
  override func tearDownWithError() throws {
    app.shutdown()
  }
  
  func testUsersCanBeRetrievedFromAPI() throws {
    let user = try User.create(
      name: usersName,
      username: usersUsername,
      on: app.db)
    _ = try User.create(on: app.db)

    try app.test(.GET, usersURI, afterResponse: { response in
      XCTAssertEqual(response.status, .ok)
      let users = try response.content.decode([User].self)
      
      XCTAssertEqual(users.count, 2)
      XCTAssertEqual(users[0].name, usersName)
      XCTAssertEqual(users[0].username, usersUsername)
      XCTAssertEqual(users[0].id, user.id)
    })
  }
  
  func testUserCanBeSavedWithAPI() throws {
    // 1
    let user = User(name: usersName, username: usersUsername)
    
    // 2
    try app.test(.POST, usersURI, beforeRequest: { req in
      // 3
      try req.content.encode(user)
    }, afterResponse: { response in
      // 4
      let receivedUser = try response.content.decode(User.self)
      // 5
      XCTAssertEqual(receivedUser.name, usersName)
      XCTAssertEqual(receivedUser.username, usersUsername)
      XCTAssertNotNil(receivedUser.id)
      
      // 6
      try app.test(.GET, usersURI,
        afterResponse: { secondResponse in
          // 7
          let users =
            try secondResponse.content.decode([User].self)
          XCTAssertEqual(users.count, 1)
          XCTAssertEqual(users[0].name, usersName)
          XCTAssertEqual(users[0].username, usersUsername)
          XCTAssertEqual(users[0].id, receivedUser.id)
        })
    })
  }
  
  func testGettingASingleUserFromTheAPI() throws {
    // 1
    let user = try User.create(
      name: usersName,
      username: usersUsername,
      on: app.db)
    
    // 2
    try app.test(.GET, "\(usersURI)\(user.id!)",
      afterResponse: { response in
        let receivedUser = try response.content.decode(User.self)
        // 3
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertEqual(receivedUser.id, user.id)
      })
  }
}
