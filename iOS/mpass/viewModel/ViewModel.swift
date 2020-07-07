import Foundation
import SwiftyJSON

class ViewModel {
    let model = TmdbModels()
    var theDatabase = LiveData<[Int:JSON]>([:])
    
    func loadGenres() {
        var genres: [Int:JSON] = [:]
        var loadingGenres = 0
        model.fetchTvGenres().subscribe(onNext: { [weak self] json in
            for genre in json.arrayValue {
                genres[genre["id"].intValue] = genre
            }
            loadingGenres = genres.count
            for (id, _) in genres {
                self?.model.fetchTvByGenre(id).subscribe(onNext: { json in
                    let gid = json["gid"].intValue
                    if var genre = genres[gid] {
                        genre["results"] = json["results"]
                        genres[gid] = genre
                        loadingGenres -= 1
                        if loadingGenres == 0 {
                            self?.theDatabase.data = genres
                        }
                    }
                }, onError: { error in
                    loadingGenres -= 1
                    if loadingGenres == 0 {
                        self?.theDatabase.data = genres
                    }
                    print(error)
                })
            }
        }, onError: { error in
            print(error)
        })
    }
}
