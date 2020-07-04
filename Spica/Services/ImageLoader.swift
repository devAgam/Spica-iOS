//
//  ImageLoader.swift
//  Spica
//
//  Created by Adrian Baumgart on 30.06.20.
//

import Foundation
import UIKit

public class ImageLoader {
    static let `default` = ImageLoader()
    public func loadImageFromInternet(url: URL) -> UIImage {
        let tempImg: UIImage?
        let data = try? Data(contentsOf: url)
        tempImg = UIImage(data: data!)

        return tempImg!
    }
}
