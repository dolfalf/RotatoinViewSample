//
//  ViewController.swift
//  RotatoinViewSample
//
//  Created by jelee on 2023/04/24.
//

import UIKit

struct Banner {
    let image: UIImage
}


class ViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let cellIdentifier = "BannerCell"
    
    // NOTE: データから取得したソース
    private let banners = [Banner(image: UIImage(named: "00")!),
                           Banner(image: UIImage(named: "01")!),
                           Banner(image: UIImage(named: "02")!)]
    
    private var autoScrollTimer: Timer?     // 自動ローリングタイマー
    
    private lazy var currentPageIndex = 2   // 5つのrollingデータを生成するため、現在Bannerは固定する
    private lazy var centerIndex = Int(floor(Double(banners.count)) / 2.0)  // 真ん中のBannerのIndex
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = CustomFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast
        collectionView.clipsToBounds = false
        
        // 初期表示Position指定
        // 修正：アプリ起動時、指定されてるIndexではなく、最初のIndexから始まる現象修正。（23.5.8)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(row: Int(ceil(Double(self.rollingBanner(centerIndex: self.centerIndex).count)) / 2.0), section: 0),
                                        at: .centeredHorizontally, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ローリングタイマー開始
        startAutoScrollTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // ローリングタイマー終了
        stopAutoScrollTimer()
    }
    
    // MARK: - Private
    
    // ローリングデータを生成する（前後のBannerがはじ出して表示されるのを表現するため）
    private func rollingBanner(centerIndex: Int) -> [Banner] {
        let count = banners.count
        
        return [banners[((centerIndex + count) - 2) % count],
                banners[((centerIndex + count) - 1) % count],
                banners[centerIndex],
                banners[(centerIndex + 1) % count],
                banners[(centerIndex + 2) % count]]
        
    }
    
    private func startAutoScrollTimer() {
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 3.0,
                                               target: self,
                                               selector: #selector(scrollToNextPage),
                                               userInfo: nil,
                                               repeats: true)
    }

    private func stopAutoScrollTimer() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    // Timer callback method
    @objc private func scrollToNextPage() {
        let nextPageIndex = currentPageIndex + 1
        let nextIndexPath = IndexPath(item: nextPageIndex, section: 0)
        collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // ローリングデータは動的に順番が変わる
        return rollingBanner(centerIndex: centerIndex).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! BannerCollectionViewCell
        
        // ローリングデータは動的に順番が変わる
        let banner = rollingBanner(centerIndex: centerIndex)[indexPath.item] // bannersはあなたのデータソースです（例: [Banner]型）
        cell.configure(with: banner)
        
        return cell
    }

}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPageIndex()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentPageIndex()
    }
    
    private func updateCurrentPageIndex() {
        let centerX = collectionView.contentOffset.x + (collectionView.frame.width / 2)
        
        let indexPath = collectionView.indexPathForItem(at: CGPoint(x: centerX,
                                                                    y: collectionView.frame.height / 2))
        let nextPageIndex = indexPath?.row ?? 0
        
        // スワイプ方向を判定し真ん中の位置を計算
        if currentPageIndex > nextPageIndex {
            centerIndex = (centerIndex + banners.count - 1) % banners.count
        } else if currentPageIndex < nextPageIndex {
            centerIndex = (centerIndex + 1) % banners.count
        }
        
        // !!! 計算されたものにデータソースを再読み込み
        collectionView.reloadData()
        
        // Offset位置を固定する。無限ローリングのためこれは変わらない。データソースが変更されるから
        collectionView.scrollToItem(at: IndexPath(row: currentPageIndex, section: 0),
                                    at: .centeredHorizontally, animated: false)
    }
}
