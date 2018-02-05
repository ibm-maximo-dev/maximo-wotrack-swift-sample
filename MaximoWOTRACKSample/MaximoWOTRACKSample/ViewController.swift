//
//  ViewController.swift
//  MaximoWOTRACKSample
//
//  Created by Silvino Vieira de Vasconcelos Neto on 02/02/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var _hostPort: UITextField!
    @IBOutlet weak var _username: UITextField!
    @IBOutlet weak var _password: UITextField!
    @IBOutlet weak var _login_button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _username.autocapitalizationType = UITextAutocapitalizationType.none
        _username.autocorrectionType = UITextAutocorrectionType.no
        
        let hostPort = UserDefaults.standard.string(forKey: "hostPort")
        if hostPort != nil {
            _hostPort.text = hostPort
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func LoginButton(_ sender: Any) {
        do {
            let hostPortStr = _hostPort.text
            UserDefaults.standard.set(hostPortStr, forKey: "hostPort")
            var hostPort = hostPortStr!.split(separator: ":")
            _ = try MaximoAPI.shared().login(userName: _username.text!, password: _password.text!,
                    host: String(hostPort[0]), port: Int(hostPort[1])!)
        }
        catch {
            let alert = UIAlertController(title: "Error", message: "An error occurred during the login", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

