import CoreData
import Foundation

protocol PersistenceStorageProtocol {
    func saveUsers(_ users: [UserDomainModel]) async
    func fetchUsers() async -> [UserDomainModel]
    func deleteUser(by id: String) async
}

final class CoreDataStorage: PersistenceStorageProtocol {
    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext { container.viewContext }

    init() {
        container = NSPersistentContainer(name: "RamdomUser")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data store: \(error)")
            }
        }
    }

    func saveUsers(_ users: [UserDomainModel]) async {
        await context.perform {
            for user in users {
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

    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data context: \(error)")
            }
        }
    }
}
