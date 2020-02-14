import Foundation
import PromiseKit
import SwiftyJSON

class TmdbModels {
    let api = TmdbApi()
    
    func fetchTvGenres() -> LiveData<JSON> {
        let data = LiveData<JSON>()
        firstly {
            api.tvGetGenre()
        }.done { genres in
            data.data = genres
        }.catch { err in
            data.error = err
        }
        return data
    }
    
    func fetchTvByGenre(_ gid: Int) -> LiveData<JSON> {
        let data = LiveData<JSON>()
        firstly {
            api.tvGetGenreCollection(gid)
        }.done { tvs in
            var json = tvs
            json["gid"] = JSON(gid)
            data.data = json
        }.catch { err in
            data.error = err
        }
        return data
    }
}

