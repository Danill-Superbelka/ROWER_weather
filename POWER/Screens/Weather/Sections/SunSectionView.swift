import UIKit
import SnapKit

final class SunSectionView: UIView {

    private let card = SectionCardView()

    private let sunriseIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "sunrise.fill"))
        iv.tintColor = .Colors.tempBarWarm
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let sunriseTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let sunriseTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .Colors.secondaryText
        label.textAlignment = .center
        label.text = NSLocalizedString("weather.sunrise", comment: "")
        return label
    }()

    private let sunsetIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "sunset.fill"))
        iv.tintColor = .Colors.tempBarWarm
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let sunsetTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let sunsetTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .Colors.secondaryText
        label.textAlignment = .center
        label.text = NSLocalizedString("weather.sunset", comment: "")
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

    func configure(astro: Astro, localtime: String) {
        sunriseTimeLabel.text = astro.sunrise
        sunsetTimeLabel.text = astro.sunset
    }

    private func setupView() {
        card.setHeader(
            icon: "sun.horizon",
            title: NSLocalizedString("weather.sun", comment: "")
        )

        let sunriseStack = UIStackView(arrangedSubviews: [
            sunriseIcon, sunriseTimeLabel, sunriseTitleLabel
        ])
        sunriseStack.axis = .vertical
        sunriseStack.spacing = 4
        sunriseStack.alignment = .center

        let sunsetStack = UIStackView(arrangedSubviews: [
            sunsetIcon, sunsetTimeLabel, sunsetTitleLabel
        ])
        sunsetStack.axis = .vertical
        sunsetStack.spacing = 4
        sunsetStack.alignment = .center

        sunriseIcon.snp.makeConstraints { $0.size.equalTo(28) }
        sunsetIcon.snp.makeConstraints { $0.size.equalTo(28) }

        let row = UIStackView(arrangedSubviews: [sunriseStack, sunsetStack])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 16

        let wrapper = UIView()
        wrapper.addSubview(row)
        row.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }

        card.contentStack.addArrangedSubview(wrapper)

        addSubview(card)
        card.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
