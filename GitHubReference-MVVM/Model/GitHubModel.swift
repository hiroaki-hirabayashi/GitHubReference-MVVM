//
//  GitHubModel.swift
//  GitHubReference-MVVM
//
//  Created by Hiroaki-Hirabayashi on 2021/11/30.
//

import Foundation

struct GitHubModel: Codable {
    let name: String
    private let fullName: String
    var urlString: String { "https://github.com/\(fullName)" }

    enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
    }
}

struct GitHubResponse: Codable {
    let items: [GitHubModel]?
}
