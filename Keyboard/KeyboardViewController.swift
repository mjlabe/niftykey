import UIKit
import SwiftUI
import SharedModels
import KeyboardCore
import ThemeEngine
import PredictionEngine

final class KeyboardInputView: UIInputView {
    override var safeAreaInsets: UIEdgeInsets {
        return .zero
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        superview?.backgroundColor = backgroundColor
    }
}

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
    private var backgroundView: UIView?
    private var lastShiftTapTime: Date?

    override func loadView() {
        let customInputView = KeyboardInputView(frame: .zero, inputViewStyle: .keyboard)
        customInputView.backgroundColor = loadBackgroundUIColor()
        customInputView.allowsSelfSizing = true
        self.inputView = customInputView
    }
    
    private func loadBackgroundUIColor() -> UIColor {
        let settings = KeyboardSettings.load()
        if let r = settings.customBackgroundColorRed,
           let g = settings.customBackgroundColorGreen,
           let b = settings.customBackgroundColorBlue {
            return UIColor(red: r, green: g, blue: b, alpha: 1.0)
        }
        let isDark = traitCollection.userInterfaceStyle == .dark
        return isDark 
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
            : UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEngines()
        applyCustomColorIfSet()
        
        let bgColor = loadBackgroundUIColor()
        view.backgroundColor = bgColor
        inputView?.backgroundColor = bgColor
        inputView?.superview?.backgroundColor = bgColor
        
        setupUI()
        setupHeightConstraint()
    }
    
    private func applyCustomColorIfSet() {
        let settings = KeyboardSettings.load()
        if let r = settings.customBackgroundColorRed,
           let g = settings.customBackgroundColorGreen,
           let b = settings.customBackgroundColorBlue {
            ThemeProvider.shared.setCustomBackgroundColor(red: r, green: g, blue: b)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        setupBackgroundView()
        
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

    private func setupBackgroundView() {
        let bgView = UIView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = loadBackgroundUIColor()
        view.addSubview(bgView)
        
        // Pin to inputView edges, ignoring safe area
        if let inputView = self.inputView {
            NSLayoutConstraint.activate([
                bgView.leadingAnchor.constraint(equalTo: inputView.leadingAnchor),
                bgView.trailingAnchor.constraint(equalTo: inputView.trailingAnchor),
                bgView.topAnchor.constraint(equalTo: inputView.topAnchor),
                bgView.bottomAnchor.constraint(equalTo: inputView.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                bgView.topAnchor.constraint(equalTo: view.topAnchor),
                bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        self.backgroundView = bgView
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
            let now = Date()
            if let lastTap = lastShiftTapTime,
               now.timeIntervalSince(lastTap) < 0.3 {
                keyboardState.enableCapsLock()
                lastShiftTapTime = nil
            } else {
                keyboardState.toggleShift()
                lastShiftTapTime = now
            }
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
        applyCustomColorIfSet()
        
        let isDark = traitCollection.userInterfaceStyle == .dark
        ThemeProvider.shared.applyTheme(for: isDark ? .dark : .light)
        
        // Update UIKit background to match theme
        let theme = ThemeProvider.shared.currentTheme
        let bgColor = UIColor(theme.backgroundColor)
        view.backgroundColor = bgColor
        inputView?.backgroundColor = bgColor
        inputView?.superview?.backgroundColor = bgColor
        backgroundView?.backgroundColor = bgColor
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
