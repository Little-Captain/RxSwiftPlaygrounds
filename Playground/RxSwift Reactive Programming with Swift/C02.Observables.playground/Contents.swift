//: Playground - noun: a place where people can play

import RxSwift

//: Observable
example(of: "just, of, from") {
    // 1
    let one = 1
    let two = 2
    let three = 3
    
    // 2
    let observable: Observable<Int> = Observable<Int>.just(one)
    let observable2 = Observable.of(one, two, three)
    let observable3 = Observable.of([one, two, three])
    let observable4 = Observable.from([one, two, three])
    
    //    let sequence = 0..<3
    //    var iterator = sequence.makeIterator()
    //    while let n = iterator.next() {
    //        print(n)
    //    }
    
    let bag = DisposeBag()
    
    observable4
        .subscribe { event in
            print(event)
        }
        .disposed(by: bag)
}

example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable.of(one, two, three)
    
    let bag = DisposeBag()
    
    observable
        .subscribe { event in
            print(event)
        }
        .disposed(by: bag)
    
    observable
        .subscribe { event in
            if let element = event.element {
                print(element)
            }
        }
        .disposed(by: bag)
    
    observable
        .subscribe(onNext: { element in
            print(element)
        })
        .disposed(by: bag)
}

example(of: "empty") {
    let observable = Observable<Void>.empty()
    let bag = DisposeBag()
    observable
        .subscribe(onNext: { element in
            print(element)
        }, onCompleted: {
            print("Completed")
        })
        .disposed(by: bag)
}

example(of: "never") {
    let observable = Observable<Void>.never()
    let bag = DisposeBag()
    observable
        .subscribe(onNext: { element in
            print(element)
        }, onCompleted: {
            print("Completed")
        })
        .disposed(by: bag)
}

example(of: "range") {
    let observable = Observable<Int>.range(start: 1, count: 10)
    let bag = DisposeBag()
    observable
        .subscribe(onNext: { i in
            let n = Double(i)
            let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
            print(fibonacci)
        })
        .disposed(by: bag)
    observable
        .map { i -> Int in
            let n = Double(i)
            return Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: bag)
}

example(of: "dispose") {
    // 1
    let observable = Observable.of("A", "B", "C")
    // 2
    let subscription = observable
        .subscribe { event in
            // 3
            print(event)
    }
    subscription.dispose()
}

example(of: "DisposeBag") {
    let disposeBag = DisposeBag()
    Observable.of("A", "B", "C")
        .subscribe {
            print($0)
        }
        .disposed(by: disposeBag)
    Observable.of("A", "B", "C")
        .subscribe(onDisposed: {
            print("Disposed")
        })
        .dispose()
}

example(of: "create") {
    enum MyError: Error {
        case anError
    }
    let disposeBag = DisposeBag()
    Observable<String>
        .create { observer in
            observer.onNext("A")
            observer.onError(MyError.anError)
            observer.onNext("B")
//            observer.onCompleted()
            observer.onNext("C")
            return Disposables.create()
        }
        .subscribe(
            onNext: { print($0) },
            onError: { print($0) },
            onCompleted: { print("Completed") },
            onDisposed: { print("Disposed") })
        .disposed(by: disposeBag)
    
    // 注意: observable 被回收的三种情况(内存被释放)
    // 1. 发送 completed 事件(正常)
    // 2. 发送 error 事件(异常)
    // 3. 调用 dispose 方法(手动调用, 或通过 dispose bag 管理)
}

example(of: "deferred") {
    var flip = false
    let factory: Observable<Int> = Observable.deferred {
        flip = !flip
        if flip {
            return Observable.of(1, 2, 3)
        } else {
            return Observable.of(4, 5, 6)
        }
    }
    
    for _ in 0...3 {
        let bag = DisposeBag()
        factory
            .subscribe(onNext: {
                print($0, terminator: " ")
            }, onCompleted: {
                print("completed", terminator: " ")
            }, onDisposed: {
                print("disposed", terminator: " ")
            })
            .disposed(by: bag)
        // of 运算符中的所有元素发送完毕，就会立即发送 completed 然后被回收
        // 也就是上面的 .disposed(by: bag) 不调用，效果是一样的
        print()
    }
}

example(of: "Single") {
    let disposeBag = DisposeBag()
    enum FileReadError: Error {
        case fileNotFound, unreadable, encodingFailed
    }
    
    func loadText(from name: String) -> Single<String> {
        return Single.create { single in
            let disposable = Disposables.create()
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                single(.error(FileReadError.fileNotFound))
                return disposable
            }
            guard let data = FileManager.default.contents(atPath: path) else {
                single(.error(FileReadError.unreadable))
                return disposable
            }
            guard let contents = String(data: data, encoding: .utf8) else {
                single(.error(FileReadError.encodingFailed))
                return disposable
            }
            single(.success(contents))
            return disposable
        }
    }
    
    loadText(from: "Copyright")
        //        .subscribe {
        //            switch $0 {
        //            case .success(let string):
        //                print(string)
        //            case .error(let error):
        //                print(error)
        //            }
        //        }
        .subscribe(onSuccess: { print($0) }, onError: { print($0) })
        .disposed(by: disposeBag)
}

example(of: "Maybe") {
    
    enum MaybeError: Error {
        case mayError
    }
    
    let disposeBag = DisposeBag()
    
    let number = 2
    
    func getMaybe() -> Maybe<String> {
        return Maybe.create { maybe in
            switch number {
            case 1:
                maybe(.success("success"))
            case 2:
                maybe(.completed)
            default:
                maybe(.error(MaybeError.mayError))
            }
            return Disposables.create()
        }
    }
    
//    getMaybe().subscribe(onSuccess: {
//        print($0)
//    }, onError: {
//        print($0)
//    }, onCompleted: {
//        print("completed")
//    })
    getMaybe().asObservable()
        .subscribe(onNext: {
            print($0)
        }, onError: {
            print($0)
        }, onCompleted: {
            print("completed")
        }, onDisposed: {
            print("disposed")
        })
}

example(of: "Completed") {
    
    enum CompletedError: Error {
        case cError
    }
    
    let disposeBag = DisposeBag()
    
    let number = 1
    
    func getCompleted() -> Completable {
        return Completable.create { com in
            switch number {
            case 1:
                com(.completed)
            default:
                com(.error(CompletedError.cError))
            }
            return Disposables.create()
        }
    }

//    getCompleted().subscribe(onCompleted: {
//        print("completed")
//    }, onError: {
//        print($0)
//    })
    getCompleted().asObservable()
        .subscribe(onNext: {
            print($0)
        }, onError: {
            print($0)
        }, onCompleted: {
            print("completed")
        }, onDisposed: {
            print("disposed")
        })
}

example(of: "Perform side effects: do") {
    let observable = Observable<Void>.never()
    observable
        .do(onCompleted: {
            print("do Completed")
        }, onSubscribe: {
            print("do Subscribe")
        }, onDispose: {
            print("do Disposed")
        })
        .subscribe(onNext: { element in
            print(element)
        }, onCompleted: {
            print("Completed")
        }, onDisposed: {
            print("Disposed")
        })
        .dispose()
}

example(of: "Print debug info: debug") {
    let disposeBag = DisposeBag()
    Observable.of("A", "B", "C")
        .debug("Debug", trimOutput: false)
        .subscribe {
            print($0)
        }
        .disposed(by: disposeBag)
}
