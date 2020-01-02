/**
 *  Dictionary++.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

extension Dictionary where Key: ExpressibleByStringLiteral, Value: ExpressibleByStringLiteral {

    var urlencoded: String {
        let params: [String] = self.mapValues { String(describing: $0) }.mapValues {
            $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }.map { "\($0)=\($1)" }

        return params.reduce(into: "") { result, value in
            if result == "" {
                result = value
            } else {
                result.append("&\(value)")
            }
        }
    }

}

extension Dictionary where Key == StringLiteralType {

    func multipartData(boundary: String) -> Data {
        let body = NSMutableData()

        let boundaryPrefix = "--\(boundary)\r\n"

        self.forEach { key, value in
            body.appendString(boundaryPrefix)

            switch value {
            case let data as Data:
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"media\"\r\n")
                body.appendString("Content-Type: application/octet-stream\r\n\r\n")
                body.append(data)
                body.appendString("\r\n")
            case let string as String:
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(string)\r\n")
            case let value as Any:
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(String(describing: value))\r\n")
            default:
                break
            }
        }

        body.appendString("--\(boundary)--")

        return body as Data
    }

}

extension NSMutableData {

    func appendString(_ string: String) {
        let data = string.data(using: .utf8, allowLossyConversion: false)
        self.append(data!)
    }

}
