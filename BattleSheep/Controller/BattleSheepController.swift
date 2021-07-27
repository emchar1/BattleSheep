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

class CC: UICollectionViewCell {
    @IBOutlet weak var label2: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}


// MARK: - BattleSheepController
class BattleSheepController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cv2: UICollectionView!
    @IBOutlet weak var statusLabel: UILabel!
    var player1 = BattleSheep()
    var player2 = BattleSheep()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        cv2.delegate = self
        cv2.dataSource = self
        cv2.isUserInteractionEnabled = false
        player1.delegate = self
        statusLabel.text = ""
    }
    
    @IBAction func newGamePressed(_ sender: UIButton) {
        player1.newGame()
        player2.newGame()
        statusLabel.text = ""
        collectionView.isUserInteractionEnabled = true
        collectionView.reloadData()
        cv2.reloadData()
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
        let row = indexPath.row / BattleSheep.boardSize
        let col = indexPath.row % BattleSheep.boardSize
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        var player: BattleSheep
        
        if cell is CollectionCell {
            player = player1
        }
        else {
            player = player2
        }
        
        switch player.board[row][col] {
        case .blank:
            cell.backgroundColor = .lightGray
        case .sheep:
            cell.backgroundColor = cell is CollectionCell ? .lightGray : .white
        case .hit:
            cell.backgroundColor = .red
        case .miss:
            cell.backgroundColor = .gray
        case .sink:
            cell.backgroundColor = .black
        }
        
        //Uncomment to debug
        if let cell = cell as? CollectionCell {
            cell.label.text = ""
//            cell.label.text = "\(player1.board[row][col].rawValue)"
        }
        if let cell = cell as? CC {
            cell.label2.text = ""
//            cell.label2.text = "\(player1.board[row][col].rawValue)"
        }

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !player1.isGameOver && !player2.isGameOver else {
            return
        }
        
        guard player1.fire(at: Coordinates(row: indexPath.row / BattleSheep.boardSize,
                                           col: indexPath.row % BattleSheep.boardSize)!) != nil else {
            statusLabel.text = "You've already attacked this area."
            return
        }

        statusLabel.text = ""
        player2.cpuMove2()
        
        self.collectionView.isUserInteractionEnabled = false
        statusLabel.text = "CPU attacking..."
        collectionView.reloadData()
        if player1.isGameOver {
            statusLabel.text = "YOU WIN!!!\nPress 'New Game' to play again.\nAccuracy: \(Int(Double(player1.totalHits)/Double(player1.totalAttacks) * 100))%"
            self.collectionView.isUserInteractionEnabled = false
            
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...0)) {
            self.collectionView.isUserInteractionEnabled = true
            self.statusLabel.text = ""
            self.cv2.reloadData()
            if self.player2.isGameOver {
                self.statusLabel.text = "YOU LOSE!\nPress 'New Game' to play again."
                self.collectionView.isUserInteractionEnabled = false
                
                return
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellBorderSize = 2
        let edgeInsets = 5
        let numColumns = BattleSheep.boardSize
        let cellSize = (collectionView.frame.width - CGFloat(2 * edgeInsets + (numColumns - 1) * cellBorderSize)) / CGFloat(numColumns)
        
        return CGSize(width: cellSize, height: cellSize * 0.8)
    }
}


// MARK: - BattleSheetDelegate
extension BattleSheepController: BattleSheepDelegate {
    func didShearSheep(_ controller: BattleSheep) {
        statusLabel.text = "You blew up a sheep!"
        print("You blew up a sheep!")
    }
}
