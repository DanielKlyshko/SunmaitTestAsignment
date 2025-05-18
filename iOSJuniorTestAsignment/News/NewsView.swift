import SwiftUI

struct NewsView: View {
    
    @StateObject private var viewModel = NewsViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @State private var selectedIndex = 0
    let segments = ["All", "Favorites", "Blocked"]
    
    @State private var showAlert = false
    
    @State private var selectedURL: URL? = nil
    @State private var isShowingSafari = false
    
    var filteredArticles: [Article] {
        switch selectedIndex {
        case 0: return viewModel.articles
        case 1: return viewModel.favoriteArticles
        case 2: return viewModel.blockedArticles
        default: return []
        }
    }
    
    var body: some View {
        
        ZStack {
            Color.beigeCustom
                .edgesIgnoringSafeArea(.all)
            NavigationView {
                List {
                    Picker("Select", selection: $selectedIndex) {
                        ForEach(0..<segments.count, id: \.self) { index in
                            Text(segments[index])
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 8)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    
                    
                    if selectedIndex == 0 {
                        
                        if viewModel.error != nil {
                            VStack(spacing: 10) {
                                
                                Spacer()
                                    .frame(height: 150)
                                
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.blueCustom)
                                    .font(.system(size: 40))
                                
                                Text("No Results")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.blackCustom)
                                
                                Button {
                                    viewModel.retry()
                                } label: {
                                    ZStack {
                                        Text("Refresh")
                                            .font(.system(size: 17, weight: .semibold))
                                            .frame(maxWidth: .infinity)
                                        
                                        HStack {
                                            Spacer()
                                            Image(systemName: "arrow.clockwise")
                                                .font(.system(size: 20))
                                        }
                                        .padding(.trailing)
                                    }
                                    .frame(height: 44)
                                    .background(Color.blueCustom)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                                    .padding(.horizontal, 32)
                                }
                                
                            }
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            
                        } else {
                            
                            ForEach(viewModel.articlesWithNavigation) { item in
                                switch item {
                                case .article(let article):
                                    ArticleCardView(
                                        viewModel: viewModel,
                                        article: article
                                    )
                                    .onTapGesture {
                                        if let url = URL(string: article.webUrl) {
                                            selectedURL = url
                                        }
                                    }
                                    .onChange(of: selectedURL) { newValue in
                                        if newValue != nil {
                                            isShowingSafari = true
                                        }
                                    }
                                    .onAppear {
                                        viewModel.loadNextIfNeeded(currentItem: article)
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .padding(.vertical, -6)
                                    
                                case .navigation(let block, _):
                                    NavigationBlockView(block: block)
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                }
                            }
                            
                            
                            
                        }
                    } else if selectedIndex == 1 {
                        
                        if viewModel.favoriteArticles.isEmpty {
                            emptyStateView(
                                icon: "heart.circle.fill",
                                text: "No Favorite News"
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        } else {
                            ForEach(filteredArticles) { article in
                                ArticleCardView(
                                    viewModel: viewModel,
                                    article: article
                                )
                                .onTapGesture {
                                    if let url = URL(string: article.webUrl) {
                                        selectedURL = url
                                        isShowingSafari = true
                                    }
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .padding(.vertical, -6)
                            }
                        }
                        
                    } else {
                        
                        if viewModel.blockedArticles.isEmpty {
                            emptyStateView(
                                icon: "nosign",
                                text: "No Blocked News"
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            
                        } else {
                            ForEach(filteredArticles) { article in
                                ArticleCardView(
                                    viewModel: viewModel,
                                    article: article
                                )
                                .onTapGesture {
                                    if let url = URL(string: article.webUrl) {
                                        selectedURL = url
                                        isShowingSafari = true
                                    }
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .padding(.vertical, -6)
                            }
                        }
                        
                    }
                    
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .refreshable {
                    viewModel.refresh()
                }
                .navigationTitle(
                    Text("News")
                )
                .navigationBarTitleDisplayMode(.large)
                .background(Color.beigeCustom)
                
            }
            
            if viewModel.isRetrying {
                ZStack {
                    Color.black.opacity(0.5)
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                    
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            
            if showAlert {
                ZStack {
                    Color.black.opacity(0.5)
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
            }
            
        }
        .edgesIgnoringSafeArea(.all)
        .onReceive(networkMonitor.$isConnected) { isConnected in
            if !isConnected {
                showAlert = true
            }
        }
        .alert("No Internet Connection", isPresented: $showAlert) {
            Button("ОК", role: .cancel) {
                showAlert = false
            }
        }
        .sheet(isPresented: $isShowingSafari) {
            if let url = selectedURL {
                SafariView(url: url)
            }
        }
    }
    
    private func emptyStateView(icon: String, text: String) -> some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 180)
            Image(systemName: icon)
                .foregroundColor(.blueCustom)
                .font(.system(size: 40))
            Text(text)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.blackCustom)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
