import UIKit
import SnapKit

final class HourlySectionView: UIView {

    private let card = SectionCardView()

    private let hourlyScroll: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        return sv
    }()

    private let hourlyStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
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

    func configure(
        currentTemp: Double,
        currentIconURL: URL?,
        todayHours: [HourWeather],
        tomorrowHours: [HourWeather],
        currentHour: Int
    ) {
        hourlyStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let nowItem = HourlyItemView()
        nowItem.configure(
            time: NSLocalizedString("weather.now", comment: ""),
            iconURL: currentIconURL,
            temperature: "\(Int(currentTemp))°"
        )
        hourlyStack.addArrangedSubview(nowItem)

        let now = Date().timeIntervalSince1970

        for hour in todayHours where Double(hour.timeEpoch) > now {
            let item = HourlyItemView()
            let time = hour.time.dateFromAPI?.displayTimeString ?? ""
            item.configure(
                time: time,
                iconURL: iconURL(from: hour.condition.icon),
                temperature: "\(Int(hour.tempC))°"
            )
            hourlyStack.addArrangedSubview(item)
        }

        for hour in tomorrowHours {
            let item = HourlyItemView()
            let time = hour.time.dateFromAPI?.displayTimeString ?? ""
            item.configure(
                time: time,
                iconURL: iconURL(from: hour.condition.icon),
                temperature: "\(Int(hour.tempC))°"
            )
            hourlyStack.addArrangedSubview(item)
        }
    }

    private func iconURL(from path: String) -> URL? {
        let urlString = path.hasPrefix("//") ? "https:\(path)" : path
        return URL(string: urlString)
    }

    private func setupView() {
        card.setHeader(
            icon: "clock",
            title: NSLocalizedString("weather.hourly.title", comment: "")
        )

        addSubview(card)
        card.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        card.contentStack.addArrangedSubview(hourlyScroll)

        hourlyScroll.addSubview(hourlyStack)
        hourlyStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
            make.height.equalToSuperview().offset(-24)
        }
    }
}
