//
//  ContentView.swift
//  SUSTAINForiOS
//
//  Created by klein cafa on 2025-02-18.
//

import SwiftUI

struct ContentView: View {
    @StateObject var chatController = ChatController()  // ✅ Use ChatController
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

//struct MessageView: View {
//    var message: Message
//
//    var body: some View {
//        Group {
//            if message.isUser {
//                HStack {
//                    Spacer()
//                    Text(message.content)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(Color.white)
//                        .clipShape(Capsule())
//                }
//            } else {
//                HStack {
//                    Text(message.content)
//                        .padding()
//                        .background(Color.black)
//                        .foregroundColor(Color.white)
//                        .clipShape(Capsule())
//                    Spacer()
//                }
//            }
//        }
//        .padding(.horizontal)
//    }
//}

#Preview {
    ContentView()
}
