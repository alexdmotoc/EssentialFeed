//
//  DebugSceneDelegate.swift
//  EssentialApp
//
//  Created by Alex Motoc on 20.10.2023.
//

#if DEBUG

import Foundation
import UIKit
import EssentialFeed

class DebugSceneDelegate: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: storeURL)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeClient() -> HTTPClient {
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity") {
            return DebugHTTPClient(connectivity: connectivity)
        }
        return super.makeClient()
    }
}

private class DebugHTTPClient: HTTPClient {
    private struct Task: HTTPClientTask {
        func cancel() {}
    }
    
    private let connectivity: String
    
    init(connectivity: String) {
        self.connectivity = connectivity
    }
    
    func get(url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        switch connectivity {
        case "online":
            completion(.success(makeGetResponse(for: url)))
        default:
            completion(.failure(NSError(domain: "debug error", code: 0)))
        }
        return Task()
    }
    
    private func makeGetResponse(for url: URL) -> (HTTPURLResponse, Data) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, makeData(for: url))
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let image = UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            UIColor.red.setFill()
            rendererContext.fill(rect)
        }
        
        return image.pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }
}

#endif
