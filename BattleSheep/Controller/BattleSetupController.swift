//
//  BattleSetupController.swift
//  BattleSheep
//
//  Created by Eddie Char on 7/28/21.
//

import UIKit

class BattleSetupController: UIViewController {
    
    @IBOutlet weak var collectionViewPlayer: UICollectionView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionViewPlayer.delegate = self
        collectionViewPlayer.dataSource = self
        
        let s0 = CreateSheep(size: 2, color: .white, superView: view, collectionViewPlayer: collectionViewPlayer)
        let s1 = CreateSheep(size: 3, color: .white, superView: view, collectionViewPlayer: collectionViewPlayer)
        let s2 = CreateSheep(size: 3, color: .white, superView: view, collectionViewPlayer: collectionViewPlayer)
        let s3 = CreateSheep(size: 4, color: .white, superView: view, collectionViewPlayer: collectionViewPlayer)
        let s4 = CreateSheep(size: 5, color: .white, superView: view, collectionViewPlayer: collectionViewPlayer)

        view.addSubview(s0.collectionView)
        view.addSubview(s1.collectionView)
        view.addSubview(s2.collectionView)
        view.addSubview(s3.collectionView)
        view.addSubview(s4.collectionView)
        
        s0.activateConstraints(at: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2))
        s1.activateConstraints(at: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 + 30))
        s2.activateConstraints(at: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 + 60))
        s3.activateConstraints(at: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 + 90))
        s4.activateConstraints(at: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 + 120))

        s0.collectionView.addGestureRecognizer(s0.addGesture(target: self, action: #selector(didPan(_:))))
        s1.collectionView.addGestureRecognizer(s1.addGesture(target: self, action: #selector(didPan(_:))))
        s2.collectionView.addGestureRecognizer(s2.addGesture(target: self, action: #selector(didPan(_:))))
        s3.collectionView.addGestureRecognizer(s3.addGesture(target: self, action: #selector(didPan(_:))))
        s4.collectionView.addGestureRecognizer(s4.addGesture(target: self, action: #selector(didPan(_:))))
    }
    
    @objc func didPan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)

        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x,
                                  y: view.center.y + translation.y)
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        
        if recognizer.state == UIGestureRecognizer.State.ended {
            let velocity = recognizer.velocity(in: self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            print("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
            
            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide

            var finalPoint = CGPoint(x:recognizer.view!.center.x + (velocity.x * slideFactor),
                                     y:recognizer.view!.center.y + (velocity.y * slideFactor))

            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)

            UIView.animate(withDuration: Double(slideFactor * 2),
                           delay: 0,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: { recognizer.view!.center = finalPoint },
                           completion: nil)
        }
    }
}


extension BattleSetupController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BattleSheep.boardSize * BattleSheep.boardSize
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .lightGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellBorderSize = 2
        let edgeInsets = 5
        let numColumns = BattleSheep.boardSize
        let cellSize = (collectionView.frame.width - CGFloat(2 * edgeInsets + (numColumns - 1) * cellBorderSize)) / CGFloat(numColumns)
        
        return CGSize(width: cellSize, height: cellSize * 0.8)
    }
}


extension BattleSetupController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
