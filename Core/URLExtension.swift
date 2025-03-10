//
//  URLExtension.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import JavaScriptCore
import BrowserServicesKit

extension URL {

    enum Host: String {
        case localhost
    }

    public func toDesktopUrl() -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        components.host = components.host?.dropping(prefix: "m.")
        components.host = components.host?.dropping(prefix: "mobile.")
        return components.url ?? self
    }

    public func isCustomURLScheme() -> Bool {
        return scheme != nil && !absoluteString.hasPrefix(URLProtocol.http.scheme) && !absoluteString.hasPrefix(URLProtocol.https.scheme)
    }

    public func isBookmarklet() -> Bool {
        return absoluteString.isBookmarklet()
    }

    public func toDecodedBookmarklet() -> String? {
        return absoluteString.toDecodedBookmarklet()
    }
    
    // MARK: static

    public static func webUrl(from text: String) -> URL? {
        guard var url = URL(string: text) else { return nil }

        switch url.scheme {
        case URLProtocol.http.rawValue, URLProtocol.https.rawValue:
            break
        case .none:
            // assume http by default
            guard let urlWithScheme = URL(string: URLProtocol.http.scheme + text),
                  // only allow 2nd+ level domains or "localhost" without scheme
                  urlWithScheme.host?.contains(".") == true || urlWithScheme.host == .localhost
            else { return nil }
            url = urlWithScheme

        default:
            return nil
        }

        guard url.host?.isValidHost == true, url.user == nil else { return nil }

        return url
    }

    public static func decode(query: String) -> String? {
        return query.removingPercentEncoding
    }

    /// Uses JavaScriptCore to determine if the bookmarklet is valid JavaScript
    public static func isValidBookmarklet(url: URL?) -> Bool {
        guard let url = url,
              let bookmarklet = url.toDecodedBookmarklet(),
              let context = JSContext() else { return false }

        context.evaluateScript(bookmarklet)
        if let exception = context.exception {
            // Allow ReferenceErrors since the bookmarklet will likely want to access
            // document or other variables which don't exist in this JSContext.  Consider
            // this bookmarklet invalid for all other exceptions.
            return exception.description.contains("ReferenceError")
        }
        return true
    }
    
    public func isPart(ofDomain domain: String) -> Bool {
        guard let host = host else { return false }
        return host == domain || host.hasSuffix(".\(domain)")
    }

    public func normalized() -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = nil
        components?.fragment = nil

        return components?.url
    }

}
