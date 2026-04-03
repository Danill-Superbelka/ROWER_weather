import UIKit
import SnapKit

final class DailySectionView: UIView {

    private let card = SectionCardView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(days: [ForecastDay], todayDateString: String) {
        card.contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let globalMin = days.map(\.day.mintempC).min() ?? 0
        let globalMax = days.map(\.day.maxtempC).max() ?? 0

        for (index, forecastDay) in days.enumerated() {
            let dayName: String
            if forecastDay.date == todayDateString {
                dayName = NSLocalizedString("weather.today", comment: "")
            } else {
                dayName = forecastDay.date.dateFromAPIDate?.shortDayName ?? forecastDay.date
            }

            let iconURL: URL?
            let iconPath = forecastDay.day.condition.icon
            iconURL = URL(string: iconPath.hasPrefix("//") ? "https:\(iconPath)" : iconPath)

            let row = DailyRowView()
            row.configure(
                dayName: dayName,
                iconURL: iconURL,
                rainChance: forecastDay.day.dailyChanceOfRain,
                minTemp: forecastDay.day.mintempC,
                maxTemp: forecastDay.day.maxtempC,
                globalMin: globalMin,
                globalMax: globalMax
            )
            card.contentStack.addArrangedSubview(row)

            if index < days.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .Colors.separator
                separator.snp.makeConstraints { $0.height.equalTo(0.5) }

                let wrapper = UIView()
                wrapper.addSubview(separator)
                separator.snp.makeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.leading.trailing.equalToSuperview().inset(16)
                }
                card.contentStack.addArrangedSubview(wrapper)
            }
        }
    }

    private func setupView() {
        card.setHeader(
            icon: "calendar",
            title: NSLocalizedString("weather.daily.title", comment: "")
        )

        addSubview(card)
        card.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
