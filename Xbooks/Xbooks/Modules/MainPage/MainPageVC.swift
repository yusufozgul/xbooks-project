//
//  MainPageVC.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 6.11.2020.
//

import UIKit

private typealias DataSource = UICollectionViewDiffableDataSource<MainPageVCSections, MainPageCollectionModel>

enum MainPageVCSections {
    case nowReading
    case suggestedBooks
    case reports
}

protocol MainPageVCInterface: class {
    func configureCollectionView()
    func prepareView()
    func showError(errorDescription: String)
    func updateCollectionView(with snapShot: MainPageSnapshot)
}

class MainPageVC: UIViewController {
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    var presenter: MainPagePresenterInterface!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [self] sectionIndex, _ in
            if sectionIndex == 0 {
                return nowReadingLayout()
            }
            
            if sectionIndex == 1 {
                return bookCardsLayout()
            }
            
            if sectionIndex == 2 {
                return reportLayout()
            }
            return bookCardsLayout()
        }
        return layout
    }
    
    private func nowReadingLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem])
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        return layoutSection
    }
    
    private func bookCardsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(160))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem, layoutItem, layoutItem])
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        layoutSection.orthogonalScrollingBehavior = .groupPaging
        let layoutSectionHeader = sectionHeader()
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        return layoutSection
    }
    
    private func reportLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(250))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem])
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let layoutSectionHeader = sectionHeader()
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        return layoutSection
    }
    
    private func sectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: "UICollectionViewCell", alignment: .top)
        return layoutSectionHeader
    }
}

// MARK: - MainPageVCInterface
extension MainPageVC: MainPageVCInterface {
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.register(UINib.loadNib(name: NowReadingView.reuseIdentifier), forCellWithReuseIdentifier: NowReadingView.reuseIdentifier)
        collectionView.register(UINib.loadNib(name: BookInfoView.reuseIdentifier), forCellWithReuseIdentifier: BookInfoView.reuseIdentifier)
        collectionView.register(UINib.loadNib(name: SummaryReportView.reuseIdentifier), forCellWithReuseIdentifier: SummaryReportView.reuseIdentifier)
        collectionView.register(UINib.loadNib(name: RadarChart.reuseIdentifier), forCellWithReuseIdentifier: RadarChart.reuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forSupplementaryViewOfKind: "UICollectionViewCell", withReuseIdentifier: "UICollectionViewCell")
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, data) -> UICollectionViewCell? in
            switch data {
            case .nowReadingBook(let book):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NowReadingView.reuseIdentifier, for: indexPath) as? NowReadingView
                cell?.configure(title: ReadingManager.shared.userData.currentBook?.name ?? "",
                                dailyPoint: "\(ReadingManager.shared.userData.currentBook?.totalPoint ?? 0) Puan",
                                dailyDuration: "\(((ReadingManager.shared.userData.currentBook?.totalDuration ?? 0) / 60)) dakika")
                return cell
            case .suggestedBooks(let book):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookInfoView.reuseIdentifier, for: indexPath) as? BookInfoView
                cell?.setView(title: book.bookName, detail: book.explanation)
                cell?.bookImage.loadImage(from: book.bookImageURL)
                return cell
            case .summaryReports(let data):
                if indexPath.item == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SummaryReportView.reuseIdentifier, for: indexPath) as? SummaryReportView
                    cell?.setData(data: data)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RadarChart.reuseIdentifier, for: indexPath) as? RadarChart
                    cell?.setData(data: data)
                    return cell
                }
            }
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UICollectionViewCell", for: indexPath)
            cell.subviews.forEach({$0.removeFromSuperview()})
            let label = UILabel()
            switch indexPath.section {
            case 0:
                break
            case 1:
                label.text = "Öneriler"
            case 2:
                label.text = "Özet Raporunuz"
            default:
                label.text = ""
            }
            label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
            label.sizeToFit()
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(label)
            label.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 5).isActive = true
            return cell
        }
    }
    
    func prepareView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        title = "Okunuyor"
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "DATA_GETTED"), object: nil, queue: .main) { (_) in
            self.collectionView.reloadData()
        }
    }
    
    func showError(errorDescription: String) {
        let alert = UIAlertController(title: "ALERT_TITLE", message: errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ALERT_CANCEL_BUTTON_TITLE", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func updateCollectionView(with snapShot: MainPageSnapshot) {
        DispatchQueue.main.async { [weak self] in
            self?.dataSource.apply(snapShot, animatingDifferences: true)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension MainPageVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.tappedCell(at: indexPath)
    }
}
