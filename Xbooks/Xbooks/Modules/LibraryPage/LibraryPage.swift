//
//  LibraryPage.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import UIKit

private typealias DataSource = UICollectionViewDiffableDataSource<LibraryPageVCSections, LibraryPageCollectionModel>


enum LibraryPageVCSections {
    case suggestedBooks
    case suggestedAuthor
}

protocol LibraryPageVCInterface: class {
    func configureCollectionView()
    func prepareView()
    func showError(errorDescription: String)
    func updateCollectionView(with snapShot: LibraryPageSnapshot)
}

class LibraryPageVC: UIViewController {
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    var presenter: MainPagePresenterInterface!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.load()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [self] sectionIndex, _ in
            if sectionIndex == 0 {
                return authorCardsLayout()
            }
            
            if sectionIndex == 1 {
                return bookCardsLayout()
            }
            return bookCardsLayout()
        }
        return layout
    }
    
    private func bookCardsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(160))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem, layoutItem, layoutItem])
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let layoutSectionHeader = sectionHeader()
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        return layoutSection
    }
    
    private func authorCardsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let layoutSectionHeader = sectionHeader()
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        layoutSection.orthogonalScrollingBehavior = .groupPaging
        return layoutSection
    }
    
    private func sectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: "UICollectionViewCell", alignment: .top)
        return layoutSectionHeader
    }
}

// MARK: - MainPageVCInterface
extension LibraryPageVC: LibraryPageVCInterface {
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.register(UINib.loadNib(name: GridCardView.reuseIdentifier), forCellWithReuseIdentifier: GridCardView.reuseIdentifier)
        collectionView.register(UINib.loadNib(name: BookInfoView.reuseIdentifier), forCellWithReuseIdentifier: BookInfoView.reuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forSupplementaryViewOfKind: "UICollectionViewCell", withReuseIdentifier: "UICollectionViewCell")
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, data) -> UICollectionViewCell? in
            switch data {
            case .suggestedAuthor(let author):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCardView.reuseIdentifier, for: indexPath) as? GridCardView
                cell?.setView(label: author.title)
                cell?.image.loadImage(from: author.imageURL)
                return cell
            case .suggestedBooks(let book):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookInfoView.reuseIdentifier, for: indexPath) as? BookInfoView
                cell?.setView(title: book.bookName, detail: book.explanation)
                cell?.bookImage.loadImage(from: book.bookImageURL)
                return cell
            }
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UICollectionViewCell", for: indexPath)
            cell.subviews.forEach({$0.removeFromSuperview()})
            let label = UILabel()
            switch indexPath.section {
            case 0:
                label.text = "Önerilen Yazarlar"
            case 1:
                label.text = "Önerilen Kitaplar"
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
        title = "Kitaplık"
    }
    
    func showError(errorDescription: String) {
        let alert = UIAlertController(title: "Uyarı", message: errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Kapat", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func updateCollectionView(with snapShot: LibraryPageSnapshot) {
        DispatchQueue.main.async { [weak self] in
            self?.dataSource.apply(snapShot, animatingDifferences: true)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension LibraryPageVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.tappedCell(at: indexPath)
    }
}
