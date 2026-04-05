import Foundation
import Combine

enum CitySearchState {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}

final class CitySearchViewModel {

    // MARK: - Inputs

    let searchQuery = CurrentValueSubject<String, Never>("")

    // MARK: - Outputs

    @Published private(set) var results: [CitySearchResult] = []
    @Published private(set) var searchState: CitySearchState = .idle

    // MARK: - Dependencies

    private let weatherService: WeatherServicing
    private var cancellables = Set<AnyCancellable>()

    init(weatherService: WeatherServicing) {
        self.weatherService = weatherService

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
            searchState = .idle
            return
        }

        searchState = .loading

        Task { @MainActor in
            do {
                let cities = try await weatherService.searchCities(query: query)
                results = cities
                searchState = cities.isEmpty ? .empty : .loaded
            } catch {
                results = []
                searchState = .error(NSLocalizedString("error.loadFailed", comment: ""))
            }
        }
    }
}
