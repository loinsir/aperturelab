//
//  ViewController.swift
//  CacheRx
//
//  Created by 김인환 on 2022/03/21.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var imageLoadLabel: UILabel!
    @IBOutlet weak var cheeImageView: UIImageView!
    @IBOutlet weak var bengImageView: UIImageView!
    
    var disposeBag: DisposeBag = DisposeBag()
    
    let cheeUrl: String = "https://api.thecatapi.com/v1/images/search?breed_ids=chee"
    let bengUrl: String = "https://api.thecatapi.com/v1/images/search?breed_ids=beng"
    
    var cheeImageUrl: URL?
    var bengImageUrl: URL?
    
    enum nilError: Error {
        case optionalError
        case decodeError
        case loadError
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()
    }
    
    func requestData() {
        subscribeBengImage()
        subscribeCheeImage()
    }
    
    func subscribeBengImage() {
        if let bengImageUrl = bengImageUrl{
            fetchImage(from: bengImageUrl).subscribe { event in
                switch event {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.bengImageView.image = image
                        self.imageLoadLabel.text = "이미지 로딩 완료"
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        } else {
            guard let bengDataUrl = URL(string: bengUrl) else { return }
            fetchData(from: bengDataUrl).subscribe { event in
                switch event {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.bengImageView.image = image
                        self.imageLoadLabel.text = "이미지 로딩 완료"
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func subscribeCheeImage() {
        if let cheeImageUrl = cheeImageUrl {
            fetchImage(from: cheeImageUrl).subscribe { event in
                switch event {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.cheeImageView.image = image
                        self.imageLoadLabel.text = "이미지 로딩 완료"
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else {
            guard let cheeDataUrl = URL(string: cheeUrl) else { return }
            fetchData(from: cheeDataUrl).subscribe { event in
                switch event {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.cheeImageView.image = image
                        self.imageLoadLabel.text = "이미지 로딩 완료"
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func fetchData(from url: URL) -> Single<UIImage?> { // 초기 데이터를 fetch한다.
        imageLoadLabel.text = "이미지 로드 중"
        
        var request = URLRequest(url: url)
        request.setValue("fbd7a055-ef60-4a3a-9049-d0dfb942b615", forHTTPHeaderField: "x-api-key")
        
        return Single.create { emitter in
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    emitter(.failure(error))
                }
                
                if let data = data {
                    do {
                        if url.absoluteString == self.cheeUrl {
                            let decodedData = try JSONDecoder().decode(CheetohDataModel.self, from: data)
                            guard let imageUrl = URL(string: decodedData[0].url) else { return emitter(.failure(nilError.optionalError)) }
                            self.cheeImageUrl = imageUrl
                            
                            let imageData = try Data(contentsOf: imageUrl)
                            emitter(.success(UIImage(data: imageData)))
                            
                        } else {
                            let decodedData = try JSONDecoder().decode(BengalDataModels.self, from: data)
                            guard let imageUrl = URL(string: decodedData[0].url) else { return emitter(.failure(nilError.optionalError)) }
                            self.bengImageUrl = imageUrl
                            
                            let imageData = try Data(contentsOf: imageUrl)
                            emitter(.success(UIImage(data: imageData)))
                            
                        }
                    } catch {
                        emitter(.failure(nilError.decodeError))
                    }
                }
            }.resume()
            return Disposables.create()
        }
    }
    
    func fetchImage(from url: URL) -> Single<UIImage?> { // image URL로만 이미지를 불러오는 메서드
        imageLoadLabel.text = "이미지 로드 중"
        return Single.create { emitter in
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url)
                    let image = UIImage(data: data)
                    emitter(.success(image))
                } catch {
                    emitter(.failure(nilError.loadError))
                }
            }
            return Disposables.create()
        }
    }
    
    @IBAction func touchImageReloadButton(_ sender: UIButton) {
        imageLoadLabel.text = "이미지 로딩 중"
        subscribeCheeImage()
        subscribeBengImage()
    }
    
    @IBAction func touchClearButton(_ sender: UIButton) {
        cheeImageView.image = nil
        bengImageView.image = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cacheVC = segue.destination as? CacheViewController else { return }
        cacheVC.cheeImageUrl = cheeImageUrl
        cacheVC.bengImageUrl = bengImageUrl
    }
}
