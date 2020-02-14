import Foundation
import SwiftyJSON

class ViewModel {
    let model = TmdbModels()
    
    var theDatabase = LiveData<[Int:JSON]>([:])
    
    func loadGenres() {
        var genres: [Int:JSON] = [:]
        model.fetchTvGenres().subscribe(onNext: { [weak self] json in
            for genre in json.arrayValue {
                genres[genre["id"].intValue] = genre
            }
            for (id, _) in genres {
                self?.model.fetchTvByGenre(id).subscribe(onNext: { json in
                    let gid = json["gid"].intValue
                    if var genre = genres[gid] {
                        genre["results"] = json["results"]
                        genres[gid] = genre
                        self?.theDatabase.data = genres
                    }
                }, onError: { error in
                    print(error)
                })
            }
        }, onError: { error in
            print(error)
        })
    }
}
