//
//  ViewController.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 6.11.2020.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pageImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pageDots: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    private var currentPage = 0
    
    let onboardingData: [OnboardingPageDataModel] = [
        .init(title: "Hoşgeldiniz",
              imageName: "road_to_knowledge",
              description: "xbooks ile kitap okuma alışkanlığınızı üst seviyelere çıkarın, bu hızlı tur size rehberlik edecekktir, ileri butonuna tıklayın ve müthiş özelliklerimizi keşfedin",
              buttonName: "İleri"),
        .init(title: "Nasıl mı?",
              imageName: "reading_time",
              description: "Xbooks ile kitap okudukça puan kazanırsınız, kazanacağınız puanlar sisin kitap okumanıza göre hesaplanır ve daima sizin daha fazla ve daha verimli şekilde okumanız için size özel teklifler sunar.",
              buttonName: "İleri"),
        .init(title: "Burada ücret yoookkk",
              imageName: "book_reading",
              description: "Platform'a kayıt olduğunuz zaman sizden ücret istemiyoruz, size puan veriyoruz. Verdiğimiz puan ile kitap alıp ardından bu kitabı okudukça yeni kitaplar alabilmek için puan kazanacaksınız.",
              buttonName: "İleri"),
        .init(title: "Unutamayacaksınız :)",
              imageName: "in_no_time",
              description: "Günlük kitap okuma alışkanlığınızı takip edip alışkanlığınız dışına çıktığınız durumlarda size bildirim göndereceğiz.",
              buttonName: "İleri"),
        .init(title: "O zaman başlayalımmm",
              imageName: "book_lover",
              description: "Öncelikle bir hesaba sahip değilsen hesap açmanı isteyeceğiz, eğer bir hesaba sahipsen giriş yaparak devam edebilirsin",
              buttonName: "Devam"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageDots.numberOfPages = onboardingData.count
        setData(index: 0)
    }
    
    func setData(index: Int) {
        currentPage = index
        let data = onboardingData[index]
        
        titleLabel.text = data.title
        pageImage.image = UIImage(named: data.imageName)
        descriptionLabel.text = data.description
        pageDots.currentPage = index
        nextButton.setTitle(data.buttonName, for: .normal)
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        if currentPage == onboardingData.count - 1 {
            let actionSheet = UIAlertController(title: "",
                                                message: "",
                                                preferredStyle: .actionSheet)
            let loginAction = UIAlertAction(title: "Giriş Yap",
                                            style: .default) { (_) in
                self.performSegue(withIdentifier: "toLoginPage", sender: nil)
            }
            let signupAction = UIAlertAction(title: "Kayıt Ol",
                                             style: .default) { (_) in
                self.performSegue(withIdentifier: "toSignupPage", sender: nil)
            }
            actionSheet.addAction(loginAction)
            actionSheet.addAction(signupAction)
            self.present(actionSheet, animated: true)
        } else {
            setData(index: (currentPage + 1))
        }
    }
}

struct OnboardingPageDataModel {
    let title: String
    let imageName: String
    let description: String
    let buttonName: String
}
