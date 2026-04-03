import UIKit
import SnapKit

final class CurrentWeatherSectionView: UIView {

    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 72, weight: .ultraLight)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let highLowLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let feelsLikeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .Colors.secondaryText
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(current: CurrentWeather, day: Day) {
        temperatureLabel.text = "\(Int(current.tempC))°"
        conditionLabel.text = current.condition.text

        let high = "\(Int(day.maxtempC))°"
        let low = "\(Int(day.mintempC))°"
        highLowLabel.text = String(
            format: NSLocalizedString("weather.highLow", comment: ""),
            high, low
        )

        feelsLikeLabel.text = String(
            format: NSLocalizedString("weather.feelsLike", comment: ""),
            "\(Int(current.feelslikeC))°"
        )
    }

    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [
            temperatureLabel,
            conditionLabel,
            highLowLabel,
            feelsLikeLabel
        ])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
