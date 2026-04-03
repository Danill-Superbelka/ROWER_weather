import Foundation
import Combine

final class CitySearchViewModel {

    // MARK: - Inputs

    let searchQuery = CurrentValueSubject<String, Never>("")

    // MARK: - Outputs

    @Published private(set) var results: [CitySearchResult] = []

    // MARK: - Dependencies

    private let weatherService = WeatherService(network: NetworkService.shared)
    private var cancellables = Set<AnyCancellable>()

    init() {
        searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }

        Task { @MainActor in
            do {
                let cities = try await weatherService.searchCities(query: query)
                results = cities
            } catch {
                // ignore search errors silently
            }
        }
    }
}
