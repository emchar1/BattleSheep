//
//  BattleSheepController.swift
//  BattleSheep
//
//  Created by Eddie Char on 7/9/21.
//

import UIKit

// MARK: - CollectionCell
class CollectionCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}


// MARK: - BattleSheepController
class BattleSheepController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var statusLabel: UILabel!
    var battleSheep = BattleSheep()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        battleSheep.delegate = self
        statusLabel.text = ""
    }
    
    @IBAction func newGamePressed(_ sender: UIButton) {
        battleSheep.newGame()
        statusLabel.text = ""
        collectionView.reloadData()
    }
}


// MARK: - UICollectionView
extension BattleSheepController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BattleSheep.boardSize * BattleSheep.boardSize
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionCell
        let row = indexPath.row / BattleSheep.boardSize
        let col = indexPath.row % BattleSheep.boardSize

        switch battleSheep.board[row][col] {
        case .blank, .sheep:
            cell.backgroundColor = .lightGray
        case .hit:
            cell.backgroundColor = .green
        case .miss:
            cell.backgroundColor = .red
        case .sink:
            cell.backgroundColor = .darkGray
        }

//        cell.label.text = ""
        
        //Uncomment to debug
        cell.label.text = "\(battleSheep.board[row][col].rawValue)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row / BattleSheep.boardSize
        let col = indexPath.row % BattleSheep.boardSize

        statusLabel.text = ""
        battleSheep.fire(at: (row: row, col: col))

        if battleSheep.isGameOver {
            statusLabel.text = "Game Over. Press 'New Game' to play again.\nAccuracy: \(Int(Double(battleSheep.totalHits)/Double(battleSheep.totalAttacks) * 100))%"
        }
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellBorderSize = 2
        let edgeInsets = 5
        let numColumns = BattleSheep.boardSize
        let cellSize = (collectionView.frame.width - CGFloat(2 * edgeInsets + (numColumns - 1) * cellBorderSize)) / CGFloat(numColumns)
        
        return CGSize(width: cellSize, height: cellSize)
    }
}


// MARK: - BattleSheetDelegate
extension BattleSheepController: BattleSheepDelegate {
    func didShearSheep(_ controller: BattleSheep) {
        statusLabel.text = "You blew up a sheep!"
    }
}
