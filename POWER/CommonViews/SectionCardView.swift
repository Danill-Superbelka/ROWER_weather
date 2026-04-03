import UIKit
import SnapKit

final class SectionCardView: UIView {

    let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()

    private let headerIcon: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .Colors.secondaryText
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .Colors.secondaryText
        return label
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.Colors.separator
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setHeader(icon: String, title: String) {
        headerIcon.image = UIImage(systemName: icon)
        headerLabel.text = title.uppercased()
        headerStack.isHidden = false
        separator.isHidden = false
    }

    private func setupView() {
        backgroundColor = .Colors.cardBackground
        layer.cornerRadius = 12
        clipsToBounds = true

        addSubview(headerStack)
        addSubview(separator)
        addSubview(contentStack)

        headerIcon.snp.makeConstraints { make in
            make.size.equalTo(14)
        }

        headerStack.addArrangedSubview(headerIcon)
        headerStack.addArrangedSubview(headerLabel)
        headerStack.isHidden = true
        separator.isHidden = true

        headerStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        separator.snp.makeConstraints { make in
            make.top.equalTo(headerStack.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }

        contentStack.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
