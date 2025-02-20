//
//  ContentView.swift
//  SUSTAINForiOS
//
//  Created by klein cafa on 2025-02-18.
//

import SwiftUI

class ChatController: ObservableObject {
    @Published var messages: [Message] = []
    
    // ✅ Replace with your actual Vercel API URL
    let apiURL = "https://my-chatbot.sustain-for-ios.workers.dev"
    
    func sendNewMessage(content: String) {
        let userMessage = Message(content: content, isUser: true)
        self.messages.append(userMessage)
        
        getBotReply(from: content)
    }
    
    private func getBotReply(from message: String) {
        guard let url = URL(string: apiURL) else {
            print("Invalid API URL")
            return
        }

        let messagesArray: [[String: String]] = [["role": "user", "content": message]]
        let requestBody = OpenAIRequest(messages: messagesArray)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("Failed to encode request: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request failed: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("ℹ️ HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No response data")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                DispatchQueue.main.async {
                    if let reply = response.choices.first?.message.content {
                        self.messages.append(Message(content: reply, isUser: false))
                    } else {
                        self.messages.append(Message(content: "No response", isUser: false))
                    }
                }
            } catch {
                print("❌ Failed to decode response: \(error)")
            }
        }.resume()
    }
}

import Foundation

struct OpenAIRequest: Codable {
    let messages: [[String: String]]
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: MessageContent
}

struct MessageContent: Codable {
    let role: String
    let content: String
}

struct Message: Identifiable {
    var id: UUID = .init()
    var content: String
    var isUser: Bool
}

import SwiftUI

struct ContentView: View {
    @StateObject var chatController: ChatController = .init()
    @State var string: String = ""

    var body: some View {
//        ZStack {
//            // Background Image
//            Image("bg") // Make sure the image is inside Assets.xcassets
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea() // Extend to full screen
//            
            // Chat Interface
            VStack {
                ScrollView {
                    ForEach(chatController.messages) { message in
                        MessageView(message: message)
                            .padding(5)
                    }
                }
                Divider()
                HStack {
                    TextField("Message...", text: self.$string, axis: .vertical)
                        .padding(5)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                    Button {
                        self.chatController.sendNewMessage(content: string)
                        string = ""
                    } label: {
                        Image(systemName: "paperplane")
                    }
                }
                .padding()
//            }
//            .padding()
        }
    }
}

struct MessageView: View {
    var message: Message
    var body: some View {
        Group {
            if message.isUser {
                HStack {
                    Spacer()
                    Text(message.content)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .clipShape(Capsule())
                }
            } else {
                HStack {
                    Text(message.content)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(Color.white)
                        .clipShape(Capsule())
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
