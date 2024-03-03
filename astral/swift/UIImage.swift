//
//  UIImage.swift
//  astral
//
//  Created by Joseph Haygood on 3/3/24.
//

import Foundation
import UIKit

extension UIImage {
    func invertedImage() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage else { return nil }
        let context = CIContext(options: nil)
        
        guard let outputCgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: outputCgImage)
    }
}
