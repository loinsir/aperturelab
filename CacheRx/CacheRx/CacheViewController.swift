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
    
    // 외부로 넘겨받는다
    var cheeImageUrl: URL?
    var bengImageUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    func fetchData() { // 처음 이미지를 받아 캐싱
        imageLoadLabel.text = "이미지 로딩 중"
        guard let cheeImageUrl = cheeImageUrl,
              let bengImageUrl = bengImageUrl else { return }
        
        fetchImage(from: bengImageUrl).subscribe { event in
            switch event {
            case .next(let image):
                DispatchQueue.main.async {
                    self.bengImageView.image = image
                }
                guard let image = image else { return }
                self.imageCache.setObject(image, forKey: self.bengCacheKey)
            case .completed:
                DispatchQueue.main.async {
                    self.imageLoadLabel.text = "이미지 로딩 완료"
                }
            case .error(let error):
                print(error.localizedDescription)
            }
        }
        
        fetchImage(from: cheeImageUrl).subscribe { event in
            switch event {
            case .next(let image):
                DispatchQueue.main.async {
                    self.cheeImageView.image = image
                }
                guard let image = image else { return }
                self.imageCache.setObject(image, forKey: self.cheeCacheKey)
            case .completed:
                DispatchQueue.main.async {
                    self.imageLoadLabel.text = "이미지 로딩 완료"
                }
            case .error(let error):
                print(error.localizedDescription)
            }
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
        
        if let cheeCachedImage = imageCache.object(forKey: cheeCacheKey) {
            cheeImageView.image = cheeCachedImage
        } else {
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
        }
        
        if let bengCachedImage = imageCache.object(forKey: bengCacheKey) {
            bengImageView.image = bengCachedImage
        } else {
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
    }
    
    @IBAction func touchClearButton(_ sender: UIButton) {
        cheeImageView.image = nil
        bengImageView.image = nil
    }
}
