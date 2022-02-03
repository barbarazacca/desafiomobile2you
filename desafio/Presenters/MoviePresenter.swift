//
//  MoviePresenter.swift
//  desafio
//
//  Created by Bárbara on 02/02/22.
//

import Foundation
import Alamofire
import RxSwift

protocol MoviePresenterDelegate: AnyObject {
    func renderLoading()
    func render(data: MovieViewModel)
    func renderError(_ error: RequestError)
}

protocol MoviePresenterProtocol: AnyObject {
    func populate()
}

class MoviePresenter : MoviePresenterProtocol {
    
    private weak var delegate: MoviePresenterDelegate?
    
    private let movieId = 194; // Id do filme le fabuleux destin d'amlie poulain
    
    var disposeBag: DisposeBag = DisposeBag()
    
    init(delegate: MoviePresenterDelegate) {
        self.delegate = delegate
    }
    
    internal func populate() {
        // TODO: Criar requisição do filme e dos filmes relacionados
        
        MovieService.shared.getById(id: self.movieId)
            .subscribe(onNext: { [self] movie in
                MovieService.shared.getSimilarMoviesById(id: movieId)
                    .subscribe(onNext: { [self] movies in
                        GenreService.shared.getGenresList().subscribe(onNext: { [self] genres in
                            var dict = Dictionary<Int,String>()
                            genres.forEach { dict[$0.id] = $0.name }
                            self.delegate?.render(data: MovieViewModel(movie: movie, similarMovies: movies, genres: dict))
                        },
                        onError: { [self] error in
                            self.delegate?.renderError(error as! RequestError)
                        }).disposed(by: self.disposeBag)
                    },
                    onError: { [self] error in
                        self.delegate?.renderError(error as! RequestError)
                    }).disposed(by: self.disposeBag)
            },
            onError: { [self] error in
                self.delegate?.renderError(error as! RequestError)
            }).disposed(by: self.disposeBag)
        
    }
}
