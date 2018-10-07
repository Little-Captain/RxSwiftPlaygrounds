//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire

//: RxAlamofire

let bag = DisposeBag()

// Basic requests
Observable.of("Little-Captain/RxSwiftPlaygrounds")
    .map { URL(string: "https://api.github.com/repos/\($0)/events")! }
    .flatMap { string(.get, $0) }
    .subscribe(onNext: { print("📌 string: \($0)") })
    .disposed(by: bag)

Observable.of("Little-Captain/RxSwiftPlaygrounds")
    .map { URL(string: "https://api.github.com/repos/\($0)/events")! }
    .flatMap { json(.get, $0) }
    .subscribe(onNext: { print("📌 json: \($0)") })
    .disposed(by: bag)

Observable.of("Little-Captain/RxSwiftPlaygrounds")
    .map { URL(string: "https://api.github.com/repos/\($0)/events")! }
    .flatMap { data(.get, $0) }
    .subscribe(onNext: { print("📌 data: \($0)") })
    .disposed(by: bag)

// Request customization
Observable.of("Little-Captain/RxSwiftPlaygrounds")
    .map { URL(string: "https://api.github.com/repos/\($0)/events")! }
    .flatMap { json(.get, $0, parameters: nil) }
    .subscribe(onNext: { print("📌 Request customization json: \($0)") })
    .disposed(by: bag)

// Response validation
Observable.of("Little-Captain/RxSwiftPlaygrounds")
    .map { URL(string: "https://api.github.com/repos/\($0)/events")! }
    .flatMap { request(.get, $0) }
    .flatMap {
        $0
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .rx.json()
    }
    .subscribe(onNext: { print("📌 Response validation json: \($0)") })
    .disposed(by: bag)

// Downloading files
let destination: DownloadRequest.DownloadFileDestination = { _, response in
    let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let filename = response.suggestedFilename ?? "image.png"
    let fileURL = docsURL.appendingPathComponent(filename)
    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
}

Observable.of("Little-Captain/RxSwiftPlaygrounds")
    .map { URL(string: "https://api.github.com/repos/\($0)/events")! }
    .map { URLRequest(url: $0) }
    .flatMap {
        SessionManager.default.rx.download($0, to: destination)
    }
    .subscribe(onCompleted: { print("Download complete") })
    .disposed(by: bag)

// Upload tasks
Observable.of("Little-Captain/RxSwiftPlaygrounds")
    .map { URL(string: "https://api.github.com/repos/\($0)/events")! }
    .map { URLRequest(url: $0) }
    .flatMap {
        SessionManager.default.rx.upload(Data(), urlRequest: $0)
    }
    .subscribe(onCompleted: { print("Upload complete") })
    .disposed(by: bag)

// Tracking progress
Observable.of("Little-Captain/RxSwiftPlaygrounds")
    .map { URL(string: "https://api.github.com/repos/\($0)/events")! }
    .map { URLRequest(url: $0) }
    .flatMap {
        SessionManager.default
            .rx.upload(Data(), urlRequest: $0)
            .flatMap { $0.validate().rx.progress() }
    }
    .subscribe(onNext: {
        let percent = Int(100.0 * $0.completed)
        print("Upload progress: \(percent)%")
    }, onCompleted: {
        print("Upload complete")
    })
    .disposed(by: bag)

let hostView = setupHostView()
hostView
