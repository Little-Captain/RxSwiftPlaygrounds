import UIKit
import RxSwift
import RxCocoa

// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
    static func make() -> TimelineView<E> {
        let view = TimelineView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        view.setup()
        return view
    }
    public func on(_ event: Event<E>) {
        switch event {
        case .next(let value):
            add(.Next(String(describing: value)))
        case .completed:
            add(.Completed())
        case .error(_):
            add(.Error())
        }
    }
}

let elementsPerSecond = 1
let delayInSeconds = 1.5

let sourceObservable = PublishSubject<Int>()

let sourceTimeline = TimelineView<Int>.make()
let delayedTimeline = TimelineView<Int>.make()

let stack = UIStackView.makeVertical([
  UILabel.makeTitle("delay"),
  UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
  sourceTimeline,
  UILabel.make("Delayed elements (with a \(delayInSeconds)s delay):"),
  delayedTimeline])

var current = 1
let timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
  sourceObservable.onNext(current)
  current = current + 1
}

//: Time-shifting operators
// Delayed subscriptions
// The idea behind the delaySubscription(_:scheduler:) is, as the name implies,
// to delay the time a subscriber starts receiving elements from its subscription.
// 被延迟的订阅
// delaySubscription(_:scheduler:) 的目的是延迟订阅者从订阅中开始接收元素的时间.

// Note: In Rx, some observables are called “cold” while others are “hot”.
// Cold observables start emitting elements when you subscribe to them.
// Hot observables are more like permanent sources you happen to look at
// at some point (think of Notifications). When delaying a subscription,
// it won't make a difference if the observable is cold. If it's hot,
// you may skip elements, as in this example.
// Hot and cold observables are a tricky topic that can take some time
// getting your head around. Remember that cold observables emit events
// only when subscribed to, but hot observables emit events independent
// of being subscribed to.
// 注意: 在 Rx 中, 一些 observable 称为 `cold` 的, 另一些称为 `hot` 的
// cold observable 在你订阅它的时候发出元素
// hot observable 更像是一个永久的源, 一直发出元素, 你可以随时观察它 (就像通知)
// 当延迟一个订阅, 如果是 cold observable, 将没有任何影响
// 当延迟一个订阅, 如果是 hot observable, 你可能会错过一些元素
// 说明: 延迟订阅相当于, 你不是现在订阅, 而是延迟一段时间后才开始订阅
// hot observable 和 cold observable 是需要一些时间来讨论的重要主题.
// 请记住: cold observable 只在订阅时才发出事件, 而 hot observable 会发出独立于订阅的事件

// The other kind of delay in RxSwift lets you time-shift the whole sequence.
// Instead of subscribing late, the operator subscribes immediately to the
// source observable, but delays every emitted element by the specified amount
// of time. The net result is a concrete time-shift.
// 另一个 RxSwift 中的延迟操作让你可以时移整个序列.
// 与延迟订阅不同, 这个操作符立即订阅源 observable, 但是针对每个元素延迟指定的时间后再发送
// 返回网络结果是一个具体时移实例

// Delaying the subscription (with the default settings) made you miss some elements
// from the source observable. When using the delay(_:scheduler:) operator,
// you time-shift the elements and won't miss any. Again, the subscription occurs immediately.
// You simply “see” the items with a delay.
// 延迟订阅(使用默认设置)让你从源 observable 丢失一些元素. 当使用  delay(_:scheduler:) 操作时,
// 你时移每个元素但是不会丢失任何一个. 相对于延迟订阅, 这里订阅立即发生,
// 只是简单的 `看见` 元素被延迟了一个固定时间.

// cold observable
_ = Observable.from([1, 2, 3, 4])
    .delaySubscription(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
    .subscribe(onNext: { print($0) })

_ = sourceObservable.subscribe(sourceTimeline)

// Setup the delayed subscription
// hot observable
//_ = sourceObservable
////    .delaySubscription(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
//    .delay(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
//    .subscribe(delayedTimeline)

// You may want a more powerful timer observable. You can use the
// Observable.timer(_:period:scheduler:) operator which is very much like
// Observable.interval(_:scheduler:) but adds the following features:
// • You can specify a “due date” as the time that elapsed between
//   the point of subscription and the first emitted value.
// • The repeat period is optional. If you don't specify one,
//   the timer observable will emit once, then complete.
// 你可能想要一个更强大的 timer observable.
// 你可以使用 Observable.timer(_:period:scheduler:) 操作符, 它与
// Observable.interval(_:scheduler:) 非常相似, 但是添加了一下特性:
// 1. 你可以指定一个 `dueTime` 用于确定订阅与第一个元素发出的时间间隔
// 2. 重复周期时间 `period` 是可选的. 如果你没有指定, timer observable
//    只会发出一个元素, 然后完成.

// There are several benefits to using this over Dispatch:
// • The whole chain is more readable (more “Rx-y”).
// • Since the subscription returns a disposable, you can cancel at any point
//   before the first or second timer triggers with a single observable.
// • Using the flatMap(_:) operator, you can produce timer sequences without
//   having to jump through hoops with Dispatch asynchronous closures.
// 使用 Observable.timer(_:period:scheduler:) 替换 Dispatch 的好处有:
// 1. 整个调用链更具可读性
// 2. 因为订阅返回了一个 disposable, 你可以在订阅返回 disposable 后轻松取消它
// 3. 使用 flatMap(_:) 操作符, 你可以在不使用 Dispatch 异步闭包嵌套的情况下,
//    轻松产生时钟序列


_ = Observable<Int>
    .timer(3, scheduler: MainScheduler.instance)
    .flatMap { _ in
        sourceObservable
            .delay(RxTimeInterval(delayInSeconds),
                   scheduler: MainScheduler.instance)
    }
    .subscribe(delayedTimeline)

let hostView = setupHostView()
hostView.addSubview(stack)
hostView
