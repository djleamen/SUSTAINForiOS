//
//  ContentView.swift
//  SUSTAINForiOS
//
//  Created by klein cafa on 2025-02-18.
//  Edited by DJ Leamen on 2025-08-18.
//

import SwiftUI

struct ContentView: View {
    @StateObject var chatController = ChatController()
    @State private var userInput: String = ""

    var body: some View {
        VStack {
            ScrollView {
                ForEach(chatController.messages) { message in
                    MessageView(message: message)
                        .padding(5)
                }
            }
            Divider()
            HStack {
                TextField("Message...", text: self.$userInput, axis: .vertical)
                    .padding(5)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                Button {
                    self.chatController.sendNewMessage(content: userInput)
                    userInput = ""
                } label: {
                    Image(systemName: "paperplane")
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
