//
//  Profile.swift
//  ProfileApp
//
//  Created by 杉本匠 on 2022/04/24.
//

import Foundation

struct SearchResponse: Codable {
  let items: [Item]
}

struct Item: Codable {
  let snippet: Snippet
}

struct Snippet: Codable {
  let channelId: String
  let channelTitle: String
  let title: String
  let description: String
  let thumbnails: Thumbnail
}

struct Thumbnail: Codable {
  let `default`: ThumbnailURL
  let medium: ThumbnailURL
}

struct ThumbnailURL: Codable {
  let url: URL
}








