import UIKit
import SnapKit

final class DetailsSectionView: UIView {

    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(current: CurrentWeather, today: Day) {
        mainStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let items: [(icon: String, title: String, value: String, subtitle: String?)] = [
            (
                "humidity",
                NSLocalizedString("weather.humidity", comment: ""),
                "\(current.humidity)%",
                nil
            ),
            (
                "wind",
                NSLocalizedString("weather.wind", comment: ""),
                "\(Int(current.windKph)) km/h",
                current.windDir
            ),
            (
                "gauge.with.dots.needle.bottom.50percent",
                NSLocalizedString("weather.pressure", comment: ""),
                "\(Int(current.pressureMb)) mb",
                nil
            ),
            (
                "eye",
                NSLocalizedString("weather.visibility", comment: ""),
                "\(Int(current.visKm)) km",
                nil
            ),
            (
                "sun.max",
                NSLocalizedString("weather.uvIndex", comment: ""),
                "\(Int(current.uv))",
                uvDescription(for: current.uv)
            ),
            (
                "cloud.rain",
                NSLocalizedString("weather.rainChance", comment: ""),
                "\(today.dailyChanceOfRain)%",
                nil
            )
        ]

        for rowStart in stride(from: 0, to: items.count, by: 2) {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 12
            rowStack.distribution = .fillEqually

            for i in rowStart..<min(rowStart + 2, items.count) {
                let item = items[i]
                let card = SectionCardView()
                card.setHeader(icon: item.icon, title: item.title)

                let valueView = WeatherValueView()
                valueView.configure(
                    title: "",
                    value: item.value,
                    subtitle: item.subtitle
                )
                card.contentStack.addArrangedSubview(valueView)
                rowStack.addArrangedSubview(card)
            }

            mainStack.addArrangedSubview(rowStack)
        }
    }

    private func uvDescription(for uv: Double) -> String {
        switch uv {
        case ..<3:
            return NSLocalizedString("weather.uv.low", comment: "")
        case 3..<6:
            return NSLocalizedString("weather.uv.moderate", comment: "")
        case 6..<8:
            return NSLocalizedString("weather.uv.high", comment: "")
        case 8..<11:
            return NSLocalizedString("weather.uv.veryHigh", comment: "")
        default:
            return NSLocalizedString("weather.uv.extreme", comment: "")
        }
    }

    private func setupView() {
        addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
