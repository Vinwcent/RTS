//
//  StartViewController.swift
//  TinyRTS
//
//  Created by Vincent Van Wynendaele on 27/08/2021.
//

import UIKit
import GameKit

let screenHeight = UIScreen.main.bounds.height
let screenWidth = UIScreen.main.bounds.width

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupLayers()
        setupLogo()
        
        gameCenterHelper = GameCenterHelper()
        gameCenterHelper.delegate = self
        gameCenterHelper.authenticatePlayer()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - WORKSPACE
    
    private var gameCenterHelper: GameCenterHelper!
    
    
    func setupLogo() {
        let logo = UIImageView(image: UIImage(named: "logo"))
        logo.frame = CGRect(x: 1/10*screenWidth, y: screenHeight/20, width: 8/10*screenWidth, height: 8/10*screenWidth*108/286)
        self.view.insertSubview(logo, aboveSubview: playButton)
        UIView.animate(withDuration: 8, delay: 0, options: [.curveLinear,.repeat,.autoreverse], animations: {
            logo.frame = CGRect(x: 0, y: screenHeight/20, width: screenWidth, height: screenWidth*108/286)
        }, completion: nil)
    }
    
    func setupLayers() {
        
        let image1 = UIImageView(image: UIImage(named: "frontLayer"))
        image1.frame = CGRect(x: 0, y: 0, width: screenHeight*162/160, height: screenHeight)
        let image2 = UIImageView(image: UIImage(named: "frontLayer"))
        image2.frame = CGRect(x: image1.frame.width, y: 0, width: screenHeight*162/160, height: screenHeight)
        let firstLayer = UIView(frame: CGRect(x: 0, y: 0, width: 2*image1.frame.width, height: screenHeight))
        firstLayer.addSubview(image1)
        firstLayer.addSubview(image2)
        self.view.insertSubview(firstLayer, belowSubview: playButton)
        UIView.animate(withDuration: 12.0, delay: 0, options: [.repeat,.curveLinear], animations:  {
            firstLayer.frame.origin.x = -image1.frame.width
        }, completion: nil)
        
        let image3 = UIImageView(image: UIImage(named: "midLayer"))
        image3.frame = CGRect(x: 0, y: 0, width: screenHeight*224/160, height: screenHeight)
        let image4 = UIImageView(image: UIImage(named: "midLayer"))
        image4.frame = CGRect(x: image3.frame.width, y: 0, width: screenHeight*224/160, height: screenHeight)
        let secondLayer = UIView(frame: CGRect(x: 0, y: 0, width: 2*image3.frame.width, height: screenHeight))
        secondLayer.addSubview(image3)
        secondLayer.addSubview(image4)
        self.view.insertSubview(secondLayer, belowSubview: firstLayer)
        UIView.animate(withDuration: 14.0, delay: 0, options: [.repeat,.curveLinear], animations:  {
            secondLayer.frame.origin.x = -image3.frame.width
        }, completion: nil)
        
        let image5 = UIImageView(image: UIImage(named: "backLayer"))
        image5.frame = CGRect(x: 0, y: 0, width: screenHeight*128/160, height: screenHeight)
        let image6 = UIImageView(image: UIImage(named: "backLayer"))
        image6.frame = CGRect(x: image5.frame.width, y: 0, width: screenHeight*128/160, height: screenHeight)
        let thirdLayer = UIView(frame: CGRect(x: 0, y: 0, width: 2*image5.frame.width, height: screenHeight))
        thirdLayer.addSubview(image5)
        thirdLayer.addSubview(image6)
        self.view.insertSubview(thirdLayer, belowSubview: secondLayer)
        UIView.animate(withDuration: 16.0, delay: 0, options: [.repeat,.curveLinear], animations:  {
            thirdLayer.frame.origin.x = -image5.frame.width
        }, completion: nil)
        
    }
    
    
    // MARK: - OUTLETS
    
    
    @IBOutlet weak var playButton: UIButton!
    
    
    
    // MARK: - ACTIONS
    
    @IBAction func pressPlay(_ sender: Any) {
        // performSegue(withIdentifier: "showGame", sender: nil) // TO REMOVE -> presentMatchmaker
        gameCenterHelper.presentMatchmaker()
    }
    
    // MARK: - OVERRIDES
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? GameViewController,
              let match = sender as? GKMatch else {return}
        vc.match = match
    }
    
    
}

extension StartViewController: GameCenterHelperDelegate {
    func didChangeAuthStatus(isAuthenticated: Bool) {
        playButton.isEnabled = isAuthenticated
    }
    
    func presentGameCenterAuth(viewController: UIViewController?) {
        guard let vc = viewController else {return}
        self.present(vc, animated: true)
    }
    
    func presentMatchmaking(viewController: UIViewController?) {
        guard let vc = viewController else {return}
        self.present(vc, animated: true)
    }
    
    func presentGame(match: GKMatch) {
        performSegue(withIdentifier: "showGame", sender: match)
        
    }
}
