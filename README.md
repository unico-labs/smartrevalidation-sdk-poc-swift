<p align="center">
  <a href="https://unico.io">
    <img width="350" src="https://unico.io/wp-content/uploads/2024/05/idcloud-horizontal-color.svg">
  </a>
</p>

<h1 align="center">Smart Revalidation (SilentAuth) — SDK iOS POC</h1>

<div align="center">

### POC de teste ponta a ponta da autenticação silenciosa de device (SilentAuth) via SDK iOS, com fallback de selfie

![IOS](https://img.shields.io/badge/iOS-grey?logo=apple)
</div>

---

## 🎯 O que esta POC faz

1. O app chama `UnicoSDK.startSilentValidation(prepareInfo:)` com um `PrepareInfo(externalUserId:)`. A SDK faz a coleta de dados do device **em background** — sem abrir a câmera nem exigir captura do usuário.
2. Em caso de sucesso, o app chama `POST /processes/v1` (apiKey do **SilentAuth**) usando o **mesmo `externalUserId`**, junto com os dados do `subject` (documento/nome).
3. O app lê `silentAuth.result` da resposta:

| Resultado | O que acontece |
| --- | --- |
| `yes` | Fim do fluxo — pop-up "Device validado" com o ID do processo |
| `inconclusive` | Fim do fluxo — pop-up "Validação inconclusiva" com o ID do processo |
| `no` | **Fallback de biometria:** abre a câmera de selfie e, na captura, cria um novo processo (apiKey de **selfie**) enviando o `encrypted` como `imageBase64`. O pop-up final mostra o `unicoId.result` (`yes`/`no`/`inconclusive`) e o ID desse processo |

O botão **"Criar processo com Selfie"** roda só a captura de selfie + criação do processo, de forma independente do SilentAuth.

Os logs de cada etapa aparecem no painel da tela.

> ⚠️ O `externalUserId` usado na validação e no `POST /processes/v1` precisa ser **idêntico, char a char**. Qualquer diferença faz a busca falhar silenciosamente (retorno inconclusivo, sem erro).

---

## 💻 Compatibilidade

- **iOS:** 16.0 ou superior
- **SDK:** `unicocheck-ios` 3.3.0 (CocoaPods)
- **Dispositivo físico** — as SDKs de biometria/device intelligence da Unico não funcionam em simulador.

---

## ⚙️ Configuração antes de rodar

Este repositório **não contém nenhuma credencial real**. Substitua os placeholders:

| Onde | O que trocar |
| --- | --- |
| `SDKConfig.swift` → `getBundleIdentifier()` | Seu bundle identifier registrado na Unico (o mesmo do target no Xcode) |
| `SDKConfig.swift` → `sdkKey` | Sua **SDK Key**, com a capability SilentAuth habilitada |
| `ViewController.swift` → `silentAuthApiKey` | **API Key** com a capability SilentAuth habilitada |
| `ViewController.swift` → `selfieApiKey` | **API Key** usada na criação do processo com selfie |

O **access token (Bearer)** não é hardcoded — cole-o no campo "Bearer token" da tela antes de rodar o teste, já que costuma ter validade curta.

Para gerar as credenciais Unico, consulte a [documentação oficial](https://developer.unico.io/).

---

## 📦 Instalação

```bash
pod install
open sample-app-new.xcworkspace
```

A SDK é inicializada uma vez no `AppDelegate`:

```swift
UnicoSDK.initializeSDK(config: SDKConfig(), environment: .UAT)
```

A permissão de câmera (`NSCameraUsageDescription`) já está configurada no projeto.

---

## ▶️ Como usar

1. Substitua os placeholders da seção [Configuração](#️-configuração-antes-de-rodar) e rode `pod install`.
2. Rode o app em um iPhone físico.
3. Preencha o `externalUserId` (CPF, e-mail ou ID interno) e os dados de `subject`.
4. Cole o **Bearer token** válido.
5. Toque em **"Testar SilentAuth"** e acompanhe o painel de **Logs** e o pop-up de resultado.

---

## 🤔 Dúvidas

Em caso de conflito de biblioteca com a SDK, abra um chamado na plataforma oficial de Suporte da Unico. Para dúvidas gerais de integração, consulte a [documentação oficial](https://developer.unico.io/).
