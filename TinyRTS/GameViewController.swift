//
//  GameViewController.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 12/08/2021.
//

import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController {
    
    // MARK: - GAMECENTER
    var gameModel = GameModel()
    var localPlayer: Player?
    var match: GKMatch?

    // MARK: - INIT
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        match?.delegate = self
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            self.setupPlayers()
            if self.gameModel.players.count == 2 {
                if let view = self.view as! SKView? {
                    // Load the SKScene from 'GameScene.sks'
                    if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                        self.match?.delegate = nil
                        scene.match = self.match
                        scene.gameModel = self.gameModel
                        scene.localPlayer = self.localPlayer
                        scene.size = view.bounds.size
                        scene.scaleMode = .resizeFill
                        // Present the scene
                        view.presentScene(scene)
                        timer.invalidate()
                        
                        view.ignoresSiblingOrder = true
                        
                        view.showsFPS = true
                        view.showsNodeCount = true
                    }
                }
            }
        }
    }
    
    private func setupPlayers() {
        
        /*
        var players = [Player(displayName: GKLocalPlayer.local.displayName),Player(displayName: "test")]
        players[0].index = .one
        players[0].race = .human
        gameModel.players.append(players[0])
        gameModel.players.append(players[1])
        localPlayer = players[0]
         */
        // REMOVE AND PUT BACK
        
        
        

        guard let player2Name = match?.players.first?.displayName else { return }
        let player1 = Player(displayName: GKLocalPlayer.local.displayName)
        let player2 = Player(displayName: player2Name)
        
        var players = [player1,player2]
        
        players.sort { (player1, player2) -> Bool in
            player1.displayName < player2.displayName
        }
        if players.first?.displayName == GKLocalPlayer.local.displayName {
            if gameModel.players.count == 0 {
                players[0].index = .one
                players[0].race = .orc
                gameModel.players.append(players[0])
                localPlayer = players[0]
                sendData()
            }
        } else {
            if gameModel.players.count == 1 {
                players[1].index = .two
                players[1].race = .human
                gameModel.players.append(players[1])
                localPlayer = players[1]
                sendData()
            }
        }
        
        
    }
    
    
    
    // MARK: - OTHERS

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: GKMatchDelegate {
    
    func sendData() {
            guard let match = match else { return }
            
            do {
                guard let data = gameModel.encode() else { return }
                try match.sendData(toAllPlayers: data, with: .reliable)
            } catch {
                print("Send data failed")
            }
        }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        guard let model = GameModel.decode(data: data) else { return }
        gameModel = model
    }
    
    func match(_ match: GKMatch, didReceive data: Data, forRecipient recipient: GKPlayer, fromRemotePlayer player: GKPlayer) {
        guard let model = GameModel.decode(data: data) else { return }
        gameModel = model
    }
}
