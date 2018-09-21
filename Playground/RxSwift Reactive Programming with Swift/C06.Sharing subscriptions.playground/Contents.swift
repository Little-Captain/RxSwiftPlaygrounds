//: Playground - noun: a place where people can play

import RxSwift

//: Sharing subscriptions
// The observable calls its create closure each time you subscribe to it
// in some situations, this might produce some bedazzling effects
// 每次订阅, 都会导致 observable 调用它的 create 闭包
// 在一些情况下, 这可能会产生一些令人费解的效果

example(of: "Sharing subscriptions") {
    
    var start = 0
    func getStartNumber() -> Int {
        start += 1
        return start
    }
    
    let numbers = Observable<Int>.create { observer in
        let start = getStartNumber()
        observer.onNext(start)
        observer.onNext(start+1)
        observer.onNext(start+2)
        observer.onCompleted()
        return Disposables.create()
    }
    //    output
    //    element [1]
    //    element [2]
    //    element [3]
    //    ---------------
    numbers
        .subscribe(onNext: { el in
            print("element [\(el)]")
        }, onCompleted: {
            print("---------------")
        })
    
    //    output
    //    element [2]
    //    element [3]
    //    element [4]
    //    ---------------
    numbers
        .subscribe(onNext: { el in
            print("element [\(el)]")
        }, onCompleted: {
            print("---------------")
        })
    // The problem is that each time you call subscribe(...), this creates a new Observable
    // for that subscription — and each copy is not guaranteed to be the same as the previous.
    // And even when the Observable does produce the same sequence of elements, it’s
    // overkill to produce those same duplicate elements for each subscription. There’s no
    // point in doing that.
    // 每次调用 subscribe(...), 都会为相应的 subscription 创建新的 Observable (调用 Observable 的 create 闭包)
    // 并不保证每个副本与前一个相同
    // 即使 Observable 生成相同的序列元素, 为每个 subscription 生成相同的重复元素也是一种浪费
    // 这样做毫无意义
    
    // To share a subscription, you can use the share() operator. A common pattern in Rx
    // code is to create several sequences from the same source Observable by filtering out
    // different elements in each of the results.
    // 为了共享 subscription, 你可以使用 share() operator
    // Rx 代码中的一个通用模式是:
    // 对相同的源 Observable, 调用不同的过滤操作来创建多个特定 Observable
    
    // share (and its specializations via parameters) create a subscription only when the
    // number of subscribers goes from 0 to 1 (e.g. when there isn't a shared subscription
    // already). When a second, third and so on subscribers start observing the sequence,
    // share uses the already created subscription to share with them. If all subscriptions to
    // the shared sequence get disposed (e.g. there are no more subscribers), share will dispose
    // the shared sequence as well. If another subscriber starts observing, share will create a
    // new subscription for it just like described above.
    
    // 只有当订阅者从 0 变为 1时, share 才创建订阅.
    // 当第二个, 第三个, ... 订阅者开始观察序列, share 共享已经创建的订阅给所有订阅者
    // 如果所有的订阅都被 disposed (没有订阅者了), share 也会 dispose
    // 如果另一个订阅者开始观察, share 将再次创建一个新的订阅
    
    // Note: share() does not provide any of the subscriptions with values emitted
    // before the subscription takes effect. share(replay:scope:), on the other hand,
    // keeps a buffer of the last few emitted values and can provide them to new
    // observers upon subscription.
    
    // 注意: share() 不为订阅提供任何默认值.
    // share(replay:scope:), 保持最近的已发送值, 并将它(们)提供给新的订阅者
    
    // The rule of thumb about sharing operators is that it's safe to use share() with
    // observables that do not complete, or if you guarantee no new subscriptions will be
    // made after completion.
    
    // 使用 share 的经验法则:
    // 1. 针对未完成的 observables 使用 share 是安全的
    // 2. 如果你能保证 observables 完成后, 没有新的订阅, 那么可以使用 share
}
