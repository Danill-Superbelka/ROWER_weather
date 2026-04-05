import UIKit
import SnapKit
import Combine

// MARK: - WeatherViewController

final class WeatherViewController: UIViewController {

    private let weatherView = WeatherView()
    private let viewModel: WeatherViewModel
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.viewModel = WeatherViewModel(
            locationService: LocationService(),
            weatherService: WeatherService(network: NetworkService.shared)
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = weatherView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        setupNavigationBar()
        bindViewModel()

        weatherView.onRetryTapped = { [weak self] in
            self?.viewModel.loadByLocation()
        }

        viewModel.loadByLocation()
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.weatherView.showState(state)
            }
            .store(in: &cancellables)

        viewModel.$cityName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.title = name
            }
            .store(in: &cancellables)

        viewModel.$forecast
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] forecast in
                self?.weatherView.configure(with: forecast)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func locationTapped() {
        viewModel.loadByLocation()
    }

    @objc private func searchTapped() {
        let searchVM = CitySearchViewModel(
            weatherService: WeatherService(network: NetworkService.shared)
        )
        let searchVC = CitySearchViewController(viewModel: searchVM)
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
        viewModel.loadByCity(city)
    }
}
