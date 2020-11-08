//
//  ProfileUpdate.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import UIKit

class ProfileUpdate: UIViewController {
    @IBOutlet weak var nameTextfiled: UITextField!
    @IBOutlet weak var surnameTextfiled: UITextField!
    @IBOutlet weak var passTextfiled: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signup(_ sender: Any) {
        let body = UpdateData(personName: nameTextfiled.text!, personLastName: surnameTextfiled.text!, password: passTextfiled.text!)
        let req = ProfileUpdateRequest(body: body)
        ApiService<GenericResponse<LoginResponse>>().getData(request: req) { (result) in
            switch result {
            case .success(let data):
                if !data.error {
                    DispatchQueue.main.async {
    //                    UserDefaults.standard.setValue("TOKEN", forKey: token)
                        self.navigationController?.popViewController(animated: true)
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


struct ProfileUpdateRequest: ApiRequestProtocol {
    var method: HttpMethod
    var url: String
    var body: Encodable?
        
    init(body: Encodable) {
        method = .POST
        url = Constant.baseUrl + "updatePerson"
        self.body = body
    }
}

struct UpdateData: Codable {
    let personName: String
    let personLastName: String
    let password: String
}
