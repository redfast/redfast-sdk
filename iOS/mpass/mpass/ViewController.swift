import UIKit
import SwiftyJSON
import RedFast

class MovieRow: UITableViewCell {
    var genre: JSON?
    @IBOutlet weak var movieCells: UICollectionView!
    @IBOutlet weak var rowTitle: UILabel!
}

class MovieCell: UICollectionViewCell {
    let api = TmdbApi()
    @IBOutlet weak var poster: UIImageView!
}

class ViewController: UIViewController {
    let viewModel = ViewModel()
    @IBOutlet weak var unsubscribe: UIButton!
    
    @IBAction func unsubscribe(_ sender: Any) {
        PromotionManager.buttonClick(self, unsubscribe) { [weak self] result in
            switch result {
            case .declined:
                let alert = UIAlertController(title: "Thank you", message: "You have successfully accept the offer", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true)
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.theDatabase.subscribe(onNext: { [weak self] db in
            self?.movieRow.reloadData()
        })
        viewModel.loadGenres()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return .portrait
        case .pad:
            return .all
        default:
            return .portrait
        }
    }
    
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
                movieRow.genre = genre
                movieRow.rowTitle.text = "\(genre["name"])"
                movieRow.movieCells.dataSource = movieRow
                movieRow.movieCells.reloadData()
            }
        }
        cell.backgroundColor = .black
        return cell
    }
}

extension MovieRow: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let genre = genre else { return 0 }
        let results = genre["results"].arrayValue
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
            movieCell.api.getPoster("\(movie["poster_path"].stringValue)").subscribe(onNext: {
                image in
                movieCell.poster.image = image
            })
        }
        cell.backgroundColor = .black
        return cell
    }
}

