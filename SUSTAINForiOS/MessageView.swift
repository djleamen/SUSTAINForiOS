//
//  MessageView.swift
//  SUSTAINForiOS
//
//  Created by klein cafa on 2025-02-20.
//

import SwiftUI

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
        .padding(.horizontal)
    }
}

// ✅ SwiftUI Preview for quick UI testing
#Preview {
    MessageView(message: Message(content: "Hello, this is a test message!", isUser: true))
}
