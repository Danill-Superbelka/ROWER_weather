import UIKit
import SnapKit

final class WeatherValueView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .Colors.secondaryText
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.textColor = .white
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .Colors.secondaryText
        label.numberOfLines = 0
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

    func configure(title: String, value: String, subtitle: String? = nil) {
        titleLabel.text = title.uppercased()
        valueLabel.text = value
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
    }

    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
}
