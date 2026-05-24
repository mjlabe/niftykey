import SwiftUI
import ThemeEngine

struct EmojiKeyboardView: View {
    let theme: KeyboardTheme
    let onEmojiTap: (String) -> Void
    let onBackToLetters: () -> Void

    @State private var selectedCategory: Int = 0

    private let categories: [(String, [String])] = [
        ("😀", ["😀","😃","😄","😁","😆","😅","🤣","😂","🙂","😉","😊","😇","🥰","😍","🤩","😘","😗","😚","😋","😛","😜","🤪","😝","🤗","🤔","🤐","😐","😏","😒","🙄","😬","😌","😔","😪","😴","😷","🤒","🤕","🤢","🤮","🥵","🥶","🥴","😵","🤯","😎","🥳","😤","😡","🥺","😢","😭"]),
        ("👋", ["👋","🤚","✋","🖖","👌","🤏","✌️","🤞","🤟","🤘","🤙","👈","👉","👆","👇","👍","👎","✊","👊","🤛","🤜","👏","🙌","👐","🤝","🙏","💪","🦵","🦶","👂","👃","👀","👁️","👅","👄"]),
        ("🐶", ["🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐨","🐯","🦁","🐮","🐷","🐸","🐵","🐔","🐧","🐦","🐤","🦆","🦅","🦉","🦇","🐺","🐗","🐴","🦄","🐝","🐛","🦋","🐌","🐞","🌸","🌺","🌻","🌹","🌿","🍀","🌲","🌳"]),
        ("🍕", ["🍕","🍔","🍟","🌭","🥪","🌮","🌯","🥗","🍝","🍜","🍣","🍱","🍤","🍙","🍚","🍦","🍰","🎂","🍫","🍬","🍭","🍮","☕","🍵","🧃","🥤","🍺","🍷","🥂","🍾"]),
        ("⚽", ["⚽","🏀","🏈","⚾","🎾","🏐","🏉","🎱","🏓","🏸","🥊","🥋","🎯","🎮","🕹️","🎲","🎭","🎨","🎬","🎤","🎧","🎼","🎹","🥁","🎷","🎺","🎸","🎻"]),
        ("🚗", ["✈️","🚗","🚕","🚌","🏎️","🚓","🚑","🚒","🚐","🚚","🚲","🛵","🏍️","🚆","🚇","🚉","🚀","🛸","⛵","🚤","🏠","🏢","🏥","🏫","⛪","🕌","🗽","🗼","🌉","🏖️"]),
        ("💡", ["💡","📱","💻","⌨️","🖥️","📷","📹","📺","📻","⏰","🔋","🔌","💰","💳","📧","📦","🔑","🔒","🔓","❤️","🧡","💛","💚","💙","💜","🖤","🤍","💔","❣️","💕","💖","💗","✨","🔥","💯","✅","❌","⭐","🌟","💫"])
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<categories.count, id: \.self) { i in
                        Button(action: { selectedCategory = i }) {
                            Text(categories[i].0)
                                .font(.system(size: 20))
                                .opacity(selectedCategory == i ? 1.0 : 0.5)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .background(theme.suggestionBarColor)

            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 8),
                    spacing: 8
                ) {
                    ForEach(categories[selectedCategory].1, id: \.self) { emoji in
                        Button(action: { onEmojiTap(emoji) }) {
                            Text(emoji)
                                .font(.system(size: 28))
                                .frame(width: 36, height: 36)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .frame(height: 180)

            HStack {
                Button(action: onBackToLetters) {
                    Text("ABC")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(theme.textColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(theme.specialKeyColor)
                        .cornerRadius(5)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .background(theme.backgroundColor)
    }
}
