// Copyright © 2020 faber. All rights reserved.

import UIKit
import SDWebImage

// This class creates a collection of square images with the desired spacing.
// All the images shown in this collection are expected to be on screen.
class ImageCollectionView: UIView {
    private var imageViews: [UIImageView] = []
    private var imagesPerRow: Int = 1
    private var interImagePadding: CGFloat = 0
    private var verticalBorderPadding: CGFloat = 0
    private var horizontalBorderPadding: CGFloat = 0

    init() {
        super.init(frame: CGRect.zero)
    }

    /// Returns `true` if the update was successful. `false` if there were errors.
    @discardableResult
    public func update(withImageURLs imageURLs:[URL],
                       imagesPerRow: Int = 1,
                       interImagePadding: CGFloat = 0,
                       verticalBorderPadding: CGFloat = 0,
                       horizontalBorderPadding: CGFloat = 0,
                       imageViewGenerator: (()->UIImageView)? = nil) -> Bool {
        guard imagesPerRow >= 1 else {
            return false
        }

        for imageView in imageViews {
            imageView.removeFromSuperview()
        }
        
        self.imageViews = imageURLs.map { url in
            let generatorFunction: () -> UIImageView = imageViewGenerator ?? ImageCollectionView.fallbackImageViewGenerator
            let imageView = generatorFunction()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.sd_setImage(with: url,
                                  completed: nil)
            return imageView
        }
        self.imagesPerRow = imagesPerRow
        self.interImagePadding = interImagePadding
        self.verticalBorderPadding = verticalBorderPadding
        self.horizontalBorderPadding = horizontalBorderPadding

        for imageView in imageViews {
            addSubview(imageView)
        }
        return true
    }
    
    private static func fallbackImageViewGenerator() -> UIImageView {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width,
                      height: imageHeightForSize(size))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                            
        let width = self.bounds.width
        let imageDimension = imageHeightForSize(bounds.size)
        
        let totalHorizontalInterItemPadding = CGFloat(imagesPerRow - 1) * interImagePadding
        let horizontalImageTotalWidth = imageDimension * CGFloat(imagesPerRow)
        let horizontalPadding = (width - totalHorizontalInterItemPadding - horizontalImageTotalWidth) / 2
        
        for (index, imageView) in imageViews.enumerated() {
            imageView.frame.size = CGSize(width: imageDimension, height: imageDimension)
            let imageRow = CGFloat(index / imagesPerRow)
            let imageColumn = CGFloat(index % imagesPerRow)
            
            imageView.frame.origin = CGPoint(x: horizontalPadding + imageColumn * (imageDimension + interImagePadding),
                                             y: verticalBorderPadding + imageRow * (imageDimension + interImagePadding))
        }
    }
    
    private func imageHeightForSize(_ size: CGSize) -> CGFloat {
        guard imageViews.count > 0 else { return 0 }
        
        let numberOfRows: Int = Int(ceilf(Float(imageViews.count) / Float(imagesPerRow)))

        // Width determination
        let horizontalInterItemSpacing = CGFloat(imagesPerRow - 1) * interImagePadding
        let imageWidth: CGFloat = (size.width - horizontalInterItemSpacing - 2 * horizontalBorderPadding) / CGFloat(imagesPerRow)

        // Height determination
        let verticalInterItemSpacing = CGFloat(numberOfRows - 1) * interImagePadding
        let imageHeight: CGFloat = (size.height - verticalInterItemSpacing - 2 * verticalBorderPadding) / CGFloat(numberOfRows)
        
        return (imageWidth > imageHeight
            ? imageHeight
            : imageWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }
}
