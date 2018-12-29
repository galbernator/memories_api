import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    let memoryController = MemoryController()
    let memoriesRoute = router.grouped(["api", "memories"])
    memoriesRoute.get(use: memoryController.index)
    memoriesRoute.post(use: memoryController.create)
    memoriesRoute.get(Memory.parameter, use: memoryController.show)
    memoriesRoute.put(Memory.parameter, use: memoryController.update)

    let userController = UserController()
    let usersRoute = router.grouped("api", "users")
    usersRoute.post(User.self, at: "register", use: userController.create)
    usersRoute.post("login", use: userController.login)

    let personController = PersonController()
    let peopleRoute = router.grouped("api", "users", Int.parameter, "people")
    peopleRoute.get(use: personController.index)
}
