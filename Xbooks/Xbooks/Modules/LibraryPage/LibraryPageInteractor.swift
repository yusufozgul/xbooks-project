//
//  LibraryPageInteractor.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import Foundation

enum LibraryPageCollectionModel: Hashable {
    case suggestedBooks(MainPageDataModel)
    case suggestedAuthor(LibraryPageAuthorDataModel)
}

struct LibraryPageAuthorDataModel: Hashable {
    let id = UUID()
    let title: String
    let description: String
    let imageURL: URL
}

protocol LibraryPageInteractorInterface {
    func getSuggestedBooks()
    func getSuggestedAuthorData()
}

class LibraryPageInteractor {
    weak var output: LibraryPageInteractorOutput?
}

extension LibraryPageInteractor: LibraryPageInteractorInterface {
    func getSuggestedBooks() {
        ApiService<GenericResponse<[MainPageDataModel]>>().getData(request: GetBooksRequest()) { (result) in
            switch result {
            case .success(let data):
                if data.data != nil {
                    self.output?.handleSuggestedBooks(result: .success(data.data!))
                } else {
                    print(data.message)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getSuggestedAuthorData() {
        let authors: [LibraryPageAuthorDataModel] = [
            .init(title: "J. K. Rowling",
                  description: "Joanne Kathleen 'Jo' Rowling veya bilinen adıyla J. K. Rowling, Harry Potter adlı fantastik roman serisinin İngiliz yazarı. Kathleen, kendisine verilen bir ad olmamasına rağmen, büyükannesinin onuruna bu adı almıştır.",
                  imageURL: URL(string: "https://i2.wp.com/filmloverss.com/wp-content/uploads/2020/06/jk-rowling-1-filmloverss.jpg?w=900&ssl=1")!),
            .init(title: "Stefan Zweig",
                  description: "Stefan Zweig, Avusturyalı yazar. Roman, uzun öykü, tiyatro, deneme, şiir, seyahat, anı türlerinde yirmiden fazla eser verdi.",
                  imageURL: URL(string: "https://cdn.kidega.com/author/large/stefan-zweig-profil-Zo.jpg")!),
            .init(title: "Dan Brown",
                  description: "Dan Brown, Amerikalı yazar. Amherst Koleji ve Philips Exeter Akademisi’nden mezun olduktan sonra bir süre eğitim gördüğü bu okullarda İngilizce öğretmenliği yaptı. Şifre çözme ve gizli hükûmet örgütlerine duyduğu ilgi, 1996'da ilk romanı Dijital Kale'nin ortaya çıkmasını sağladı. ",
                  imageURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/8/8b/Dan_Brown_bookjacket_cropped.jpg")!),
            .init(title: "Arthur Conan Doyle",
                  description: "Arthur Ignatius Conan Doyle, İskoçyalı bir yazar. Suç hikâyelerinde bir çığır açmış olduğu söylenen karakter Dedektif Sherlock Holmes ve Profesör Challenger'ın fikir babasıdır. Yazmış olduğu diğer eserler arasında bilimkurgu, tarihi kitaplar, oyunlar, şiirler ve kurgu dışı düz yazılar vardır.",
                  imageURL: URL(string: "https://i2.wp.com/www.ithaki.com.tr/wp-content/uploads/2017/06/arthur-conan-doyle.jpg")!),
            .init(title: "Stephen King",
                  description: "Stephen Edwin King, Amerikalı hikâye ve roman yazarı. Genellikle gerilim ve korku türünde eserler vermiştir. Kitaplarının çoğu Türkçeye de çevrilmiştir. İlk romanı Göz 1974 yılında yayımlanmıştır. Özellikle 1982 yılında başlayıp 2005 yılında sona erdirmiş olduğu Kara Kule serisi ile ünlüdür.",
                  imageURL: URL(string: "https://cdn.kidega.com/author/large/stephen-king-profil-tH.jpg")!),
            .init(title: "Jules Verne",
                  description: "Jules Gabriel Verne, Fransız yazar ve gezgin. Verne, Hugo Gernsback ve H. G. Wells ile genellikle 'Bilimkurgunun Babası' olarak adlandırılır. Eserlerinde ayrıntılarıyla tarif ettiği buluşlar ve makinaların o sıralarda gelişmekte olan Avrupa sanayisi ve teknolojisine ilham kaynağı olduğu düşünülür.",
                  imageURL: URL(string: "https://cdn.1000kitap.com/k/resimler/yazarlar/833_Jules_Verne292.jpg")!)
        ]
        output?.handleSuggestedAuthorData(result: .success(authors))
    }
}
