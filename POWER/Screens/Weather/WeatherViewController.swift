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
            self?.loadWeather()
        }

        loadWeather()
    }

    private func loadWeather() {
        Task {
            weatherView.showState(.loading)

            let coordinate = await locationService.requestLocation()

            do {
                let forecast = try await weatherService.fetchForecast(
                    lat: coordinate.latitude,
                    lon: coordinate.longitude
                )
                title = forecast.location.name
                weatherView.configure(with: forecast)
                weatherView.showState(.loaded)
            } catch {
                weatherView.showState(
                    .error(NSLocalizedString("error.loadFailed", comment: ""))
                )
            }
        }
    }

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
    }
}
