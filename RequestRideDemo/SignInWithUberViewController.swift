//
//  SignInWithUberViewController.swift
//  RequestRideDemo
//
//  Created by Abhinay Balusu on 1/24/17.
//  Copyright © 2017 abhinay. All rights reserved.
//

import UIKit
import UberRides

class SignInWithUberViewController: UIViewController, LoginButtonDelegate {
    
    var scopes: [RidesScope]
    var loginManager: LoginManager
    var blackLoginButton: LoginButton
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        scopes = [.Profile, .Places, .Request]
        
        loginManager = LoginManager(loginType: .native)
        
        blackLoginButton = LoginButton(frame:CGRect(x: 8, y: 200, width: 200, height: 60) , scopes: scopes, loginManager: loginManager)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
//        blackLoginButton.presentingViewController = self
//        
//        blackLoginButton.delegate = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "SSO"
        
        //scopes = [.Profile, .Places, .Request]
        
        //loginManager = LoginManager(loginType: .native)
        
        //blackLoginButton = LoginButton(frame:CGRect(x: 8, y: 200, width: 200, height: 60) , scopes: scopes, loginManager: loginManager)
        
        //super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        blackLoginButton.presentingViewController = self
        
        blackLoginButton.delegate = self
        
        self.view.addSubview(blackLoginButton)
        
        blackLoginButton.translatesAutoresizingMaskIntoConstraints = true
        blackLoginButton.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleTopMargin]
        
        blackLoginButton.center = self.view.center
        
        //blackLoginButton.frame = CGRect(x: 8, y: blackLoginButton.frame.origin.y, width: blackLoginButton.frame.size.width-16, height: blackLoginButton.frame.size.height)
        
    
    }
    
    func loginButton(_ button: LoginButton, didLogoutWithSuccess success: Bool){
        
        if(success)
        {
            showMessage(message: "Logout")
        }
        
    }
    
    func loginButton(_ button: LoginButton, didCompleteLoginWithToken accessToken: AccessToken?, error: NSError?){
        
        if let _ = accessToken {
            print(accessToken ?? "Access Token")
            showMessage(message: "Saved access token!")
        } else if let error = error {
            showMessage(message: error.localizedDescription)
        } else {
            showMessage(message: "Error")
        }
        
    }
    
    private func showMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
