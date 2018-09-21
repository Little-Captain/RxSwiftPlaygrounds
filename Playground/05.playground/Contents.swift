//: Playground - noun: a place where people can play

import RxSwift

func example(_ description: String,
             _ action: () -> ()) {
    
    print("================== \(description) ==================")
    action()
}

// 常用的忽略事件操作符

// ignoreElements
example("ignoreElements") {
    
    let tasks = PublishSubject<String>()
    let bag = DisposeBag()
    
    tasks.ignoreElements().subscribe { print($0) }.disposed(by: bag)
    
    tasks.onNext("T1")
    tasks.onNext("T2")
    tasks.onNext("T3")
    tasks.onCompleted()
}

// skip
example("skip") {
    
    let tasks = PublishSubject<String>()
    let bag = DisposeBag()
    
    tasks.skip(2).subscribe { print($0) }.disposed(by: bag)
    
    tasks.onNext("T1")
    tasks.onNext("T2")
    tasks.onNext("T3")
    tasks.onCompleted()
}

// skipWhile
// 跳过、当
example("skipWhile") {
    
    let tasks = PublishSubject<String>()
    let bag = DisposeBag()
    
    tasks.skipWhile { $0 != "T2" }.subscribe { print($0) }.disposed(by: bag)
    
    tasks.onNext("T1")
    tasks.onNext("T2")
    tasks.onNext("T3")
    tasks.onCompleted()
}

// skipUntil
// 跳过、直到
example("skipUntil") {
    
    let tasks = PublishSubject<String>()
    let bossIsAngry = PublishSubject<Void>()
    let bag = DisposeBag()
    
    tasks.skipUntil(bossIsAngry)
        .subscribe {
            print($0)
        }
        .addDisposableTo(bag)
    
    tasks.onNext("T1");
    bossIsAngry.onNext(());
    tasks.onNext("T2");
    tasks.onNext("T3");
    tasks.onCompleted();
}

// distinctUntilChanged
// 忽略连续重复事件
example("distinctUntilChanged") {
    
    let tasks = PublishSubject<String>()
    let bag = DisposeBag()
    
    tasks.distinctUntilChanged()
        .subscribe {
            print($0)
        }
        .addDisposableTo(bag)
    
    tasks.onNext("T1")
    tasks.onNext("T2")
    tasks.onNext("T2")
    tasks.onNext("T3")
    tasks.onNext("T3")
    tasks.onNext("T4")
    tasks.onCompleted()
}
