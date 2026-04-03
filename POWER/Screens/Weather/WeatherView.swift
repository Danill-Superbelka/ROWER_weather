//
//  WeatherView.swift
//  POWER
//
//  Created by Даниил  on 04.04.2026.
//


import UIKit
import SnapKit

// MARK: - WeatherView

final class WeatherView: UIView {
    
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupContent()
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupContent()
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }
    
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
    
    private func setupContent() {
        for i in 1...20 {
            let label = UILabel()
            label.text = "Элемент \(i)"
            label.font = .systemFont(ofSize: 18)
            label.backgroundColor = .systemGray5
            label.textAlignment = .center
            label.snp.makeConstraints { $0.height.equalTo(80) }
            stack.addArrangedSubview(label)
        }
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
