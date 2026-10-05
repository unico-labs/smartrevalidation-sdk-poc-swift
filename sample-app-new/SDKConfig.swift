import Foundation
import AcessoBio

final class SDKConfig: AcessoBioConfigDataSource {

    /// SDK Key (Client API Key) com a capability SilentAuth habilitada.
    static let sdkKey = "YOUR_SDK_KEY"

    private let hostKey: String

    init(hostKey: String = SDKConfig.sdkKey) {
        self.hostKey = hostKey
    }

    func getBundleIdentifier() -> String {
       "com.example.smartrevalidation"
    }

    func getHostKey() -> String {
       hostKey
    }
}
