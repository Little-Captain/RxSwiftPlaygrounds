//: Playground - noun: a place where people can play

import RxSwift

func example(_ description: String,
             _ action: () -> ()) {
    print("================== \(description) ==================")
    action()
}

// 如何合并Observables

// 处理事件的前置条件
example("处理事件的前置条件") {
    enum Condition: String {
        case cellular = "Cellular"
        case wifi = "WiFi"
        case none = "none"
    }
    
    let bag = DisposeBag()
    let request = Observable<String>.create { observer in
        observer.onNext("Response from server.")
        observer.onCompleted()
        return Disposables.create()
    }
    
    request
        .startWith(Condition.wifi.rawValue)
        .subscribe(onNext: { dump($0) })
        .disposed(by: bag)
}

// 串行合并多个事件序列
// concat
// 1. 都 completed 总的才 completed
// 2. 任何一个 error 总的就 error
// 3. 前一个 observable 结束后，才开始发送后一个 observable 的 value
example("串行合并多个事件序列") {
    enum E: Error {
        case demo
    }
    
    let bag = DisposeBag()
    
    let queueA = PublishSubject<String>()
    let queueB = PublishSubject<String>()
    
    let sequence = Observable.concat([queueA.asObservable(), queueB.asObservable()])
    sequence
        .subscribe(onNext: {
            dump($0)
        }, onError: {
            print($0)
        }, onCompleted: {
            print("Completed")
        },onDisposed:  {
            print("Disposed")
        })
        .disposed(by: bag)
    
    queueA.onNext("A1")
    queueA.onNext("A2")
    //        queueA.onError(E.demo)
    //        queueA.onCompleted()
    queueB.onNext("B1")
    //    queueB.onError(E.demo)
    queueA.onNext("A3")
    queueB.onCompleted()
}

// 并行合并多个事件序列
// merge
// 1. 都 completed 总的才 completed
// 2. 任何一个 error 总的就 error
// 3. 多个 observable 的 value 并行发送，到了就发送
example("并行合并多个事件序列") {
    enum E: Error {
        case demo
    }
    let bag = DisposeBag()
    let queueA = PublishSubject<String>()
    let queueB = PublishSubject<String>()
    
    let sequence = Observable.merge([queueA.asObservable(), queueB.asObservable()])
    
    sequence
        .subscribe(onNext: {
            dump($0)
        }, onError: {
            print($0)
        }, onCompleted: {
            print("Completed")
        },onDisposed:  {
            print("Disposed")
        })
        .disposed(by: bag)
    
    queueA.onNext("A1")
    queueA.onNext("A2")
    //    queueA.onError(E.demo)
    queueB.onNext("B1")
    queueA.onNext("A3")
    queueA.onCompleted()
    queueB.onCompleted()
}

// 控制最大订阅数量
example("控制最大订阅数量") {
    let bag = DisposeBag()
    let queueA = PublishSubject<String>()
    let queueB = PublishSubject<String>()
    let queueC = PublishSubject<String>()
    
    let sequence = Observable
        .of(queueA.asObservable(),
            queueB.asObservable(),
            queueC.asObservable())
        .merge(maxConcurrent: 2)
    
    sequence
        .subscribe(onNext: {
            dump($0)
        }, onError: {
            print($0)
        }, onCompleted: {
            print("Completed")
        },onDisposed:  {
            print("Disposed")
        })
        .disposed(by: bag)
    
    queueA.onNext("A1")
    queueA.onNext("A2")
    queueB.onNext("B1")
    queueA.onNext("A3")
    queueB.onNext("B2")
    queueB.onNext("B3")
    queueB.onNext("B4")
    queueC.onNext("C1") // 发送失败。因为当前 queueA queueB 使用了所有的两个并发数
    queueA.onCompleted() // queueA 让出一个并发数
    queueC.onNext("C2")
    queueB.onNext("B5")
    queueC.onNext("C3")
    queueB.onCompleted()
    queueC.onNext("C4")
    queueC.onCompleted()
}
