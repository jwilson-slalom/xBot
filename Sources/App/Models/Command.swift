//
//  Command.swift
//  App
//
//  Created by John Welch on 3/1/19.
//

import Foundation
import Vapor

struct Command: Content {

    let command: String
    let response_url: URL?
    let trigger_id: String?
    let text: String?
    
    let team_id: String?
    let team_domain: String?

    let enterprise_id: String?
    let enterprise_name: String?

    let channel_id: String?
    let channel_name: String?

    let user_id: String?
    let user_name: String?
}
