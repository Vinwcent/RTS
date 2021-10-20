//
//  GameCenterHelper.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 26/08/2021.
//

import Foundation
import GameKit

protocol GameCenterHelperDelegate: AnyObject {
    func didChangeAuthStatus(isAuthenticated: Bool)
    func presentGameCenterAuth(viewController: UIViewController?)
    func presentMatchmaking(viewController: UIViewController?)
    func presentGame(match: GKMatch)
}

final class GameCenterHelper: NSObject, GKLocalPlayerListener {
    weak var delegate: GameCenterHelperDelegate?
    
    private let minPlayers: Int = 2
    private let maxPlayers: Int = 2
    private let inviteMessage = "Jveuxvoirsiçamarchewsh"
    
    private var currentVC: GKMatchmakerViewController?
    
    var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { (gameCenterAuthViewController, error) in
            self.delegate?.didChangeAuthStatus(isAuthenticated: self.isAuthenticated)
            
            guard GKLocalPlayer.local.isAuthenticated else {
                self.delegate?.presentGameCenterAuth(viewController: gameCenterAuthViewController)
                return
            }

            GKLocalPlayer.local.register(self)
        }
    }
    
    func presentMatchmaker(withInvite invite: GKInvite? = nil) {
        guard GKLocalPlayer.local.isAuthenticated,
              let vc = createMatchmaker(withInvite: invite) else {
            return
        }
        
        currentVC = vc
        vc.matchmakerDelegate = self
        delegate?.presentMatchmaking(viewController: vc)
    }
    
    private func createMatchmaker(withInvite invite: GKInvite? = nil) -> GKMatchmakerViewController? {
        
        //If there is an invite, create the matchmaker vc with it
        if let invite = invite {
            return GKMatchmakerViewController(invite: invite)
        }
        
        return GKMatchmakerViewController(matchRequest: createRequest())
    }
    
    private func createRequest() -> GKMatchRequest {
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        request.inviteMessage = inviteMessage
        
        return request
    }
}


extension GameCenterHelper: GKMatchmakerViewControllerDelegate {
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true)
        delegate?.presentGame(match: match)
    }
    
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        currentVC?.dismiss(animated: true, completion: {
            self.presentMatchmaker(withInvite: invite)
        })
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        print("Matchmaker vc did fail with error: \(error.localizedDescription).")
    }
}
