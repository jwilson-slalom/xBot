//
//  Request+SlackSignatureValidation.swift
//  App
//
//  Created by Allen Humphreys on 3/9/19.
//

import Crypto
import Vapor

extension Request {

    func validateSlackRequest(signingSecret: String?) throws -> Bool {
        guard let secret = signingSecret else { return false }
        guard let timestamp = http.headers.firstValue(name: .slackTimestamp) else { return false }
        guard http.contentType == MediaType.urlEncodedForm else { return false }
        guard let bodyString = http.body.data?.convert(to: String.self) else { return false }
        guard let signature = http.headers.firstValue(name: .slackSignature) else { return false }

        let signedPayload = ["v0", timestamp, bodyString].joined(separator: ":")
        let hash = try HMAC.SHA256.authenticate(signedPayload, key: secret).hexEncodedString(uppercase: false)

        return ("v0=" + hash).secureCompare(to: signature)
    }
}
