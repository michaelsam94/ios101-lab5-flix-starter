//
//  ViewController.swift
//  ios101-lab5-flix1
//

import Nuke
import UIKit

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {
            if currentPage <= totalPages {
                fetchMovies(page: currentPage)
            }
        }
    }
}

// TODO: Add table view data source conformance
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
            as! MoviesCell
        let movie = movies[indexPath.row]

        if let moviePosterPath = movie.poster_path,
            let imageUrl = URL(string: "https://image.tmdb.org/t/p/w500" + moviePosterPath)
        {
            Nuke.loadImage(with: imageUrl, into: cell.movieImage)
        }
        cell.titleLabel.text = "\(movie.title)"
        cell.overviewLabel.text = "\(movie.overview)"
        return cell
    }

    // TODO: Add table view outlet
    @IBOutlet weak var moviesTableView: UITableView!

    // TODO: Add property to store fetched movies array
    private var movies = [Movie]()

    private var currentPage = 1
    private var totalPages = 1
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Assign table view data source
        moviesTableView.dataSource = self
        moviesTableView.delegate = self

        fetchMovies(page: currentPage)
    }

    // Fetches a list of popular movies from the TMDB API
    private func fetchMovies(page: Int) {
        guard !isLoading else { return }

        isLoading = true
        let url = URL(
            string:
                "https://api.themoviedb.org/3/movie/popular?api_key=b1446bbf3b4c705c6d35e7c67f59c413&language=en-US&page=\(page)"
        )!

        let session = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer { self?.isLoading = false }

            if let error = error {
                print("🚨 Request failed: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("🚨 Server Error: response: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("🚨 No data returned from request")
                return
            }

            do {
                let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                let movies = movieResponse.results

                DispatchQueue.main.async {
                    print("✅ SUCCESS!!! Fetched \(movies.count) movies")
                    self?.movies.append(contentsOf: movies)
                    self?.moviesTableView?.reloadData()
                    self?.currentPage += 1
                    self?.totalPages = movieResponse.total_pages
                }
            } catch {
                print(
                    "🚨 Error decoding JSON data into Movie Response: \(error.localizedDescription)")
                return
            }
        }

        session.resume()
    }

}
