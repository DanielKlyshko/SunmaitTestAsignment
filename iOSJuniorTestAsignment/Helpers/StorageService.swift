import SwiftUI

class StorageService {
    
    static let shared = StorageService()
    
    private let favoritesKey = "favoritesArticles"
    private let blockedKey = "blockedArticles"
    
    func saveFavorites(_ articles: [Article]) {
        if let encoded = try? JSONEncoder().encode(articles) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    func loadFavorites() -> [Article] {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let decoded = try? JSONDecoder().decode([Article].self, from: data) else { return [] }
        return decoded
    }
    
    func saveBlocked(_ articles: [Article]) {
        if let encoded = try? JSONEncoder().encode(articles) {
            UserDefaults.standard.set(encoded, forKey: blockedKey)
        }
    }
    
    func loadBlocked() -> [Article] {
        guard let data = UserDefaults.standard.data(forKey: blockedKey),
              let decoded = try? JSONDecoder().decode([Article].self, from: data) else { return [] }
        return decoded
    }
}
