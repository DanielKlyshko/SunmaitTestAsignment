import SwiftUI

struct ArticleCardView: View {
    
    @ObservedObject var viewModel: NewsViewModel
    let article: Article
    @State private var showUnblockAlert = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "newspaper.fill")
                    .foregroundColor(.blueCustom)
                    .frame(width: 94, height: 86)
                    .background(Color.beigeCustom)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.webTitle)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.blackCustom)
                        .lineLimit(3)
                    
                    Text("\(article.sectionName) ⋅ \(formattedDate(article.webPublicationDate))")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.grayCustom)
                    
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            
            Menu {
                if viewModel.blockedArticles.contains(article) {
                    Button(role: .destructive) {
                        showUnblockAlert = true
                    } label: {
                        Label("Unblock", systemImage: "lock.open")
                    }
                } else {
                    if viewModel.favoriteArticles.contains(article) {
                        Button {
                            viewModel.removeFromFavorites(article)
                        } label: {
                            Label("Remove from Favorites", systemImage: "heart.slash")
                        }
                    } else {
                        Button {
                            viewModel.addToFavorites(article)
                        } label: {
                            Label("Add to Favorites", systemImage: "heart")
                        }
                    }
                    
                    Button(role: .destructive) {
                        viewModel.blockArticle(article)
                    } label: {
                        Label("Block", systemImage: "nosign")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.grayCustom)
                    .padding()
            }
            .alert("Do you want to unblock?", isPresented: $showUnblockAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Unblock", role: .destructive) {
                    viewModel.unblockArticle(article)
                }
            } message: {
                Text("Confirm to unblock this news source")
            }
            
        }
    }
    
    private func formattedDate(_ isoDate: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d, yyyy"
            return outputFormatter.string(from: date)
        }
        return isoDate
    }
}
