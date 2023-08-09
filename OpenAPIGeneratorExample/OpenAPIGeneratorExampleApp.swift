//
//  OpenAPIGeneratorExampleApp.swift
//  OpenAPIGeneratorExample
//
//  Created by anduser on 30.07.2023.
//

import SwiftUI

@main
struct OpenAPIGeneratorExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ViewModel(state: .release))
        }
    }
}
