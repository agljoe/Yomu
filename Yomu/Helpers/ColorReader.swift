//
//  ColorReader.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-07-15.
//

import SwiftUI

extension UIImage {
    /// Returns the average color of some image.
    ///
    /// # Source
    /// https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

/// Reads the color of an image and updates the binding value containing the read cover.
struct ColorReader: ViewModifier {
    /// A color value that is updated when an image's color has been read.
    @Binding var color: Color
    
    /// The data of the image whose color is being read.
    let imageData: Data
    
    /// Returns the specified content and reads its color.
    ///
    /// - Parameter content: any content.
    ///
    /// - Returns: a view containing the color of its content.
    func body(content: Content) -> some View {
        content
            .background(
                Color.clear
                    .onAppear {
                        color = Color(uiColor: UIImage(data: imageData)?.averageColor ?? .gray)
                    }
            )
    }
}

extension View {
    /// Reads the color of the specified image.
    ///
    /// - Parameters:
    ///   - color: a color value that can be updated.
    ///   - imageData: the data of an image whose color is being read.
    ///
    /// - Returns: a view containing the color of the image.
    func readColor(color: Binding<Color>, imageData: Data) -> some View {
        modifier(ColorReader(color: color, imageData: imageData))
    }
}

