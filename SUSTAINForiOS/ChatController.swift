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
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMessage = Message(content: trimmed, isUser: true)
        DispatchQueue.main.async {
            self.messages.append(userMessage)
        }
        getBotReply(from: trimmed)
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

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Request failed: \(error.localizedDescription)")
                self.appendBotMessage("Sorry, the request failed. Please check your connection and try again.")
                return
            }

            guard let data = data else {
                print("❌ No response data")
                self.appendBotMessage("Sorry, no response was received. Please try again.")
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
                self.appendBotMessage("Sorry, something went wrong reading the response. Please try again.")
            }
        }.resume()
    }

    private func appendBotMessage(_ content: String) {
        DispatchQueue.main.async {
            self.messages.append(Message(content: content, isUser: false))
        }
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
