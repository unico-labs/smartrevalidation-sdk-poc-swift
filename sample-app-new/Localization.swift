import Foundation

/// Localização simples baseada no idioma do sistema (PT/EN/ES), sem depender de
/// Localizable.strings/.lproj — evita precisar registrar novas localizations no
/// projeto Xcode. Mesmas chaves usadas no app Android, para manter os dois em paridade.
enum L {

    private enum Lang {
        case pt, en, es
    }

    private static var current: Lang {
        let code = (Locale.preferredLanguages.first ?? "pt").lowercased()
        if code.hasPrefix("en") { return .en }
        if code.hasPrefix("es") { return .es }
        return .pt
    }

    static func t(_ key: String) -> String {
        let table: [String: String]
        switch current {
        case .pt: table = pt
        case .en: table = en
        case .es: table = es
        }
        return table[key] ?? key
    }

    static func t(_ key: String, _ args: CVarArg...) -> String {
        String(format: t(key), arguments: args)
    }

    private static let pt: [String: String] = [
        "header_subtitle": "Captura de Selfie · SDK iOS POC",
        "card_title_main": "Captura de selfie e criação de processo",
        "main_text_initial": "Pronto para iniciar",
        "hint_subject_code": "subject.code (CPF)",
        "hint_subject_name": "subject.name",
        "hint_bearer_token": "Bearer token (colar manualmente)",
        "hint_use_case": "useCase",
        "sample_use_case": "Teste",
        "card_title_onboarding": "Onboarding",
        "button_onboarding": "Criar processo (Onboarding)",
        "card_title_transacional": "Transacional (Revalidação)",
        "hint_reference_process_id": "referenceProcessId (preenchido após o Onboarding)",
        "button_transacional": "Criar processo (Transacional)",
        "card_title_sdks": "SDKs (webAppToken)",
        "hint_web_app_token": "webAppToken (colar manualmente)",
        "button_sdks": "Criar processo (SDKs)",
        "logs_title": "Logs",
        "action_clear": "Limpar",
        "action_copy": "Copiar",
        "action_close": "Fechar",
        "log_placeholder": "Logs aparecerão aqui...",
        "toast_log_copied": "Log copiado.",
        "toast_result_copied": "Resultado copiado.",
        "toast_camera_permission_required": "Permissão da câmera é obrigatória para continuar.",
        "clipboard_label_result": "Resultado do processo",
        "result_title_success": "Processo criado com sucesso",
        "result_title_error": "Não foi possível criar o processo",
        "result_title_unexpected": "Resposta inesperada",
        "result_label_http": "HTTP %d",
        "result_label_reason": "Motivo",
        "result_error_unknown": "Erro desconhecido.",
        "result_label_error_code": "Código do erro",
        "result_label_process_id": "ID do processo",
        "result_label_status": "Status",
        "result_value_status_done": "Processo concluído",
        "result_value_status_pending": "Processo em andamento / não concluído (código %d)",
        "result_label_liveness": "Prova de vida",
        "result_value_liveness_approved": "Aprovada — pessoa real presente na captura",
        "result_value_liveness_rejected": "Não aprovada — demais verificações podem não ter sido executadas",
        "result_value_unrecognized_int": "Valor não reconhecido (%d)",
        "result_label_risk": "Risco de fraude",
        "result_risk_inconclusive": "Nenhum sinal de risco encontrado",
        "result_risk_high": "Suspeita moderada de fraude",
        "result_risk_critical": "Forte evidência de fraude",
        "result_risk_extreme": "Fraude confirmada",
        "result_value_with_raw": "%@ (%@)",
        "result_value_unrecognized_string": "Valor não reconhecido (%@)",
        "result_label_identity": "Verificação de identidade",
        "result_identity_yes": "Identidade confirmada — o rosto corresponde à pessoa informada",
        "result_identity_no": "Identidade não confirmada — o rosto não corresponde",
        "result_identity_inconclusive": "Não foi possível determinar (similaridade em zona cinza)",
    ]

    private static let en: [String: String] = [
        "header_subtitle": "Selfie Capture · iOS SDK POC",
        "card_title_main": "Selfie capture and process creation",
        "main_text_initial": "Ready to start",
        "hint_subject_code": "subject.code (ID document)",
        "hint_subject_name": "subject.name",
        "hint_bearer_token": "Bearer token (paste manually)",
        "hint_use_case": "useCase",
        "sample_use_case": "Test",
        "card_title_onboarding": "Onboarding",
        "button_onboarding": "Create process (Onboarding)",
        "card_title_transacional": "Transactional (Revalidation)",
        "hint_reference_process_id": "referenceProcessId (filled in after Onboarding)",
        "button_transacional": "Create process (Transactional)",
        "card_title_sdks": "SDKs (webAppToken)",
        "hint_web_app_token": "webAppToken (paste manually)",
        "button_sdks": "Create process (SDKs)",
        "logs_title": "Logs",
        "action_clear": "Clear",
        "action_copy": "Copy",
        "action_close": "Close",
        "log_placeholder": "Logs will appear here...",
        "toast_log_copied": "Log copied.",
        "toast_result_copied": "Result copied.",
        "toast_camera_permission_required": "Camera permission is required to continue.",
        "clipboard_label_result": "Process result",
        "result_title_success": "Process created successfully",
        "result_title_error": "Could not create the process",
        "result_title_unexpected": "Unexpected response",
        "result_label_http": "HTTP %d",
        "result_label_reason": "Reason",
        "result_error_unknown": "Unknown error.",
        "result_label_error_code": "Error code",
        "result_label_process_id": "Process ID",
        "result_label_status": "Status",
        "result_value_status_done": "Process completed",
        "result_value_status_pending": "Process in progress / not completed (code %d)",
        "result_label_liveness": "Liveness check",
        "result_value_liveness_approved": "Approved — a real person was present during capture",
        "result_value_liveness_rejected": "Not approved — further checks may not have run",
        "result_value_unrecognized_int": "Unrecognized value (%d)",
        "result_label_risk": "Fraud risk",
        "result_risk_inconclusive": "No risk signal found",
        "result_risk_high": "Moderate fraud suspicion",
        "result_risk_critical": "Strong evidence of fraud",
        "result_risk_extreme": "Confirmed fraud",
        "result_value_with_raw": "%@ (%@)",
        "result_value_unrecognized_string": "Unrecognized value (%@)",
        "result_label_identity": "Identity verification",
        "result_identity_yes": "Identity confirmed — the face matches the informed person",
        "result_identity_no": "Identity not confirmed — the face does not match",
        "result_identity_inconclusive": "Could not be determined (similarity in a gray zone)",
    ]

    private static let es: [String: String] = [
        "header_subtitle": "Captura de Selfie · POC de SDK iOS",
        "card_title_main": "Captura de selfie y creación de proceso",
        "main_text_initial": "Listo para iniciar",
        "hint_subject_code": "subject.code (documento de identidad)",
        "hint_subject_name": "subject.name",
        "hint_bearer_token": "Bearer token (pegar manualmente)",
        "hint_use_case": "useCase",
        "sample_use_case": "Prueba",
        "card_title_onboarding": "Onboarding",
        "button_onboarding": "Crear proceso (Onboarding)",
        "card_title_transacional": "Transaccional (Revalidación)",
        "hint_reference_process_id": "referenceProcessId (completado después del Onboarding)",
        "button_transacional": "Crear proceso (Transaccional)",
        "card_title_sdks": "SDKs (webAppToken)",
        "hint_web_app_token": "webAppToken (pegar manualmente)",
        "button_sdks": "Crear proceso (SDKs)",
        "logs_title": "Logs",
        "action_clear": "Limpiar",
        "action_copy": "Copiar",
        "action_close": "Cerrar",
        "log_placeholder": "Los registros aparecerán aquí...",
        "toast_log_copied": "Registro copiado.",
        "toast_result_copied": "Resultado copiado.",
        "toast_camera_permission_required": "El permiso de cámara es obligatorio para continuar.",
        "clipboard_label_result": "Resultado del proceso",
        "result_title_success": "Proceso creado con éxito",
        "result_title_error": "No fue posible crear el proceso",
        "result_title_unexpected": "Respuesta inesperada",
        "result_label_http": "HTTP %d",
        "result_label_reason": "Motivo",
        "result_error_unknown": "Error desconocido.",
        "result_label_error_code": "Código de error",
        "result_label_process_id": "ID del proceso",
        "result_label_status": "Estado",
        "result_value_status_done": "Proceso concluido",
        "result_value_status_pending": "Proceso en curso / no concluido (código %d)",
        "result_label_liveness": "Prueba de vida",
        "result_value_liveness_approved": "Aprobada — persona real presente en la captura",
        "result_value_liveness_rejected": "No aprobada — las demás verificaciones pueden no haberse ejecutado",
        "result_value_unrecognized_int": "Valor no reconocido (%d)",
        "result_label_risk": "Riesgo de fraude",
        "result_risk_inconclusive": "No se encontró ninguna señal de riesgo",
        "result_risk_high": "Sospecha moderada de fraude",
        "result_risk_critical": "Fuerte evidencia de fraude",
        "result_risk_extreme": "Fraude confirmado",
        "result_value_with_raw": "%@ (%@)",
        "result_value_unrecognized_string": "Valor no reconocido (%@)",
        "result_label_identity": "Verificación de identidad",
        "result_identity_yes": "Identidad confirmada — el rostro corresponde a la persona indicada",
        "result_identity_no": "Identidad no confirmada — el rostro no corresponde",
        "result_identity_inconclusive": "No fue posible determinar (similitud en zona gris)",
    ]
}
