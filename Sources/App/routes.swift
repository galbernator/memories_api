import Vapor
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let tokenAuthGroup = router.grouped([tokenAuthMiddleware, guardAuthMiddleware])

    let memoryController = MemoryController()
    let memoriesRoute = tokenAuthGroup.grouped(["api", "memories"])
    memoriesRoute.get(use: memoryController.index)
    memoriesRoute.post(use: memoryController.create)
    memoriesRoute.get(Int.parameter, use: memoryController.show)
    memoriesRoute.put(Int.parameter, use: memoryController.update)

    let userController = UserController()
    let usersRoute = router.grouped("api", "users")
    usersRoute.post(User.self, at: "register", use: userController.create)
    usersRoute.post("login", use: userController.login)

    let personController = PersonController()
    let peopleRoute = tokenAuthGroup.grouped("api", "users", Int.parameter, "people")
    peopleRoute.get(use: personController.index)
}
