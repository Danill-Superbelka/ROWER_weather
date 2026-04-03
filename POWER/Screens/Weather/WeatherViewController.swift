import UIKit
import SnapKit

// MARK: - WeatherViewController

final class WeatherViewController: UIViewController {
    
    private let weatherView = WeatherView()
    
    override func loadView() {
        view = weatherView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Москва"
        setupNavigationBar()
    }
        
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // прозрачный фон
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // обычный заголовок
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // largeTitle
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white // кнопки, стрелка назад
    }
}
