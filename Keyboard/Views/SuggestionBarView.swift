import SwiftUI
import ThemeEngine

struct SuggestionBarView: View {
    let suggestions: [String]
    let theme: KeyboardTheme
    let onTap: (String) -> Void

    var body: some View {
        HStack(spacing: 0) {
            if suggestions.isEmpty {
                Spacer()
            } else {
                ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                    Button(action: { onTap(suggestion) }) {
                        Text(suggestion)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(theme.suggestionTextColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)

                    if index < suggestions.count - 1 {
                        Divider()
                            .frame(height: 20)
                            .foregroundColor(theme.borderColor)
                    }
                }
            }
        }
        .frame(height: 40)
        .background(theme.suggestionBarColor)
    }
}
