import SwiftUI
import Combine

class NewsViewModel: ObservableObject {
    
    @Published var navigationBlocks: [NavigationBlock] = []
    
    @Published var articles: [Article] = []
    @Published var error: String? = nil
    @Published var isRetrying = false
    
    private var currentPage = 1
    private var isLoading = false
    
    private let service = GuardianAPIService()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var favoriteArticles: [Article] = []
    @Published var blockedArticles: [Article] = []
    
    private let storage = StorageService.shared
    
    var articlesWithNavigation: [NewsItem] {
        var result: [NewsItem] = []
        
        let filtered = articles.filter { !blockedArticles.contains($0) }
        
        for (index, article) in filtered.enumerated() {
            result.append(.article(article))
            
            if (index + 1) % 2 == 0 && !navigationBlocks.isEmpty {
                let navIndex = (index / 2) % navigationBlocks.count
                let navBlock = navigationBlocks[navIndex]
                result.append(.navigation(navBlock, index / 2))
            }
        }
        
        return result
    }


    
    enum NewsItem: Identifiable {
        case article(Article)
        case navigation(NavigationBlock, Int) // добавляем индекс вставки

        var id: String {
            switch self {
            case .article(let article): return "article-\(article.id)"
            case .navigation(let block, let index): return "nav-\(block.id)-\(index)"
            }
        }
    }

    
    init() {
        loadNavigationBlocks()
        loadSavedData()
        loadPage()
    }
    
    func loadNavigationBlocks() {
        service.fetchNavigationBlocks()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Navigation error:", error.localizedDescription)
                }
            }, receiveValue: { [weak self] blocks in
                self?.navigationBlocks = blocks
            })
            .store(in: &cancellables)
    }
    
    
    private func loadSavedData() {
        favoriteArticles = storage.loadFavorites()
        blockedArticles = storage.loadBlocked()
    }
    
    func addToFavorites(_ article: Article) {
        if !favoriteArticles.contains(article) {
            favoriteArticles.append(article)
            storage.saveFavorites(favoriteArticles)
        }
    }
    
    func removeFromFavorites(_ article: Article) {
        favoriteArticles.removeAll { $0.id == article.id }
        storage.saveFavorites(favoriteArticles)
    }
    
    func blockArticle(_ article: Article) {
        if !blockedArticles.contains(article) {
            blockedArticles.append(article)
            storage.saveBlocked(blockedArticles)
            
            articles.removeAll { $0.id == article.id }
        }
    }
    
    func unblockArticle(_ article: Article) {
        blockedArticles.removeAll { $0.id == article.id }
        storage.saveBlocked(blockedArticles)
        
        if !articles.contains(article) {
            articles.insert(article, at: 0)
        }
        
        articles = articles.filter { !blockedArticles.contains($0) }
    }
    
    func fetchFilteredNews(page: Int) -> AnyPublisher<[Article], Error> {
        service.fetchNews(page: page)
            .map { [weak self] newArticles in
                guard let self = self else { return [] }
                return newArticles.filter { article in
                    !self.blockedArticles.contains(article)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func loadPage() {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        
        fetchFilteredNews(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                self?.isRetrying = false
                if case let .failure(error) = completion {
                    self?.error = error.localizedDescription
                }
            }, receiveValue: { [weak self] newArticles in
                guard let self = self else { return }
                
                if self.currentPage == 1 {
                    self.articles = newArticles
                } else {
                    self.articles.append(contentsOf: newArticles)
                }
                self.currentPage += 1
            })
            .store(in: &cancellables)
    }
    
    func refresh() {
        currentPage = 1
        articles.removeAll()
        loadPage()
    }
    
    func retry() {
        isRetrying = true
        currentPage = 1
        articles.removeAll()
        loadPage()
    }
    
    
    func loadNextIfNeeded(currentItem item: Article) {
        if articles.last == item {
            loadPage()
        }
    }
}
