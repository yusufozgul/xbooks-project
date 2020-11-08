//
//  LoginPage.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import UIKit

class LoginPage: UIViewController {
    @IBOutlet weak var mailTextfiled: UITextField!
    @IBOutlet weak var passTextfiled: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender: Any) {
        let body = LoginData(personEmail: mailTextfiled.text!, password: passTextfiled.text!)
        let req = LoginRequest(body: body)
        ApiService<GenericResponse<LoginResponse>>().getData(request: req) { (result) in
            switch result {
            case .success(let data):
                if !data.error {
                    if let token = data.data?.token {
                        DispatchQueue.main.async {
                            UserDefaults.standard.setValue(token, forKey: "TOKEN")
                            let mainTabbar = MainTabbar()
                            mainTabbar.modalPresentationStyle = .fullScreen
                            self.present(mainTabbar, animated: true)
                        }
                    }
                } else {
                    print(data.message)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}


struct LoginData: Codable {
    let personEmail: String
    let password: String
}

struct LoginRequest: ApiRequestProtocol {
    var method: HttpMethod
    var url: String
    var body: Encodable?
        
    init(body: Encodable) {
        method = .POST
        url = Constant.baseUrl + "login"
        self.body = body
    }
}

struct LoginResponse: Codable {
    let token: String
}


