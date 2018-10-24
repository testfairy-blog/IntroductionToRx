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

    override func viewDidLoad() {
        super.viewDidLoad()

        arrayExample()
        observableExample()
        
        coldObservableCreate()
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
}
