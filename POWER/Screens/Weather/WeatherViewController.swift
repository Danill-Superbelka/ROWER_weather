import UIKit
import SnapKit
internal import _LocationEssentials

// MARK: - WeatherViewController

final class WeatherViewController: UIViewController {

    private let weatherView = WeatherView()
    private let locationService = LocationService()
    private let weatherService = WeatherService(network: NetworkService.shared)

    override func loadView() {
        view = weatherView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "—"
        setupNavigationBar()

        weatherView.onRetryTapped = { [weak self] in
            self?.loadWeatherByLocation()
        }

        loadWeatherByLocation()
    }

    // MARK: - Data Loading

    private func loadWeatherByLocation() {
        Task {
            weatherView.showState(.loading)

            let coordinate = await locationService.requestLocation()
            await fetchWeather(lat: coordinate.latitude, lon: coordinate.longitude)
        }
    }

    private func loadWeather(for city: CitySearchResult) {
        Task {
            weatherView.showState(.loading)
            await fetchWeather(lat: city.lat, lon: city.lon)
        }
    }

    private func fetchWeather(lat: Double, lon: Double) async {
        do {
            let forecast = try await weatherService.fetchForecast(lat: lat, lon: lon)
            title = forecast.location.name
            weatherView.configure(with: forecast)
            weatherView.showState(.loaded)
        } catch {
            weatherView.showState(
                .error(NSLocalizedString("error.loadFailed", comment: ""))
            )
        }
    }

    // MARK: - Actions

    @objc private func locationTapped() {
        loadWeatherByLocation()
    }

    @objc private func searchTapped() {
        let searchVC = CitySearchViewController()
        searchVC.delegate = self
        let nav = UINavigationController(rootViewController: searchVC)
        present(nav, animated: true)
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "location.fill"),
            style: .plain,
            target: self,
            action: #selector(locationTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(searchTapped)
        )
    }
}

// MARK: - CitySearchDelegate

extension WeatherViewController: CitySearchDelegate {
    func didSelectCity(_ city: CitySearchResult) {
        loadWeather(for: city)
    }
}
