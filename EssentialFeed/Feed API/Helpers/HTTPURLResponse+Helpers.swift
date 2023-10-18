//
//  HTTPURLResponse+Helpers.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 18.10.2023.
//

import Foundation

extension HTTPURLResponse {
    var isOK: Bool { statusCode == 200 }
}
