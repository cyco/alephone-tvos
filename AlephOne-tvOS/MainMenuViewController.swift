//
//  MainMenuViewController.swift
//  AlephOne-tvOS
//
//  Created by Christoph Leimbrock on 06/07/16.
//  Copyright © 2016 chris. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
	@IBOutlet var newGameButton: UIButton!
	@IBOutlet var loadGameButton: UIButton!
	@IBOutlet var settingsButton: UIButton!
	@IBOutlet var aboutButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(animated: Bool) {
		self.view.window?.rootViewController!.addChildViewController(self)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBAction func newGame(sender:AnyObject?) {
		let gameController = GameViewController.sharedInstance()
		if let rootViewController = self.view.window?.rootViewController {
			rootViewController.addChildViewController(gameController)
			rootViewController.transitionFromViewController(self, toViewController: gameController,
			                                                duration: 2.0, options: [],
			                                                animations: nil, completion: nil)
			self.removeFromParentViewController()
			self.view.removeFromSuperview()
		}
		
		gameController.startNewGame(nil)
		
		// AlephOne.display_main_menu()
		// AlephOne.begin_new_game()
	}
	
	@IBAction func load(sender:AnyObject?) {
		print("load");
	}
	
	@IBAction func settings(sender:AnyObject?) {
		print("settings");
	}
	
	@IBAction func about(sender:AnyObject?) {
		print("about");
	}
}
