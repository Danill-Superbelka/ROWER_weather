import UIKit
import SnapKit

protocol CitySearchDelegate: AnyObject {
    func didSelectCity(_ city: CitySearchResult)
}

final class CitySearchViewController: UIViewController {

    weak var delegate: CitySearchDelegate?

    private let weatherService = WeatherService(network: NetworkService.shared)
    private var results: [CitySearchResult] = []
    private var searchTask: Task<Void, Never>?

    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = NSLocalizedString("search.placeholder", comment: "")
        bar.searchBarStyle = .minimal
        bar.barTintColor = .clear
        bar.searchTextField.textColor = .white
        bar.searchTextField.leftView?.tintColor = .Colors.secondaryText
        bar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("search.placeholder", comment: ""),
            attributes: [.foregroundColor: UIColor.Colors.secondaryText]
        )
        bar.searchTextField.backgroundColor = .Colors.cardBackground
        return bar
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorColor = .Colors.separator
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "CityCell")
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("search.title", comment: "")
        setupUI()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func setupUI() {
        view.backgroundColor = .Colors.gradientTop

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white

        view.addSubview(searchBar)
        view.addSubview(tableView)

        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(8)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func searchCities(query: String) {
        searchTask?.cancel()

        guard !query.isEmpty else {
            results = []
            tableView.reloadData()
            return
        }

        searchTask = Task {
            do {
                let cities = try await weatherService.searchCities(query: query)
                guard !Task.isCancelled else { return }
                results = cities
                tableView.reloadData()
            } catch {
                // ignore search errors
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension CitySearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCities(query: searchText)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension CitySearchViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        let city = results[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = city.name
        config.secondaryText = "\(city.region), \(city.country)"
        config.textProperties.color = .white
        config.secondaryTextProperties.color = .Colors.secondaryText
        cell.contentConfiguration = config
        cell.backgroundColor = .clear
        cell.selectionStyle = .default

        let selectedBg = UIView()
        selectedBg.backgroundColor = .Colors.cardBackground
        cell.selectedBackgroundView = selectedBg

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let city = results[indexPath.row]
        delegate?.didSelectCity(city)
        dismiss(animated: true)
    }
}
