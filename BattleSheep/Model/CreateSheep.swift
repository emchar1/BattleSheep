//
//  CreateSheep.swift
//  BattleSheep
//
//  Created by Eddie Char on 8/18/21.
//

import UIKit

struct CreateSheep {
    let edgeInsets: CGFloat = 5
    let size: CGFloat
    let color: UIColor
    let superView: UIView
    let collectionViewPlayer: UICollectionView
    let collectionView: UICollectionView
    let cellSize: CGFloat
    
    
    init(size: CGFloat, color: UIColor, superView: UIView, collectionViewPlayer: UICollectionView) {
        self.size = size
        self.color = color
        self.superView = superView
        self.collectionViewPlayer = collectionViewPlayer
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: edgeInsets, left: edgeInsets, bottom: edgeInsets, right: edgeInsets)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = color
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SheepCell")
        collectionView.isUserInteractionEnabled = true
        
        self.cellSize = (collectionViewPlayer.frame.width - CGFloat(2 * Int(edgeInsets) + (BattleSheep.boardSize - 1) * 2)) / CGFloat(BattleSheep.boardSize)
    }

    func addGesture(target: Any?, action: Selector?) -> UIPanGestureRecognizer {
        return UIPanGestureRecognizer(target: target, action: action)
    }
    
    func activateConstraints(at location: CGPoint) {
        NSLayoutConstraint.activate([collectionView.topAnchor.constraint(equalTo: superView.topAnchor, constant: location.y),
                                     collectionView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: location.x),
                                     collectionView.widthAnchor.constraint(equalToConstant: size * cellSize),
                                     collectionView.heightAnchor.constraint(equalToConstant: 0.8 * cellSize)])
    }
}
