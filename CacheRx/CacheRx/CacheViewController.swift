//
//  ViewController.swift
//  CacheRx
//
//  Created by 김인환 on 2022/03/21.
//

import UIKit
import RxSwift

class CacheViewController: UIViewController {

    @IBOutlet weak var imageLoadLabel: UILabel!
    @IBOutlet weak var cheeImageView: UIImageView!
    @IBOutlet weak var bengImageView: UIImageView!
    
    let imageCache = NSCache<NSString, UIImage>()
    
    let cheeCacheKey: NSString = NSString(string: "Chee")
    let bengCacheKey: NSString = NSString(string: "Beng")
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // 외부로부터 넘겨받는다
    var cheeImageUrl: URL?
    var bengImageUrl: URL?
    
    enum nilError: Error {
        case optionalError
        case decodeError
        case loadError
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    func fetchData() { // 처음 이미지를 받아 캐싱
        imageLoadLabel.text = "이미지 로딩 중"
        subscribeCheeImage()
        subscribeBengImage()
    }
    
    func subscribeBengImage() {
        guard let bengImageUrl = bengImageUrl else {
            return
        }

        fetchImage(from: bengImageUrl).subscribe { event in
            switch event {
            case .success(let image):
                DispatchQueue.main.async {
                    self.bengImageView.image = image
                    self.imageLoadLabel.text = "이미지 로딩 완료"
                }
                guard let image = image else { return }
                self.imageCache.setObject(image, forKey: self.bengCacheKey)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }.disposed(by: disposeBag)
    }
    
    func subscribeCheeImage() {
        guard let cheeImageUrl = cheeImageUrl else {
            return
        }

        fetchImage(from: cheeImageUrl).subscribe { event in
            switch event {
            case .success(let image):
                DispatchQueue.main.async {
                    self.cheeImageView.image = image
                    self.imageLoadLabel.text = "이미지 로딩 완료"
                }
                guard let image = image else { return }
                self.imageCache.setObject(image, forKey: self.cheeCacheKey)
            case .failure(let error):
                print(error.localizedDescription)
            }
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
                    emitter(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    @IBAction func touchImageReloadButton(_ sender: UIButton) {
        imageLoadLabel.text = "이미지 로딩 중"
        
        guard let cheeImageUrl = cheeImageUrl,
              let bengImageUrl = bengImageUrl else { return }
        
        if let cheeCachedImage = imageCache.object(forKey: cheeCacheKey) {
            cheeImageView.image = cheeCachedImage
        } else {
            subscribeCheeImage()
        }
        
        if let bengCachedImage = imageCache.object(forKey: bengCacheKey) {
            bengImageView.image = bengCachedImage
        } else {
            subscribeCheeImage()
        }
    }
    
    @IBAction func touchClearButton(_ sender: UIButton) {
        cheeImageView.image = nil
        bengImageView.image = nil
    }
}
