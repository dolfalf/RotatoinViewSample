//
//  BannerCollectionViewCell.swift
//  RotatoinViewSample
//
//  Created by jelee on 2023/04/24.
//

import UIKit

class BannerCollectionViewCell: UICollectionViewCell {
    
    // StoryboardからUIImageViewを接続
    @IBOutlet private weak var imageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // セルのデザインを調整（例：角丸）
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }
    
    // バナー情報でセルを設定するメソッド
    func configure(with banner: Banner) {
        imageView.image = banner.image
    }
}

