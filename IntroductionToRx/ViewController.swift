//
//  ViewController.swift
//  IntroductionToRx
//
//  Created by Diego Perini on 9.10.2018.
//  Copyright © 2018 Diego Perini. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class ViewController: UIViewController {
    let loginButton = UIButton()
    let usernameText = UITextView()
    let passText = UITextView()
    var disposeBag: DisposeBag = DisposeBag()
    
    
    override func viewWillAppear(_ animated: Bool) {
        //        arrayExample()
        //        observableExample()
        //
        //        coldObservableCreate()
        //        hotObservableCreate()
        
        //        incorrectHttpCallChaining()
        correctHttpCallChaining()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }
    
    func arrayExample() {
        let myArray = [1, 2, 3]
        let transformation = myArray.map { e -> Int in
            print("Map: ", e)
            return e * 2
        }
        let filtered = transformation.filter { e -> Bool in
            print("Filter: ", e)
            return e > 2
        }
        
        filtered.forEach { e in
            print("Result: ", e)
        }
        print("Done!")
    }
    
    func observableExample() {
        let myObservable = Observable.of(1, 2, 3) // or Observable.from([1, 2, 3])
        let transformation = myObservable.map { e -> Int in
            print("Map: ", e)
            return e * 2
        }
        let filtered = transformation.filter { e -> Bool in
            print("Filter: ", e)
            return e > 2
        }
        
        _ = filtered.subscribe(
            onNext: { e in
                print("Result: ", e)
        },
            onError: { err in
                print(err)
        },
            onCompleted: {
                print("Done!")
        },
            onDisposed: {
                print("Garbage collected!")
        }
        )
    }
    
    func coldObservableCreate() {
        let httpCallObservable:Observable<Any> = Observable<Any>.create { sub in
            Alamofire.request("https://httpbin.org/get")
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        sub.onNext(response.result.value!)
                        sub.onCompleted()
                    case .failure(let error):
                        sub.onError(error)
                    }
            }
            
            return Disposables.create()
        }
        
        _ = httpCallObservable.subscribe(
            onNext: { data in print(data) },
            onError: { error in print(error) },
            onCompleted: nil,
            onDisposed: nil
        )
    }
    
    func hotObservableCreate() {
        let screenshotNotification = NotificationCenter.default.rx.notification(NSNotification.Name.UIApplicationUserDidTakeScreenshot)
        
        _ = screenshotNotification.subscribe(
            onNext: { notification in print(notification) },
            onError: { error in print(error) },
            onCompleted: { print("this is never called") },
            onDisposed: nil
        )
    }
    
    func incorrectHttpCallChaining() {
        httpPostRx(url: "https://httpbin.org/get?call=login", body: [ "user": "example", "pass": "123456" ])
            .subscribe(
                onNext: { _ in
                    _ = httpGetRx(url: "https://httpbin.org/get?call=getProfile").subscribe(
                        onNext: { profile in
                           // show profile
                        },
                        onError: { e in
                            // show error
                        },
                        onCompleted: nil,
                        onDisposed: nil
                    )
                },
                onError: { e in
                    // show error
                },
                onCompleted: nil,
                onDisposed: nil
            )
            .disposed(by: disposeBag)
        
    }
    
    func correctHttpCallChaining() {
        loginButton.rx.controlEvent(.touchUpInside)
            .flatMap { _ in
                return httpPostRx(url: "https://httpbin.org/get?call=login", body: [ "user": self.usernameText.text, "pass": self.passText.text ])
            }
            .flatMap { l in
                return httpGetRx(url: "https://httpbin.org/get?call=getProfile")
                    .map { p in
                        return (login: l, profile: p)
                    }
            }
            .flatMap { lp in
                return httpGetRx(url: "https://httpbin.org/get?call=getNotifications")
                    .map { n in
                        return (login: lp.login, profile: lp.profile, notifications: n)
                    }
            }
            .flatMap { lpn in
                return httpGetRx(url: "https://httpbin.org/get?call=getSettings")
                    .map { s in
                        return (login: lpn.login, profile: lpn.profile, notifications: lpn.notifications, settings: s)
                    }
            }
            .subscribe(
                onNext: { lpns in
                    print(lpns.login)
                    print(lpns.profile)
                    print(lpns.notifications)
                    print(lpns.settings)
                    // show everything
                },
                onError: { e in
                    // show error
                },
                onCompleted: nil,
                onDisposed: nil
            )
            .disposed(by: disposeBag)
    }
}

func httpGetRx(url: String) -> Observable<Any> {
    return Observable<Any>.create { sub in
        Alamofire.request(url)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success:
                    sub.onNext(response.result.value!)
                    sub.onCompleted()
                case .failure(let error):
                    sub.onError(error)
                }
        }
        
        return Disposables.create()
    }
}

func httpPostRx(url: String, body: [String: Any]) -> Observable<Any> {
    return Observable<Any>.create { sub in
        Alamofire.request(url, method: .post, parameters: body)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success:
                    sub.onNext(response.result.value!)
                    sub.onCompleted()
                case .failure(let error):
                    sub.onError(error)
                }
        }
        
        return Disposables.create()
    }
}
