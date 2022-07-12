//
//  FaviconView.swift
//  
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

import SwiftUI

#if os(iOS)
public typealias FaviconImageType = UIImage
#elseif os(macOS)
public typealias FaviconImageType = NSImage
#endif

public protocol FaviconProvider {

    func image(forDomain domain: String) -> FaviconImageType?

}

public class FaviconProviderModel: ObservableObject {

    let provider: FaviconProvider

    public init(provider: FaviconProvider) {
        self.provider = provider
    }

    func image(forDomain domain: String) -> FaviconImageType {
#if os(iOS)
        let fallback = FaviconImageType(systemName: "globe")
#elseif os(macOS)
        let fallback = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
#endif
        return provider.image(forDomain: domain) ?? fallback!
    }

}

struct FaviconView: View {

    @EnvironmentObject var model: FaviconProviderModel

    let domain: String

    var body: some View {

#if os(iOS)
        let image = Image(uiImage: model.image(forDomain: domain))
#elseif os(macOS)
        let image = Image(nsImage: model.image(forDomain: domain))
#endif

        image.resizable()
            .frame(width: 24, height: 24)

    }

}
