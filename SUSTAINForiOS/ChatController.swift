//
//  ChatController.swift
//  SUSTAINForiOS
//
//  Created by klein cafa on 2025-02-20.
//

import Foundation

class ChatController: ObservableObject {
    @Published var messages: [Message] = []
    
    // ✅ Replace with your actual API URL
    let apiURL = "https://my-chatbot.sustain-for-ios.workers.dev"

    func sendNewMessage(content: String) {
        let userMessage = Message(content: content, isUser: true)
        DispatchQueue.main.async {
            self.messages.append(userMessage)
        }
        getBotReply(from: content)
    }
    
    private func getBotReply(from message: String) {
        guard let url = URL(string: apiURL) else {
            print("❌ Invalid API URL")
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
            print("❌ Failed to encode request: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request failed: \(error.localizedDescription)")
                return
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
