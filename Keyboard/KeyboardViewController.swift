import UIKit
import SwiftUI
import SharedModels
import KeyboardCore
import ThemeEngine
import PredictionEngine

final class KeyboardViewController: UIInputViewController, TextDocumentProxyProvider {
    
    var documentProxy: UITextDocumentProxy {
        textDocumentProxy
    }

    private var hostingController: UIHostingController<KeyboardRootView>?
    private var keyboardState: KeyboardState!
    private var inputCoordinator: InputCoordinator!
    private var hapticEngine: HapticEngine!
    private var predictionService: PredictionService!
    private var backspaceTimer: BackspaceTimer!
    private var spacebarGesture: SpacebarCursorGesture!
    private var soundEngine: SoundEngine!

    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        inputView?.allowsSelfSizing = true
        inputView?.backgroundColor = .clear
        setupEngines()
        setupUI()
        setupHeightConstraint()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputView?.backgroundColor = .clear
        updateColorScheme()
        updateAutoCapitalization()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        updateAutoCapitalization()
        updatePredictions()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateColorScheme()
    }

    // MARK: - Setup

    private func setupEngines() {
        let settings = KeyboardSettings.load()
        keyboardState = KeyboardState(settings: settings)
        inputCoordinator = InputCoordinator(proxyProvider: self, settings: settings)
        hapticEngine = HapticEngine()
        hapticEngine.isEnabled = settings.hapticFeedbackEnabled
        predictionService = PredictionService()
        soundEngine = SoundEngine()
        soundEngine.isEnabled = settings.soundFeedbackEnabled
        backspaceTimer = BackspaceTimer()
        spacebarGesture = SpacebarCursorGesture()

        backspaceTimer.onDeleteCharacter = { [weak self] in
            self?.inputCoordinator.deleteBackward()
            self?.hapticEngine.deleteTap()
        }
        backspaceTimer.onDeleteWord = { [weak self] in
            self?.inputCoordinator.deleteWord()
            self?.hapticEngine.deleteTap()
        }

        spacebarGesture.onCursorMove = { [weak self] offset in
            self?.inputCoordinator.moveCursor(offset: offset)
            self?.hapticEngine.selectionChanged()
        }
    }

    private func setupUI() {
        var rootView = KeyboardRootView(
            state: keyboardState,
            onKeyTap: { [weak self] key in self?.handleKeyTap(key) },
            onKeyLongPress: { [weak self] key in self?.handleKeyLongPress(key) },
            onKeyRelease: { [weak self] key in self?.handleKeyRelease(key) },
            onSuggestionTap: { [weak self] suggestion in self?.handleSuggestion(suggestion) },
            onSpacebarDragBegan: { [weak self] point in self?.spacebarGesture.began(at: point) },
            onSpacebarDragMoved: { [weak self] point in self?.spacebarGesture.moved(to: point) },
            onSpacebarDragEnded: { [weak self] in self?.spacebarGesture.ended() },
            onNextKeyboard: { [weak self] in self?.advanceToNextInputMode() }
        )
        rootView.onEmojiTap = { [weak self] emoji in
            self?.inputCoordinator.insertCharacter(emoji)
            self?.hapticEngine.keyTap()
        }
        rootView.onAlternateChar = { [weak self] char in
            self?.inputCoordinator.insertCharacter(char)
            self?.hapticEngine.keyTap()
            self?.keyboardState.autoLowercase()
            self?.updatePredictions()
        }

        let hostingVC = UIHostingController(rootView: rootView)
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        hostingVC.view.backgroundColor = .clear
        if #available(iOS 16.0, *) {
            hostingVC.sizingOptions = .intrinsicContentSize
        }
        if #available(iOS 16.4, *) {
            hostingVC.safeAreaRegions = []
        }

        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hostingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        self.hostingController = hostingVC
    }

    // MARK: - Input Handling

    private func handleKeyTap(_ key: KeyDefinition) {
        switch key.type {
        case .character, .number, .special:
            let char = keyboardState.shiftState.isUppercased
                ? key.primary.uppercased()
                : key.primary
            inputCoordinator.insertCharacter(char)
            hapticEngine.keyTap()
            soundEngine.keyClick()
            keyboardState.autoLowercase()
            updatePredictions()

        case .space:
            let inserted = inputCoordinator.insertSpace()
            hapticEngine.keyTap()
            soundEngine.keyClick()
            if inserted {
                updateAutoCapitalization()
            }
            updatePredictions()

        case .backspace:
            inputCoordinator.deleteBackward()
            hapticEngine.deleteTap()
            soundEngine.deleteClick()
            backspaceTimer.start()
            updatePredictions()

        case .returnKey:
            inputCoordinator.insertReturn()
            hapticEngine.keyTap()
            soundEngine.keyClick()
            updateAutoCapitalization()

        case .shift:
            keyboardState.toggleShift()
            hapticEngine.modifierTap()
            soundEngine.modifierClick()

        case .numeric:
            if keyboardState.mode == .letters {
                keyboardState.switchToNumbers()
            } else {
                keyboardState.switchToLetters()
            }
            hapticEngine.modifierTap()

        case .symbols:
            if keyboardState.mode == .symbols {
                keyboardState.switchToNumbers()
            } else {
                keyboardState.switchToSymbols()
            }
            hapticEngine.modifierTap()

        case .emoji:
            keyboardState.switchToEmoji()
            hapticEngine.modifierTap()

        case .globe:
            advanceToNextInputMode()

        case .period:
            inputCoordinator.insertCharacter(".")
            hapticEngine.keyTap()
            keyboardState.autoLowercase()
            updateAutoCapitalization()
            updatePredictions()

        case .comma:
            inputCoordinator.insertCharacter(",")
            hapticEngine.keyTap()
            updatePredictions()
        }
    }

    private func handleKeyLongPress(_ key: KeyDefinition) {
        switch key.type {
        case .shift:
            keyboardState.enableCapsLock()
            hapticEngine.modifierTap()
        case .period:
            hapticEngine.modifierTap()
        case .backspace:
            // Already handled by timer in tap
            break
        default:
            break
        }
    }

    private func handleKeyRelease(_ key: KeyDefinition) {
        switch key.type {
        case .backspace:
            backspaceTimer.stop()
        case .period:
            break
        default:
            break
        }
    }

    private func handleSuggestion(_ suggestion: String) {
        guard let context = inputCoordinator.contextBeforeInput else { return }

        // Find the current word being typed
        let words = context.components(separatedBy: .whitespaces)
        if let currentWord = words.last, !currentWord.isEmpty {
            for _ in 0..<currentWord.count {
                inputCoordinator.deleteBackward()
            }
        }

        inputCoordinator.insertCharacter(suggestion + " ")
        predictionService.reinforceWord(suggestion)
        hapticEngine.keyTap()
        updateAutoCapitalization()
        keyboardState.suggestions = []
    }

    // MARK: - Updates

    private func updateAutoCapitalization() {
        let shouldCap = inputCoordinator.shouldAutoCapitalize()
        keyboardState.setAutoCapitalize(shouldCap)
    }

    private func updatePredictions() {
        guard keyboardState.settings.predictionsEnabled else {
            keyboardState.suggestions = []
            return
        }

        guard let context = inputCoordinator.contextBeforeInput else {
            keyboardState.suggestions = []
            return
        }

        let words = context.components(separatedBy: .whitespaces)
        guard let prefix = words.last, !prefix.isEmpty else {
            keyboardState.suggestions = []
            return
        }

        let predictions = predictionService.predict(prefix: prefix, context: context, limit: 3)
        keyboardState.suggestions = predictions.map { $0.word }
    }

    private func updateColorScheme() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        ThemeProvider.shared.applyTheme(for: isDark ? .dark : .light)
    }

    // MARK: - Height

    private func setupHeightConstraint() {
        guard let inputView = self.inputView else { return }
        let height: CGFloat = keyboardState.showNumberRow ? 300 : 260
        heightConstraint = inputView.heightAnchor.constraint(equalToConstant: height)
        heightConstraint?.priority = .defaultHigh
        heightConstraint?.isActive = true
    }

    private func updateHeight() {
        let height: CGFloat = keyboardState.showNumberRow ? 300 : 260
        heightConstraint?.constant = height
    }
}
