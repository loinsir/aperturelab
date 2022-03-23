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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()
    }
    
    func requestData() {
        guard let cheeUrl: URL = URL(string: cheeUrl),
              let bengUrl: URL = URL(string: bengUrl) else { return }
        
        fetchData(from: cheeUrl).subscribe { event in
            switch event {
            case .next(let image):
                DispatchQueue.main.async {
                    guard let image = image else { return }
                    self.cheeImageView.image = image
                }
            case .completed:
                DispatchQueue.main.async {
                    self.imageLoadLabel.text = "이미지 로딩 완료"
                }
            case .error(let error):
                print(error.localizedDescription)
            }
        }.disposed(by: disposeBag)
        
        fetchData(from: bengUrl).subscribe { event in
            switch event {
            case .next(let image):
                DispatchQueue.main.async {
                    guard let image = image else { return }
                    self.bengImageView.image = image
                }
            case .completed:
                DispatchQueue.main.async {
                    self.imageLoadLabel.text = "이미지 로딩 완료"
                }
            case .error(let error):
                print(error.localizedDescription)
            }
        }.disposed(by: disposeBag)
    }
    
    func fetchData(from url: URL) -> Observable<UIImage?> { // 초기 데이터를 fetch한다.
        imageLoadLabel.text = "이미지 로드 중"

        var request = URLRequest(url: url)
        request.setValue("fbd7a055-ef60-4a3a-9049-d0dfb942b615", forHTTPHeaderField: "x-api-key")
        
        return Observable.create { emitter in
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    emitter.onError(error)
                }
                
                if let data = data {
                    do {
                        if url.absoluteString == self.cheeUrl {
                            let decodedData = try JSONDecoder().decode(CheetohDataModel.self, from: data)
                            guard let imageUrl = URL(string: decodedData[0].url) else { return emitter.onError(NSError()) }
                            self.cheeImageUrl = imageUrl
                            let imageData = try Data(contentsOf: imageUrl)
                            emitter.onNext(UIImage(data: imageData))
                        } else {
                            let decodedData = try JSONDecoder().decode(BengalDataModels.self, from: data)
                            guard let imageUrl = URL(string: decodedData[0].url) else { return emitter.onError(NSError()) }
                            let imageData = try Data(contentsOf: imageUrl)
                            self.bengImageUrl = imageUrl
                            emitter.onNext(UIImage(data: imageData))
                        }
                    } catch {
                        emitter.onError(error)
                    }
                }
                emitter.onCompleted()
            }.resume()
            return Disposables.create()
        }
    }
    
    func fetchImage(from url: URL) -> Observable<UIImage?> { // image URL로만 이미지를 불러오는 메서드
        imageLoadLabel.text = "이미지 로드 중"
        return Observable.create { emitter in
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url)
                    let image = UIImage(data: data)
                    emitter.onNext(image)
                } catch {
                    emitter.onError(error)
                }
                emitter.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    @IBAction func touchImageReloadButton(_ sender: UIButton) {
        imageLoadLabel.text = "이미지 로딩 중"
        guard let cheeImageUrl = cheeImageUrl,
              let bengImageUrl = bengImageUrl else { return }

        fetchImage(from: cheeImageUrl).subscribe { event in
            switch event {
            case .next(let image):
                DispatchQueue.main.async {
                    self.cheeImageView.image = image
                }
            case .completed:
                DispatchQueue.main.async {
                    self.imageLoadLabel.text = "이미지 로딩 완료"
                }
            case .error(let error):
                print(error.localizedDescription)
            }
        }.disposed(by: disposeBag)
        
        fetchImage(from: bengImageUrl).subscribe { event in
            switch event {
            case .next(let image):
                DispatchQueue.main.async {
                    self.bengImageView.image = image
                }
            case .completed:
                DispatchQueue.main.async {
                    self.imageLoadLabel.text = "이미지 로딩 완료"
                }
            case .error(let error):
                print(error.localizedDescription)
            }
        }.disposed(by: disposeBag)
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
