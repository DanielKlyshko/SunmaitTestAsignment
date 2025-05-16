import Foundation
import Combine

class GuardianAPIService {

    private let baseURL = URL(string: "https://us-central1-server-side-functions.cloudfunctions.net")!
    
    func fetchNews(page: Int) -> AnyPublisher<[Article], Error> {

        let url = baseURL.appendingPathComponent("/guardian")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)")
        ]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("daniel-klyshko", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in

                guard let httpResponse = output.response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                
                print("Status code:", httpResponse.statusCode)
                print("Raw response:", String(data: output.data, encoding: .utf8) ?? "nil")
                
                return output.data
            }
            .decode(type: GuardianResponse.self, decoder: JSONDecoder())
            .map { $0.response.results }
            .eraseToAnyPublisher()

    }
    
    func fetchNavigationBlocks() -> AnyPublisher<[NavigationBlock], Error> {
        
            let url = baseURL.appendingPathComponent("/navigation")
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("daniel-klyshko", forHTTPHeaderField: "Authorization")
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { output in
                    guard let response = output.response as? HTTPURLResponse,
                          200..<300 ~= response.statusCode else {
                        throw URLError(.badServerResponse)
                    }
                    
                    print("Navigation status:", response.statusCode)
                    print("Navigation raw:", String(data: output.data, encoding: .utf8) ?? "nil")
                    
                    return output.data
                }
                .decode(type: NavigationResponse.self, decoder: JSONDecoder())
                .map { $0.results }
                .eraseToAnyPublisher()
        }
}
