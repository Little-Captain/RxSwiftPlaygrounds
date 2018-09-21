//: Playground - noun: a place where people can play

import RxSwift
import RxCocoa

//: share vs. shareReplay
// The observable calls its create closure each time you subscribe to it
// in some situations, this might produce some bedazzling effects
// 每次订阅, 都会导致 observable 调用它的 create 闭包
// 在一些情况下, 这可能会产生一些令人费解的效果

example(of: "share vs. shareReplay") {
    let bag = DisposeBag()
    let response = Observable.of("ReactiveX/RxSwift")
        .map { URL(string: "https://api.github.com/repos/\($0)/events")! }
        .map { URLRequest(url: $0) }
        .flatMap { URLSession.shared.rx.response(request: $0) }
        .share(replay: 1, scope: .whileConnected)
    response
        .filter { response, _ in 200..<300 ~= response.statusCode }
        .subscribe(onNext: { print($0) })
        .disposed(by: bag)
    dispatchMain()
    
    // URLSession.rx.response(request:) sends your request to the server, and upon
    // receiving the response, emits a .next event just once with the returned data,
    // and then completes.
    // URLSession.rx.response(request:) 发送你的请求到服务器, 然后在收到响应时,
    // 发送一个 .next 事件返回数据, 然后完成
    
    // If the observable completes and then you subscribe to it again,
    // that will create a new subscription and will fire another
    // identical request to the server.
    // 如果 observable 完成后, 你再次订阅它
    // 这将创建一个新的订阅, 然后发起另一个完全相同的请求到服务器
    
    // To prevent situations like this, you use share(replay:, scope:).
    // This operator keeps a buffer of the last replay emitted elements
    // and feeds them to any newly subscribed observer. Therefore if your
    // request has completed and a new observer subscribes to the shared
    // sequence (via share(replay:, scope:)), it will immediately receive
    // the response from the server that's being kept in the buffer.
    // 为了防止这种情况, 请使用 share(replay:, scope:).
    // share() 会在没有任何订阅的时候被 dispose
    // 这个操作符用一个 buffet 来保存最近发出的一些元素, 然后发送给新的订阅者.
    // 因此, 如果你已经请求完成. 然后一个新的观察者订阅这个共享 observable
    // 它将立即收到保存在 buffer 中的响应数据
    
    // There are two scopes available to choose from: .whileConnected and .forever.
    // The former will buffer elements up to the point where it has no subscribers,
    // and the latter will keep the buffered elements forever. That sounds nice,
    // but consider the implications on how much memory is used by the app.
    // 有个范围可供选择: .whileConnected, .forever
    // .whileConnected: 缓存数据被保留, 直到没有任何订阅者.
    //                  也就是没有订阅者时, 缓存数据被释放
    // .forever: 缓存数据被永久的保留
    // 使用 .forever 时, 请考虑 app 的内存问题
    
    // The app would behave when using either scope:
    // .forever: the buffered network response is kept forever.
    //           New subscribers get the buffered response.
    // .whileConnected: the buffered network response is kept until
    //                  there are no more subscribers, and is then discarded.
    //                  New subscribers get a fresh network response.
    // 两种范围下的 app 行为:
    // .forever: 网络响应永久被缓存, 新订阅都将获取到缓存的响应
    // .whileConnected: 网络响应被保留到没有任何订阅者时, 然后网络响应被释放
    //                  新订阅通过网络获取一个全新的网络响应
    
    // The rule of thumb for using share(replay:, scope:) is to use it on any
    // sequences you expect to complete; this way you prevent the observable
    // from being re-created. You can also use this if you'd like observers
    // to automatically receive the last n emitted events.
    // 使用 share(replay:, scope:) 的经验法则:
    // 1. 在任何你能预料其完成的 observable 上使用. 这样你能防止 observable 重复创建
    // 2. 在你期望观察者能自动接收最新的 n 个已发送事件时使用
}
