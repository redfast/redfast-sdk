import UIKit
import SwiftyJSON
import RedFast
import Alamofire
import SDWebImage

class MovieRow: UITableViewCell {
    var index = 0
    var genre: JSON?
    @IBOutlet weak var movieCells: UICollectionView!
    @IBOutlet weak var rowTitle: UILabel!
}

class BillboardCell: UICollectionViewCell {
    @IBOutlet weak var poster: UIImageView!
}

class MovieCell: UICollectionViewCell {
    let api = TmdbApi()
    @IBOutlet weak var poster: UIImageView!
}

class ViewController: UIViewController {
    let viewModel = ViewModel()
    var billboards = [
        "https://8825eb66-9f8a-414c-aa37-ed18d08fe954.redfastlabs.com/assets/57a5f6c2-7ca5-486f-bf2c-0d06ae7f01e3_rf_settings_bg_image_web_desktop_composite.png?ts=1585698514",
        "https://8825eb66-9f8a-414c-aa37-ed18d08fe954.redfastlabs.com/assets/ca62caff-3444-4823-9aa2-ce6fad55e186_rf_settings_bg_image_web_desktop_composite.png?ts=1585698583",
        "https://8825eb66-9f8a-414c-aa37-ed18d08fe954.redfastlabs.com/assets/39e52f18-1bf7-4d04-b497-eb04eedc8236_rf_settings_bg_image_web_desktop_composite.png?ts=1585681314",
        "https://8825eb66-9f8a-414c-aa37-ed18d08fe954.redfastlabs.com/assets/caff364d-922d-4547-9b45-5a532a23d3c0_rf_settings_bg_image_web_desktop_composite.png?ts=1585698691"
    ]
    @IBOutlet weak var unsubscribe: UIButton!
    
    @IBAction func unsubscribe(_ sender: Any) {
        PromotionManager.buttonClick(self, unsubscribe) { [weak self] result in
            switch result.code {
            case .declined:
                let alert = UIAlertController(title: "Thank you", message: "You have successfully accept the offer", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true)
            default:
                break
            }
        }
    }
    
    @IBAction func showOneInApp(_ sender: Any) {
        // the dialog here is just for displaying a UI. it can be removed totally
        // the real job is done in PromotionManager.purchase
        if let products = IAPHelper.shared.products, products.count > 0 {
            let p = products[0]
            let alert = UIAlertController(title: "IAP", message: "Would you like to purchase \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { action in
                switch action.style{
                case .default:
                    //IAPHelper.shared.purchase(p)
                    
                    PromotionManager.purchase("com.redfast.test.consumable") { result in
                        switch result {
                        case .successful:
                            break
                        default:
                            break
                        }
                    }
                default:
                    break
            }}))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PromotionManager.setScreenName(self, "ViewController") { _ in }
        viewModel.theDatabase.subscribe(onNext: { [weak self] db in
            if db.count > 0 {
                self?.movieRow.reloadData()
            }
        })
        viewModel.loadGenres()
        /*PromotionManager.getInlines(.billboard) { [weak self] paths in
            if let paths  = paths {
                self?.billboards = paths.map { path in
                    switch UIDevice.current.userInterfaceIdiom {
                    case .phone:
                        return path["actions"].dictionaryValue["rf_settings_bg_image_ios_iphone_composite"]?.stringValue ?? ""
                    case .pad:
                        return path["actions"].dictionaryValue["rf_settings_bg_image_ios_ipad_composite"]?.stringValue ?? ""
                    default:
                        return ""
                    }
                }
            }
            self?.billboardRow.reloadData()
        }*/
    }
    
    @IBOutlet weak var billboardRow: UICollectionView!
    @IBOutlet weak var movieRow: UITableView!
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let db = viewModel.theDatabase.data else { return 0 }
        return db.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieRow")!
        if let movieRow = cell as? MovieRow, let db = viewModel.theDatabase.data {
            let keys = Array(db.keys)
            if let genre = db[keys[indexPath.row]] {
                movieRow.index = indexPath.row
                movieRow.genre = genre
                if indexPath.row == 0 {
                    movieRow.rowTitle.text = "Promotions"
                } else {
                    movieRow.rowTitle.text = "\(genre["name"])"
                }
                movieRow.movieCells.dataSource = movieRow
                movieRow.movieCells.reloadData()
            }
        }
        cell.backgroundColor = .black
        return cell
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return billboards.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "billboard", for: indexPath)
        if let billboardCell = cell as? BillboardCell {
            billboardCell.poster.sd_setImage(with: URL(string: billboards[indexPath.row]))
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        return CGSize(width: screenSize.width, height: screenSize.height * 0.27)
    }
}

extension MovieRow: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let genre = genre else { return 0 }
        let results = genre["results"].arrayValue
        if self.index == 0 {
            return 5
        }
        //print("\(genre["name"].stringValue) - \(results.count)")
        return results.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath)
        if let movieCell = cell as? MovieCell, let genre = genre {
            let results = genre["results"].arrayValue
            let movie = results[indexPath.row]
            if (self.index == 0) {
                let urls = [
                    "https://8825eb66-9f8a-414c-aa37-ed18d08fe954.redfastlabs.com/assets/49150dc5-35e2-498a-aba5-8b71ec9eb444_rf_settings_bg_image_web_desktop_composite.png?ts=1585681345",
                    "https://8825eb66-9f8a-414c-aa37-ed18d08fe954.redfastlabs.com/assets/b25c5395-832c-4523-8596-7e088f61bc52_rf_settings_bg_image_web_desktop_composite.png?ts=1585681370",
                    "https://8825eb66-9f8a-414c-aa37-ed18d08fe954.redfastlabs.com/assets/a39deffd-d074-49d2-854b-2d260593175f_rf_settings_bg_image_web_desktop_composite.png?ts=1585681416",
                    "https://8825eb66-9f8a-414c-aa37-ed18d08fe954.redfastlabs.com/assets/ba924bb6-116f-43c2-8a05-7e7324941104_rf_settings_bg_image_web_desktop_composite.png?ts=1585681431",
                    "https://8825eb66-9f8a-414c-aa37-ed18d08fe954.redfastlabs.com/assets/136e778b-c9ec-4591-8297-2d72836b0fec_rf_settings_bg_image_web_desktop_composite.png?ts=1585695705"
                ]
                movieCell.poster.sd_setImage(with: URL(string:urls[indexPath.row]))
            } else {
                movieCell.poster.sd_setImage(with: URL(string: "https://image.tmdb.org/t/p/w400/\(movie["poster_path"].stringValue)"))
            }
        }
        cell.backgroundColor = .black
        return cell
    }
}

