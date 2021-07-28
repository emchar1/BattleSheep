//
//  BattleSheepController.swift
//  BattleSheep
//
//  Created by Eddie Char on 7/9/21.
//

import UIKit

// MARK: - CollectionCell
class CollectionCellPlayer: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}

class CollectionCellCPU: UICollectionViewCell {
    @IBOutlet weak var label2: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}


// MARK: - BattleSheepController
class BattleSheepController: UIViewController {
    @IBOutlet weak var collectionViewPlayer: UICollectionView!
    @IBOutlet weak var collectionViewCPU: UICollectionView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var winsLossesLabel: UILabel!
    var player1 = BattleSheep()
    var player2 = BattleSheep()
    var winStreak = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionViewPlayer.delegate = self
        collectionViewPlayer.dataSource = self
        collectionViewCPU.delegate = self
        collectionViewCPU.dataSource = self
        collectionViewCPU.isUserInteractionEnabled = false
        player1.delegate = self
        statusLabel.text = ""
    }
    
    @IBAction func newGamePressed(_ sender: UIButton) {
        player1.newGame()
        player2.newGame()
        statusLabel.text = ""
        collectionViewPlayer.isUserInteractionEnabled = true
        collectionViewPlayer.reloadData()
        collectionViewCPU.reloadData()
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
        
        if cell is CollectionCellPlayer {
            player = player1
        }
        else {
            player = player2
        }
        
        switch player.board[row][col] {
        case .blank:
            cell.backgroundColor = .lightGray
        case .sheep:
            cell.backgroundColor = (cell is CollectionCellPlayer && !player2.didWin) ? .lightGray : .white
        case .hit:
            cell.backgroundColor = .red
        case .miss:
            cell.backgroundColor = .gray
        case .sink:
            cell.backgroundColor = .black
        }
        
        //Uncomment to debug
        if let cell = cell as? CollectionCellPlayer {
            cell.label.text = ""
//            cell.label.text = "\(player1.board[row][col].rawValue)"
        }
        if let cell = cell as? CollectionCellCPU {
            cell.label2.text = ""
//            cell.label2.text = "\(player1.board[row][col].rawValue)"
        }

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !player1.didWin && !player2.didWin else {
            return
        }
        
        guard player1.fire(at: Coordinates(row: indexPath.row / BattleSheep.boardSize,
                                           col: indexPath.row % BattleSheep.boardSize)!) != nil else {
            statusLabel.text = "You've already attacked this area."
            return
        }

        statusLabel.text = ""
        player2.cpuMove2()
        
        self.collectionViewPlayer.isUserInteractionEnabled = false
        statusLabel.text = "CPU attacking..."
        collectionView.reloadData()
        if player1.didWin {
            player1.winsCount += 1
            winsLossesLabel.text = "Wins: \(player1.winsCount), Losses: \(player2.winsCount), Streak: \(winStreak)"
            winStreak += 1
            statusLabel.text = "YOU WIN!!!\nPress 'New Game' to play again.\nAccuracy: \(Int(Double(player1.totalHits)/Double(player1.totalAttacks) * 100))%"
            self.collectionViewPlayer.isUserInteractionEnabled = false
            
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...0)) { [self] in
            collectionViewPlayer.isUserInteractionEnabled = true
            statusLabel.text = ""
            collectionViewCPU.reloadData()
            
            if player2.didWin {
                player2.winsCount += 1
                winStreak = 0
                winsLossesLabel.text = "Wins: \(player1.winsCount), Losses: \(player2.winsCount), Streak: \(winStreak)"
                statusLabel.text = "YOU LOSE!\nPress 'New Game' to play again."
                collectionViewPlayer.isUserInteractionEnabled = false
                
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
