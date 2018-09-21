//: Playground - noun: a place where people can play

// 理解create和debug operator

import RxSwift

enum CustomError: Error {
    case somethingWrong
}

let customOb = Observable<Int>.create { observer in
    observer.onNext(10)
    observer.onError(CustomError.somethingWrong)
    observer.onNext(11)
    observer.onCompleted()
    
    return Disposables.create()
}

let disposeBag = DisposeBag()

customOb.debug()
    .subscribe(
        onNext: { print($0) },
        onError: { print($0) },
        onCompleted: { print("Completed") },
        onDisposed: { print("Game over") }
    ).disposed(by: disposeBag)
