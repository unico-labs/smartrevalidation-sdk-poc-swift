import UIKit
import AVFoundation
import AcessoBio

/// Espelho do MainActivity.kt do app Android (unico-sdk-poc-kotlin): teste ponta a ponta do
/// SilentAuth (UnicoSDK.startSilentValidation + POST /processes/v1 com o mesmo externalUserId).
final class ViewController: UIViewController {

    // MARK: - Credenciais (placeholders, mesmos do UnicoConfig.kt / MainActivity.kt)

    // A SDK Key fica em SDKConfig.sdkKey (equivalente ao UnicoConfig.kt).
    private let silentAuthApiKey = ""
    private let selfieApiKey = ""

    private let timeout: Double = 50.0

    private var manager: AcessoBioManager?

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let mainTextLabel = UILabel()
    private let externalUserIdField = UITextField()
    private let subjectCodeField = UITextField()
    private let subjectNameField = UITextField()
    private let bearerTokenField = UITextField()
    private let logTextView = UITextView()

    private static let logPlaceholder = "Logs aparecerão aqui..."

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Teclado

    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = view.convert(frame, from: nil).height
        scrollView.contentInset.bottom = keyboardHeight + 12
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    // MARK: - Construção da tela

    private func setupUI() {
        view.backgroundColor = UIColor(hex: 0xF3F5FA)

        let headerView = makeHeader()
        let mainCard = makeMainCard()

        mainCard.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.addSubview(mainCard)

        let logCard = makeLogCard()

        view.addSubview(headerView)
        view.addSubview(scrollView)
        view.addSubview(logCard)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: logCard.topAnchor, constant: -4),

            mainCard.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            mainCard.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            mainCard.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            mainCard.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -8),
            mainCard.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),

            logCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logCard.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            logCard.heightAnchor.constraint(equalToConstant: 170),
        ])
    }

    private func makeHeader() -> UIView {
        let logo = UIImageView(image: UIImage(named: "unicologo"))
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.heightAnchor.constraint(equalToConstant: 31).isActive = true

        let subtitle = UILabel()
        subtitle.text = "SilentAuth · SDK iOS POC"
        subtitle.font = .systemFont(ofSize: 13)
        subtitle.textColor = UIColor(hex: 0x4C8CFF)
        subtitle.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [logo, subtitle])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.backgroundColor = UIColor(hex: 0x0B1B33)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18),
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
        ])
        return container
    }

    private func makeMainCard() -> UIView {
        let title = makeCardTitle("Teste de autenticação silenciosa")

        mainTextLabel.text = "Pronto para iniciar"
        mainTextLabel.font = .systemFont(ofSize: 13)
        mainTextLabel.textColor = UIColor(hex: 0x6B7280)
        mainTextLabel.numberOfLines = 0

        configureField(externalUserIdField, placeholder: "externalUserId (CPF/e-mail/ID do usuário)")
        configureField(subjectCodeField, placeholder: "subject.code (CPF)", defaultText: "12345678901", keyboardType: .numberPad)
        configureField(subjectNameField, placeholder: "subject.name", defaultText: "John Doe")
        configureField(bearerTokenField, placeholder: "Bearer token (colar manualmente)", isSecure: true)

        let selfieButton = makeButton(title: "Criar processo com Selfie", backgroundColor: .clear, titleColor: UIColor(hex: 0x0057FF), bordered: true)
        selfieButton.addTarget(self, action: #selector(openCameraLiveness), for: .touchUpInside)

        let silentAuthButton = makeButton(title: "Testar SilentAuth", backgroundColor: UIColor(hex: 0x0057FF), titleColor: .white)
        silentAuthButton.addTarget(self, action: #selector(openSilentAuthTest), for: .touchUpInside)

        return makeCard(subviews: [
            title, mainTextLabel,
            externalUserIdField, subjectCodeField, subjectNameField, bearerTokenField,
            selfieButton, silentAuthButton,
        ])
    }

    private func makeLogCard() -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(hex: 0x0B1B33)
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false

        let logTitle = UILabel()
        logTitle.text = "Logs"
        logTitle.textColor = .white
        logTitle.font = .boldSystemFont(ofSize: 13)

        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Limpar", for: .normal)
        clearButton.setTitleColor(UIColor(hex: 0x4C8CFF), for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 13)
        clearButton.addTarget(self, action: #selector(clearLogTapped), for: .touchUpInside)

        let headerRow = UIStackView(arrangedSubviews: [logTitle, clearButton])
        headerRow.axis = .horizontal
        headerRow.distribution = .equalSpacing
        headerRow.alignment = .center

        logTextView.text = Self.logPlaceholder
        logTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.textColor = UIColor(hex: 0xD7E3FF)
        logTextView.backgroundColor = .clear
        logTextView.isEditable = false
        logTextView.textContainerInset = .zero

        let stack = UIStackView(arrangedSubviews: [headerRow, logTextView])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])
        return card
    }

    // MARK: - Helpers de UI

    private func makeCard(subviews: [UIView]) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(hex: 0xE1E5EE).cgColor

        let stack = UIStackView(arrangedSubviews: subviews)
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        // Título + texto de status ficam juntos e separados dos campos, como no layout Android.
        if subviews.count > 1 {
            stack.setCustomSpacing(2, after: subviews[0])
            stack.setCustomSpacing(18, after: subviews[1])
        }

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
        ])
        return card
    }

    private func makeCardTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = UIColor(hex: 0x1A1F36)
        label.numberOfLines = 0
        return label
    }

    private func configureField(
        _ field: UITextField,
        placeholder: String,
        defaultText: String? = nil,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        field.placeholder = placeholder
        field.text = defaultText
        field.isSecureTextEntry = isSecure
        field.keyboardType = keyboardType
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    private func makeButton(title: String, backgroundColor: UIColor, titleColor: UIColor, bordered: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = titleColor
        config.cornerStyle = .medium
        if bordered {
            config.background.strokeColor = UIColor(hex: 0x0057FF)
            config.background.strokeWidth = 1
        }
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }

    private func setMainText(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.mainTextLabel.text = text
        }
    }

    private func showToast(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self?.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                alert.dismiss(animated: true)
            }
        }
    }

    // MARK: - Log

    private func addLog(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.logTextView.text += "\n\(message)"
            let bottom = NSRange(location: (self.logTextView.text as NSString).length - 1, length: 1)
            self.logTextView.scrollRangeToVisible(bottom)
        }
        print("MainActivity: \(message)")
    }

    @objc private func clearLogTapped() {
        logTextView.text = ""
        addLog("Log limpo.")
    }

    // MARK: - Ações dos botões

    @objc private func openCameraLiveness() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCameraLiveness()
        case .notDetermined:
            addLog("Solicitando permissão de câmera...")
            requestCameraPermission()
        default:
            handleCameraPermissionDenied()
        }
    }

    @objc private func openSilentAuthTest() {
        let externalUserId = externalUserIdField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !externalUserId.isEmpty else {
            addLog("Erro: informe um externalUserId antes de testar o SilentAuth.")
            showToast("Informe o externalUserId")
            return
        }

        addLog("Iniciando teste SilentAuth. externalUserId=\(externalUserId)")

        // A validação silenciosa não abre câmera nem pede permissão. Só em caso de sucesso o
        // processo é criado (apiKey do SilentAuth); em erro nada mais é disparado — nem a
        // captura de biometria, nem o processo com a apiKey da selfie.
        UnicoSDK.startSilentValidation(prepareInfo: PrepareInfo(externalUserId: externalUserId, useCase: nil)) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.addLog("SilentAuth sucesso.")
                self.createProcess(apiKey: self.silentAuthApiKey, externalUserId: externalUserId)
            case .failure(let error):
                self.addLog("SilentAuth erro: \(error.desc)")
            }
        }
    }

    // MARK: - Permissão de câmera

    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }
                if granted {
                    self.addLog("Permissão da câmera concedida.")
                    self.startCameraLiveness()
                } else {
                    self.handleCameraPermissionDenied()
                }
            }
        }
    }

    private func handleCameraPermissionDenied() {
        addLog("Permissão da câmera negada pelo usuário.")
        showToast("Permissão da câmera é obrigatória para continuar.")
    }

    // MARK: - SDK

    private func makeManager() -> AcessoBioManager? {
        let manager = AcessoBioManager(viewController: self)
        manager?.setTheme(SampleAppThemes())
        manager?.setTimeoutSession(timeout)
        manager?.setEnvironment(.UAT)
        self.manager = manager
        return manager
    }

    private func startCameraLiveness() {
        addLog("Permissão de câmera concedida. Iniciando SDK Liveness.")
        makeManager()?.build().prepareSelfieCamera(self, config: SDKConfig())
    }

    // MARK: - CreateProcess (HTTP)

    private func createProcess(apiKey: String, externalUserId: String? = nil, imageBase64: String? = nil) {
        let subjectCode = subjectCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let subjectName = subjectNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let bearerToken = bearerTokenField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !bearerToken.isEmpty else {
            addLog("Erro: preencha o Bearer Token antes de criar o processo.")
            return
        }

        if let externalUserId {
            addLog("CreateProcess -> externalUserId=\"\(externalUserId)\" (len=\(externalUserId.count))")
        }
        addLog("Disparando CreateProcess...")

        var body: [String: Any] = ["subject": ["code": subjectCode, "name": subjectName]]
        if let externalUserId { body["externalUserId"] = externalUserId }
        if let imageBase64 { body["imageBase64"] = imageBase64 }

        // O imageBase64 (JWT da selfie) é enorme; no log aparece só o tamanho.
        var bodyForLog = body
        if let imageBase64 { bodyForLog["imageBase64"] = "<omitido, \(imageBase64.count) chars>" }
        if let logData = try? JSONSerialization.data(withJSONObject: bodyForLog),
           let logString = String(data: logData, encoding: .utf8) {
            addLog("POST /processes/v1 body: \(logString)")
        }

        guard let url = URL(string: "https://api.id.uat.unico.app/processes/v1") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "APIKEY")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error {
                self?.addLog("Erro ao chamar CreateProcess: \(error.localizedDescription)")
                return
            }
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let responseBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            self?.addLog("CreateProcess -> HTTP \(statusCode): \(responseBody)")
            self?.handleProcessResponse(statusCode: statusCode, responseBody: responseBody)
        }.resume()
    }

    /// Interpreta a resposta do CreateProcess.
    /// - silentAuth "no": fallback de biometria — abre a câmera de selfie (o processo é criado
    ///   com a apiKey da selfie e o encrypted no onSuccessSelfie). Sem modal: o fluxo continua.
    /// - Demais casos (silentAuth yes/inconclusive, unicoId da selfie, erro): fim do fluxo,
    ///   exibe o modal com o resultado tratado e o ID do processo.
    private func handleProcessResponse(statusCode: Int, responseBody: String) {
        guard let data = responseBody.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            if !(200...299).contains(statusCode) {
                showResultModal(ProcessOutcome(kind: .error, title: "Não foi possível criar o processo",
                                               message: "HTTP \(statusCode)", processId: nil))
            }
            return
        }
        let processId = json["id"] as? String

        if let error = json["error"] as? [String: Any] {
            let description = error["description"] as? String ?? "Erro desconhecido."
            showResultModal(ProcessOutcome(kind: .error, title: "Não foi possível criar o processo",
                                           message: description, processId: processId))
            return
        }
        guard (200...299).contains(statusCode) else {
            showResultModal(ProcessOutcome(kind: .error, title: "Não foi possível criar o processo",
                                           message: "HTTP \(statusCode)", processId: processId))
            return
        }

        if let silentAuth = json["silentAuth"] as? [String: Any], let result = silentAuth["result"] as? String {
            addLog("SilentAuth resultado: \(result)")
            switch result.lowercased() {
            case "no":
                addLog("SilentAuth retornou \"no\". Abrindo câmera para captura de selfie...")
                setMainText("SilentAuth: não validado. Capture a selfie.")
                DispatchQueue.main.async { [weak self] in self?.openCameraLiveness() }
            case "yes":
                showResultModal(ProcessOutcome(kind: .success, title: "Device validado",
                                               message: "O SilentAuth validou este dispositivo silenciosamente, sem precisar de selfie.",
                                               processId: processId))
            case "inconclusive":
                showResultModal(ProcessOutcome(kind: .warning, title: "Validação inconclusiva",
                                               message: "Não foi possível determinar a validação silenciosa deste dispositivo.",
                                               processId: processId))
            default:
                showResultModal(ProcessOutcome(kind: .warning, title: "Resultado não reconhecido",
                                               message: "SilentAuth retornou \"\(result)\".", processId: processId))
            }
            return
        }

        // Processo criado com selfie: verificação de identidade (unicoId yes/no/inconclusive).
        if let unicoId = json["unicoId"] as? [String: Any], let result = unicoId["result"] as? String {
            switch result.lowercased() {
            case "yes":
                showResultModal(ProcessOutcome(kind: .success, title: "Identidade confirmada",
                                               message: "O rosto capturado corresponde à pessoa informada.", processId: processId))
            case "no":
                showResultModal(ProcessOutcome(kind: .failure, title: "Identidade não confirmada",
                                               message: "O rosto capturado não corresponde à pessoa informada.", processId: processId))
            case "inconclusive":
                showResultModal(ProcessOutcome(kind: .warning, title: "Identidade inconclusiva",
                                               message: "Não foi possível determinar se o rosto corresponde à pessoa informada.",
                                               processId: processId))
            default:
                showResultModal(ProcessOutcome(kind: .warning, title: "Resultado não reconhecido",
                                               message: "unicoId retornou \"\(result)\".", processId: processId))
            }
        } else if let liveness = json["liveness"] as? Int, liveness == 2 {
            showResultModal(ProcessOutcome(kind: .failure, title: "Prova de vida não aprovada",
                                           message: "A captura não foi reconhecida como uma pessoa real.", processId: processId))
        }
    }

    private func showResultModal(_ outcome: ProcessOutcome) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let modal = ResultModalViewController(outcome: outcome)
            let presenter = self.presentedViewController ?? self
            presenter.present(modal, animated: true)
        }
    }
}

// MARK: - Modal de resultado

private struct ProcessOutcome {
    enum Kind { case success, failure, warning, error }
    let kind: Kind
    let title: String
    let message: String
    let processId: String?
}

private final class ResultModalViewController: UIViewController {

    private let outcome: ProcessOutcome

    init(outcome: ProcessOutcome) {
        self.outcome = outcome
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private var accent: (color: UIColor, symbol: String) {
        switch outcome.kind {
        case .success: return (UIColor(hex: 0x16A34A), "checkmark")
        case .failure, .error: return (UIColor(hex: 0xDC2626), "xmark")
        case .warning: return (UIColor(hex: 0xD97706), "exclamationmark")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 24
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.25
        card.layer.shadowRadius = 24
        card.layer.shadowOffset = CGSize(width: 0, height: 8)
        card.translatesAutoresizingMaskIntoConstraints = false

        let badge = UIView()
        badge.backgroundColor = accent.color.withAlphaComponent(0.14)
        badge.layer.cornerRadius = 32
        badge.translatesAutoresizingMaskIntoConstraints = false
        let icon = UIImageView(image: UIImage(systemName: accent.symbol,
                                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)))
        icon.tintColor = accent.color
        icon.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(icon)
        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(equalToConstant: 64),
            badge.heightAnchor.constraint(equalToConstant: 64),
            icon.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
        ])

        let title = UILabel()
        title.text = outcome.title
        title.font = .boldSystemFont(ofSize: 20)
        title.textColor = UIColor(hex: 0x1A1F36)
        title.textAlignment = .center
        title.numberOfLines = 0

        let message = UILabel()
        message.text = outcome.message
        message.font = .systemFont(ofSize: 14)
        message.textColor = UIColor(hex: 0x6B7280)
        message.textAlignment = .center
        message.numberOfLines = 0

        // Container para o badge ficar centralizado em vez de esticar na stack (alignment .fill).
        let badgeRow = UIView()
        badgeRow.addSubview(badge)
        NSLayoutConstraint.activate([
            badge.topAnchor.constraint(equalTo: badgeRow.topAnchor),
            badge.bottomAnchor.constraint(equalTo: badgeRow.bottomAnchor),
            badge.centerXAnchor.constraint(equalTo: badgeRow.centerXAnchor),
        ])

        var arranged: [UIView] = [badgeRow, title, message]

        if let processId = outcome.processId {
            let idCaption = UILabel()
            idCaption.text = "ID DO PROCESSO"
            idCaption.font = .systemFont(ofSize: 11, weight: .semibold)
            idCaption.textColor = UIColor(hex: 0x6B7280)
            idCaption.textAlignment = .center

            let idLabel = UILabel()
            idLabel.text = processId
            idLabel.font = .monospacedSystemFont(ofSize: 13, weight: .medium)
            idLabel.textColor = UIColor(hex: 0x1A1F36)
            idLabel.textAlignment = .center
            idLabel.numberOfLines = 0

            let copyButton = UIButton(type: .system)
            copyButton.setTitle("Copiar ID", for: .normal)
            copyButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            copyButton.setTitleColor(UIColor(hex: 0x0057FF), for: .normal)
            copyButton.addAction(UIAction { [weak copyButton] _ in
                UIPasteboard.general.string = processId
                copyButton?.setTitle("Copiado ✓", for: .normal)
            }, for: .touchUpInside)

            let idStack = UIStackView(arrangedSubviews: [idCaption, idLabel, copyButton])
            idStack.axis = .vertical
            idStack.spacing = 4
            idStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 6, right: 12)
            idStack.isLayoutMarginsRelativeArrangement = true
            idStack.backgroundColor = UIColor(hex: 0xF3F5FA)
            idStack.layer.cornerRadius = 12
            arranged.append(idStack)
        }

        var closeConfig = UIButton.Configuration.filled()
        closeConfig.title = "Fechar"
        closeConfig.baseBackgroundColor = UIColor(hex: 0x0B1B33)
        closeConfig.baseForegroundColor = .white
        closeConfig.cornerStyle = .medium
        let close = UIButton(configuration: closeConfig)
        close.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        close.heightAnchor.constraint(equalToConstant: 48).isActive = true
        arranged.append(close)

        let stack = UIStackView(arrangedSubviews: arranged)
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.setCustomSpacing(16, after: badgeRow)
        stack.setCustomSpacing(20, after: arranged[arranged.count - 2])
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)
        view.addSubview(card)
        NSLayoutConstraint.activate([
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22),
        ])
    }
}

// MARK: - AcessoBioManagerDelegate

extension ViewController: AcessoBioManagerDelegate {
    func onErrorAcessoBioManager(_ error: ErrorBio!) {
        addLog("Erro AcessoBio: \(error?.desc ?? "-")")
        setMainText(error?.desc ?? "-")
    }

    func onUserClosedCameraManually() {
        addLog("Usuário fechou a câmera manualmente.")
        setMainText("Camera fechada manualmente.")
    }

    func onSystemClosedCameraTimeoutSession() {
        addLog("Sessão encerrada por timeout.")
        setMainText("Tempo de sessão excedido.")
    }

    func onSystemChangedTypeCameraTimeoutFaceInference() {
        addLog("Timeout de inferência de face.")
        setMainText("Tempo de inferência excedido.")
    }
}

// MARK: - SelfieCameraDelegate

extension ViewController: SelfieCameraDelegate {
    func onCameraReady(_ cameraOpener: AcessoBioCameraOpenerDelegate!) {
        addLog("Camera pronta.")
        cameraOpener.open(self)
    }

    func onCameraFailed(_ message: ErrorPrepare!) {
        addLog("Falha na câmera: \(message?.desc ?? "-")")
        setMainText(message?.desc ?? "-")
    }
}

// MARK: - AcessoBioSelfieDelegate

extension ViewController: AcessoBioSelfieDelegate {
    func onSuccessSelfie(_ result: SelfieResult!) {
        addLog("Selfie capturada com sucesso.")
        setMainText("Selfie capturada com sucesso.")

        print("MainActivity: JWT COMPLETO DA SELFIE: \(result?.encrypted ?? "")")

        if let encrypted = result?.encrypted {
            addLog("Criando processo com selfie (imageBase64)...")
            createProcess(apiKey: selfieApiKey, imageBase64: encrypted)
        }
    }

    func onErrorSelfie(_ errorBio: ErrorBio!) {
        addLog("Erro na selfie: \(errorBio?.desc ?? "-")")
        setMainText(errorBio?.desc ?? "-")
    }

    func onSuccess(_ successResult: SuccessResult!) {
        addLog("Processo finalizado com sucesso.")
        setMainText("Processo finalizado com sucesso.")

        addLog("ProcessId: \(successResult?.processId ?? "-")")
        print("MainActivity: PROCESS ID: \(successResult?.processId ?? "-")")
    }
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIColor hex helper

private extension UIColor {
    convenience init(hex: Int) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
