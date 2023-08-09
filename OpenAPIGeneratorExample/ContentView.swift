//
//  ContentView.swift
//  OpenAPIGeneratorExample
//
//  Created by anduser on 30.07.2023.
//

import OpenAPIRuntime
import OpenAPIURLSession
import SwiftUI

// MARK: - ContentView

struct ContentView: View {

    // MARK: - Properties

    @StateObject var viewModel: ViewModel

    // MARK: - Body

    var body: some View {
        List {
            ForEach(viewModel.news.news, id: \.self) { item in
                VStack {
                    HStack {
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)

                        VStack(alignment: .leading) {
                            Text(item.title ?? "")
                            Text(item.description ?? "")
                        }
                        .padding()
                    } //: HStack
                } //: VStack
                .padding()
            } //: Repeat
        } //: List
        .onAppear {
            viewModel.fetchNews()
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ViewModel(state: .debug))
    }
}

// MARK: - ViewModel

final class ViewModel: ObservableObject {

    @Published var news: ResponseMo = ResponseMo(news: [])
    let client: APIProtocol
    let apiKey: String = "f556071334fe2d67eff332fe872b384f"

    init(state: ViewModelState) {
        switch state {
        case .debug:
            client = MockClient()

        case .release:
            client = Client(
                serverURL: try! Servers.server1(),
                transport: URLSessionTransport()
            )
        }
    }

    func fetchNews() {
        Task {
            do {
                let response = try await client.everythingGet(Operations.everythingGet.Input(query: .init(access_key: apiKey)))

                switch response {

                case .ok(let data):
                    switch data.body {
                    case .json(let payload):
                        await MainActor.run {
                            news = ResponseMo(news: payload.data)
                        }
                    }

                case .default(statusCode: _, _):
                    break
                }

            } catch {
                // Do nothing
            }
        }
    }
}

struct MockClient: APIProtocol {
    func everythingGet(_ input: Operations.everythingGet.Input) async throws -> Operations.everythingGet.Output {
        return .ok(Operations.everythingGet.Output.Ok(
            body: .json(
                Components.Schemas.NewsList(
                    pagination: .init(
                        limit: 0,
                        offset: 0,
                        count: 0,
                        total: 0
                    ), data: [
                        .init(
                            title: "MockTitle1",
                            description: "Mock Description 1"
                        ),
                        .init(
                            title: "MockTitle2",
                            description: "Mock Description 2"
                        )
                    ]
                )
            )
        ))
    }
}

// MARK: - ResponseMo

struct ResponseMo {
    let news: Components.Schemas.NewsList.dataPayload
}

// MARK: - ViewModelState

enum ViewModelState {
    case debug
    case release
}

// MARK: - News

struct News: Hashable {

    let title: String
    let description: String
}
