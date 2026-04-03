//
//  WeatherView.swift
//  POWER
//
//  Created by Даниил  on 04.04.2026.
//


import UIKit
import SnapKit

// MARK: - WeatherViewState

enum WeatherViewState {
    case loading
    case error(String)
    case loaded
}

// MARK: - WeatherView

final class WeatherView: UIView {

    var onRetryTapped: (() -> Void)?

    private var gradientLayer: CAGradientLayer?

    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = true
        sv.contentInsetAdjustmentBehavior = .always
        return sv
    }()

    private let contentView = UIView()
    private let stack = UIStackView()

    // MARK: - Loading

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Error

    private let errorContainer = UIView()

    private let errorIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        iv.tintColor = .Colors.secondaryText
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .Colors.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("error.retry", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .Colors.cardBackground
        button.layer.cornerRadius = 12
        return button
    }()

    // MARK: - Sections

    private let currentWeatherSection = CurrentWeatherSectionView()
    private let hourlySection = HourlySectionView()
    private let dailySection = DailySectionView()
    private let detailsSection = DetailsSectionView()
    private let sunSection = SunSectionView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupSections()
        setupLoadingView()
        setupErrorView()
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupSections()
        setupLoadingView()
        setupErrorView()
        setupGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }

    // MARK: - Public

    func showState(_ state: WeatherViewState) {
        switch state {
        case .loading:
            scrollView.isHidden = true
            errorContainer.isHidden = true
            loadingIndicator.startAnimating()
        case .error(let message):
            loadingIndicator.stopAnimating()
            scrollView.isHidden = true
            errorContainer.isHidden = false
            errorLabel.text = message
        case .loaded:
            loadingIndicator.stopAnimating()
            errorContainer.isHidden = true
            scrollView.isHidden = false
        }
    }

    func configure(with forecast: ForecastResponse) {
        let today = forecast.forecast.forecastday.first

        currentWeatherSection.configure(
            current: forecast.current,
            day: today?.day ?? forecast.forecast.forecastday[0].day
        )

        let currentIconPath = forecast.current.condition.icon
        let currentIconURL = URL(string: currentIconPath.hasPrefix("//") ? "https:\(currentIconPath)" : currentIconPath)

        let todayHours = today?.hour ?? []
        let tomorrowHours = forecast.forecast.forecastday.count > 1
            ? forecast.forecast.forecastday[1].hour
            : []

        hourlySection.configure(
            currentTemp: forecast.current.tempC,
            currentIconURL: currentIconURL,
            todayHours: todayHours,
            tomorrowHours: tomorrowHours,
            currentHour: Date().currentHour
        )

        dailySection.configure(
            days: forecast.forecast.forecastday,
            todayDateString: Date().apiDateString
        )

        detailsSection.configure(
            current: forecast.current,
            today: today?.day ?? forecast.forecast.forecastday[0].day
        )

        if let astro = today?.astro {
            sunSection.configure(
                astro: astro,
                localtime: forecast.location.localtime
            )
        }
    }

    // MARK: - Setup (constraints untouched)

    private func setupView() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        contentView.addSubview(stack)
        stack.axis = .vertical
        stack.spacing = 16
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16))
        }
    }

    private func setupSections() {
        stack.addArrangedSubview(currentWeatherSection)
        stack.addArrangedSubview(hourlySection)
        stack.addArrangedSubview(dailySection)
        stack.addArrangedSubview(detailsSection)
        stack.addArrangedSubview(sunSection)
    }

    private func setupLoadingView() {
        addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupErrorView() {
        addSubview(errorContainer)
        errorContainer.isHidden = true

        errorContainer.addSubview(errorIcon)
        errorContainer.addSubview(errorLabel)
        errorContainer.addSubview(retryButton)

        errorContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }

        errorIcon.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(40)
        }

        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(errorIcon.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
        }

        retryButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }

        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    }

    @objc private func retryTapped() {
        onRetryTapped?()
    }

    private func setupGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.Colors.gradientTop.cgColor,
            UIColor.Colors.gradientBottom.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradient, at: 0)
        self.gradientLayer = gradient
    }
}
