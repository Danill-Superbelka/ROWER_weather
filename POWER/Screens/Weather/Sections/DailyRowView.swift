import UIKit
import SnapKit

final class DailyRowView: UIView {

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        return label
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    private let rainLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .Colors.tempBarCold
        label.textAlignment = .right
        return label
    }()

    private let minLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .Colors.secondaryText
        label.textAlignment = .right
        return label
    }()

    private let maxLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()

    private let barBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .Colors.tempBarBackground
        view.layer.cornerRadius = 2.5
        view.clipsToBounds = true
        return view
    }()

    private let barFill: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2.5
        view.clipsToBounds = true
        return view
    }()

    private var fillLeadingRatio: CGFloat = 0
    private var fillWidthRatio: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let barWidth = barBackground.bounds.width
        guard barWidth > 0 else { return }

        barFill.frame = CGRect(
            x: barWidth * fillLeadingRatio,
            y: 0,
            width: barWidth * fillWidthRatio,
            height: barBackground.bounds.height
        )

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = barFill.bounds
        gradientLayer.colors = [
            UIColor.Colors.tempBarCold.cgColor,
            UIColor.Colors.tempBarWarm.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        barFill.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        barFill.layer.insertSublayer(gradientLayer, at: 0)
    }

    func configure(
        dayName: String,
        iconURL: URL?,
        rainChance: Int,
        minTemp: Double,
        maxTemp: Double,
        globalMin: Double,
        globalMax: Double
    ) {
        dayLabel.text = dayName
        iconView.loadWeatherIcon(from: iconURL)
        minLabel.text = "\(Int(minTemp))°"
        maxLabel.text = "\(Int(maxTemp))°"

        if rainChance > 0 {
            rainLabel.text = "\(rainChance)%"
        } else {
            rainLabel.text = ""
        }

        let range = globalMax - globalMin
        if range > 0 {
            fillLeadingRatio = (minTemp - globalMin) / range
            fillWidthRatio = (maxTemp - minTemp) / range
        } else {
            fillLeadingRatio = 0
            fillWidthRatio = 1
        }

        setNeedsLayout()
    }

    private func setupView() {
        let rainIcon = UIStackView(arrangedSubviews: [rainLabel])
        rainIcon.alignment = .trailing

        dayLabel.snp.makeConstraints { make in
            make.width.equalTo(90)
        }

        iconView.snp.makeConstraints { make in
            make.size.equalTo(24)
        }

        rainLabel.snp.makeConstraints { make in
            make.width.equalTo(32)
        }

        minLabel.snp.makeConstraints { make in
            make.width.equalTo(32)
        }

        maxLabel.snp.makeConstraints { make in
            make.width.equalTo(32)
        }

        barBackground.addSubview(barFill)
        barBackground.snp.makeConstraints { make in
            make.height.equalTo(5)
        }

        let row = UIStackView(arrangedSubviews: [
            dayLabel, iconView, rainLabel, minLabel, barBackground, maxLabel
        ])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center

        addSubview(row)
        row.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
    }
}
