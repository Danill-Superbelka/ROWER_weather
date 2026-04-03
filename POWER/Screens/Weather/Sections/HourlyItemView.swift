import UIKit
import SnapKit

final class HourlyItemView: UIView {

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
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

    func configure(time: String, iconURL: URL?, temperature: String) {
        timeLabel.text = time
        iconView.loadWeatherIcon(from: iconURL)
        tempLabel.text = temperature
    }

    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [timeLabel, iconView, tempLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconView.snp.makeConstraints { make in
            make.size.equalTo(28)
        }

        snp.makeConstraints { make in
            make.width.equalTo(60)
        }
    }
}
