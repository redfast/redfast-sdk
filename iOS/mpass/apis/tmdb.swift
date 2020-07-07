import Foundation
import PromiseKit
import Alamofire
import SwiftyJSON
import UIKit

class TmdbApi {
    static let API_KEY = "e3b287b40edd5313ba5318db511ee52a"
    static let BASE_URL = "https://api.themoviedb.org/3/"
    static let QUERY_TAIL = "api_key=\(API_KEY)&language=en-US"
    
    func tvGetGenre() -> Promise<JSON> {
        return Promise { seal in
            let dataRequest = AF.request(TmdbApi.BASE_URL + "genre/tv/list?" + TmdbApi.QUERY_TAIL)
            dataRequest.responseJSON { response in
                //print(dataRequest.description)
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    seal.fulfill(json["genres"])
                case .failure(let error):
                    seal.reject(error)
                }
            }
            
        }
    }
    
    func tvGetGenreCollection(_ gid: Int) -> Promise<JSON> {
        return Promise { seal in
            let dataRequest = AF.request(TmdbApi.BASE_URL + "discover/tv?sort_by=popularity.desc&page=1&with_genres=\(gid)&" + TmdbApi.QUERY_TAIL)
            dataRequest.responseJSON { response in
                //print(dataRequest.description)
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    seal.fulfill(json)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getPoster(_ url: String) -> LiveData<UIImage> {
        let data = LiveData<UIImage>()
        let dataRequest = AF.request("https://image.tmdb.org/t/p/w400\(url)")
        dataRequest.responseData { response in
            //print(dataRequest.description)
            switch response.result {
            case .success(let value):
                data.data = UIImage(data: value)
            case .failure(let error):
                print(error)
            }
        }
        return data
    }
}
