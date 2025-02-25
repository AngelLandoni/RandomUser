import CoreData
import Foundation

private enum Constans {
    static let randomUserContainer = "RamdomUser"
}

protocol PersistenceStorageProtocol {
    func saveUsers(_ users: [UserDomainModel]) async
    func fetchUsers() async -> [UserDomainModel]
    func deleteUser(by id: String) async
    func banUser(by id: String) async
    func isUserBanned(by id: String) async -> Bool
}

final class CoreDataStorage: PersistenceStorageProtocol {
    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext { container.viewContext }
    
    init(container: NSPersistentContainer = NSPersistentContainer(name: Constans.randomUserContainer)) {
        self.container = container
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Failed to load Core Data store: \(error)")
            }
        }
    }
    
    func saveUsers(_ users: [UserDomainModel]) async {
        await context.perform {
            for user in users {
                let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", user.id)
                fetchRequest.fetchLimit = 1
                
                do {
                    let existingUsers = try self.context.fetch(fetchRequest)
                    if existingUsers.isEmpty {
                        // Create new entity if not found
                        let entity = UserEntity(context: self.context)
                        entity.id = user.id
                        entity.name = user.firstName
                        entity.surname = user.lastName
                        entity.email = user.email
                        entity.phone = user.phone
                        entity.picture = user.picture
                        entity.thumbnail = user.thumbnail
                        entity.gender = user.gender
                        entity.location = user.location
                        entity.registeredDate = user.registeredDate
                    }
                } catch {
                    print("Failed to check for duplicate user: \(error)")
                }
            }
            self.saveContext()
        }
    }
    
    func fetchUsers() async -> [UserDomainModel] {
        await context.perform {
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            do {
                let entities = try self.context.fetch(fetchRequest)
                return entities.map { $0.toDomain() }
            } catch {
                return []
            }
        }
    }
    
    func deleteUser(by id: String) async {
        await context.perform {
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                if let entity = try self.context.fetch(fetchRequest).first {
                    self.context.delete(entity)
                    self.saveContext()
                }
            } catch {
                print("Failed to delete user: \(error)")
            }
        }
    }
    
    func banUser(by id: String) async {
        await context.perform {
            do {
                let fetchRequest: NSFetchRequest<BannedUserEntity> = BannedUserEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", id)
                fetchRequest.fetchLimit = 1

                if try self.context.count(for: fetchRequest) == 0 {
                    let bannedUser = BannedUserEntity(context: self.context)
                    bannedUser.id = id
                    self.saveContext()
                }
            } catch {
                print("Failed to ban user: \(error)")
            }
        }
    }
    
    func isUserBanned(by userID: String) async -> Bool {
        await context.perform {
            let fetchRequest: NSFetchRequest<BannedUserEntity> = BannedUserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", userID)
            
            do {
                return try self.context.count(for: fetchRequest) > 0
            } catch {
                print("Failed to check if user is banned: \(error)")
                return false
            }
        }
    }
    
    private func fetchBannedUserIDs() async -> Set<String> {
        await context.perform {
            let fetchRequest: NSFetchRequest<BannedUserEntity> = BannedUserEntity.fetchRequest()
            do {
                let bannedUsers = try self.context.fetch(fetchRequest)
                return Set(bannedUsers.compactMap { $0.id })
            } catch {
                print("Failed to fetch banned users: \(error)")
                return []
            }
        }
    }
    
    private func saveContext() {
        context.perform {
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    print("Failed to save Core Data context: \(error)")
                }
            }
        }
    }
}
