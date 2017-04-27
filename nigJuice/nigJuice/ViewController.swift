//
//  ViewController.swift
//  nigJuice
//
//  Created by Kevin Vo on 3/10/17.
//  Copyright © 2017 Kevin Vo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let v1 : View1 = View1(nibName: "View1", bundle: nil)
        let v2 : View2 = View2(nibName: "View2", bundle: nil)
       // let v3 : View3 = View3(nibName: "View3", bundle: nil)
        
        self.addChildViewController(v1)
       self.scrollView.addSubview(v1.view)
       v1.didMove(toParentViewController: self)
        
        self.addChildViewController(v2)
        self.scrollView.addSubview(v2.view)
        v2.didMove(toParentViewController: self)
        
       // self.addChildViewController(v3)
       // self.scrollView.addSubview(v3.view)
      //  v3.didMove(toParentViewController: self)
        
        var v2Frame : CGRect = v2.view.frame
        v2Frame.origin.x = self.view.frame.width
        v2.view.frame = v2Frame
        
       //var v3Frame : CGRect = v3.view.frame
       //v3Frame.origin.x = self.view.frame.width * 2
      // v3.view.frame = v3Frame
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width * 2, height: self.view.frame.height)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
