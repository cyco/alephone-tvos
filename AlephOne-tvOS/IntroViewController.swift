//
//  IntroViewController.swift
//  AlephOne-tvOS
//
//  Created by Christoph Leimbrock on 06/07/16.
//  Copyright © 2016 chris. All rights reserved.
//

import UIKit

@objc class IntroViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let image = UIImage(named: "somewhere")
    let imageView = UIImageView(image: image)
    imageView.frame = CGRectMake(0, 0, 1920, 1080)
    self.view.addSubview(imageView)
  }

	override func viewDidAppear(animated: Bool) {
		dispatch_in(1 * NSEC_PER_SEC, dispatch_get_main_queue()) {
			self.fadeToGameView()
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  private func fadeToGameView() {
		let mainMenuViewController = MainMenuViewController(nibName: nil, bundle: nil)
		self.parentViewController?.addChildViewController(mainMenuViewController)
		self.parentViewController?.transitionFromViewController(self, toViewController: mainMenuViewController, duration: 2.0, options: [], animations: nil, completion: nil)
		self.removeFromParentViewController()
		self.view.removeFromSuperview()
	}
}
