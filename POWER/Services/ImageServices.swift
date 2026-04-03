//
//  ImageServices.swift
//  POWER
//
//  Created by Даниил  on 04.04.2026.
//

import UIKit
import Kingfisher

extension UIImageView {
    func loadWeatherIcon(from url: URL?) {
        guard let url else {
            self.image = nil
            return
        }

        kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "cloud"),
            options: [
                .transition(.fade(0.2)),
                .processor(DownsamplingImageProcessor(size: bounds.size))
            ]
        )
    }
}
