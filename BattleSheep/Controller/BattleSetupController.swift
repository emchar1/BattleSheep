//
//  BattleSetupController.swift
//  BattleSheep
//
//  Created by Eddie Char on 7/28/21.
//

import UIKit

class BattleSetupController: UIViewController {
    
    @IBOutlet weak var collectionViewPlayer: UICollectionView!
    
    let collectionViewSheep: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .green
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SheepCellular")
        collectionView.isUserInteractionEnabled = true
//        collectionView.register(TitleCell.self, forCellWithReuseIdentifier: TitleCell.identifier)
//        collectionView.register(HeaderView.self,
//                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                                withReuseIdentifier: HeaderView.reuseIdentifier)
//        collectionView.register(FooterView.self,
//                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
//                                withReuseIdentifier: FooterView.reuseIdentifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionViewPlayer.delegate = self
        collectionViewPlayer.dataSource = self
        
        
        //this aint working
        view.addSubview(collectionViewSheep)
        
//        NSLayoutConstraint.activate([collectionViewSheep.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
//                                     collectionViewSheep.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//                                     view.trailingAnchor.constraint(equalTo: collectionViewSheep.trailingAnchor, constant: 20),
//                                     view.bottomAnchor.constraint(equalTo: collectionViewSheep.bottomAnchor, constant: 200)])
        
        NSLayoutConstraint.activate([collectionViewSheep.widthAnchor.constraint(equalToConstant: 250),
                                     collectionViewSheep.heightAnchor.constraint(equalToConstant: 5)])
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        collectionViewPlayer.addGestureRecognizer(panGestureRecognizer)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
