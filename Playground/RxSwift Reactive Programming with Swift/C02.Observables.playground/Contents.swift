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
    
    let sequence = 0..<3
    var iterator = sequence.makeIterator()
    while let n = iterator.next() {
        print(n)
    }
}

example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable.of(one, two, three)
    observable.subscribe { event in
        print(event)
    }
    observable.subscribe { event in
        if let element = event.element {
            print(element)
        }
    }
    observable.subscribe(onNext: { element in
        print(element)
    })
}

example(of: "empty") {
    let observable = Observable<Void>.empty()
    observable
        .subscribe(
            onNext: { element in
                print(element)
        },
            onCompleted: {
                print("Completed")
        })
}

example(of: "never") {
    let observable = Observable<Void>.never()
    observable
        .subscribe(
            onNext: { element in
                print(element)
        },
            onCompleted: {
                print("Completed")
        })
}

example(of: "range") {
    let observable = Observable<Int>.range(start: 1, count: 10)
    observable
        .subscribe(onNext: { i in
            let n = Double(i)
            let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
            print(fibonacci)
        })
    observable
        .map { i -> Int in
            let n = Double(i)
            return Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
        }
        .subscribe(onNext: {
            print($0)
        })
}

example(of: "dispose") {
    // 1
    let observable = Observable.of("A", "B", "C")
    // 2
    let subscription = observable.subscribe { event in
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
            observer.onCompleted()
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
    let disposeBag = DisposeBag()
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
        factory
            .subscribe(onNext: {
                print($0, terminator: "")
            })
            .disposed(by: disposeBag)
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
    
    loadText(from: "Copyright1")
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
        .debug("First", trimOutput: false)
        .subscribe {
            print($0)
        }
        .disposed(by: disposeBag)
}
