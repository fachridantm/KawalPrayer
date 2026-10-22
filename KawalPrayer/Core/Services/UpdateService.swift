import Foundation
import Observation
import AppKit

// MARK: - App Release Models

struct AppReleaseInfo: Equatable {
    let version: String
    let tagName: String
    let releaseNotes: String
    let publishedAt: Date?
    let htmlUrl: URL
    let downloadUrl: URL?
    let assetName: String?
}

enum UpdateStatus: Equatable {
    case idle
    case checking
    case updateAvailable(AppReleaseInfo)
    case downloading(progress: Double)
    case readyToInstall(release: AppReleaseInfo, localPath: URL)
    case upToDate
    case error(String)
}

struct GitHubReleasePayload: Decodable {
    let tagName: String
    let name: String?
    let body: String?
    let htmlUrl: String
    let publishedAt: String?
    let assets: [GitHubAssetPayload]

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name
        case body
        case htmlUrl = "html_url"
        case publishedAt = "published_at"
        case assets
    }
}

struct GitHubAssetPayload: Decodable {
    let name: String
    let browserDownloadUrl: String
    let size: Int

    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadUrl = "browser_download_url"
        case size
    }
}

// MARK: - Update Service

@Observable
@MainActor
final class UpdateService: NSObject {

    static let shared = UpdateService()

    var status: UpdateStatus = .idle
    var latestRelease: AppReleaseInfo?

    var isUpdateAvailable: Bool {
        switch status {
        case .updateAvailable, .downloading, .readyToInstall:
            return true
        case .idle, .checking, .upToDate, .error:
            return false
        }
    }

    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var currentBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var displayVersion: String {
        "\(currentVersion) (\(currentBuild))"
    }

    private let repoOwner = "fachridantm"
    private let repoName = "KawalPrayer"

    override init() {
        super.init()
    }

    // MARK: - Version Comparison

    static func isVersion(_ remote: String, greaterThan current: String) -> Bool {
        let cleanRemote = sanitizeVersionString(remote)
        let cleanCurrent = sanitizeVersionString(current)

        let remoteComponents = cleanRemote.split(separator: ".").compactMap { Int($0) }
        let currentComponents = cleanCurrent.split(separator: ".").compactMap { Int($0) }

        let count = max(remoteComponents.count, currentComponents.count)
        for i in 0..<count {
            let r = i < remoteComponents.count ? remoteComponents[i] : 0
            let c = i < currentComponents.count ? currentComponents[i] : 0
            if r > c { return true }
            if r < c { return false }
        }
        return false
    }

    private static func sanitizeVersionString(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: CharacterSet(charactersIn: "vV \t\n"))
        let withoutMetadata = trimmed.split(
            maxSplits: 1,
            omittingEmptySubsequences: true
        ) { $0 == "-" || $0 == "+" }.first
        return String(withoutMetadata ?? Substring(trimmed))
    }

    // MARK: - Check For Updates

    func checkForUpdates(autoDownload: Bool = false, manual: Bool = false) async {
        status = .checking

        let endpointString = "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest"
        guard let url = URL(string: endpointString) else {
            status = .error(String(localized: "Invalid update URL"))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("KawalPrayer-macOS", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                status = .error(String(localized: "Failed to connect to update server"))
                return
            }

            if httpResponse.statusCode == 404 {
                // No releases published yet on GitHub repository
                status = manual ? .upToDate : .idle
                return
            }

            guard httpResponse.statusCode == 200 else {
                status = .error(String(localized: "Update server error"))
                return
            }

            let release = try JSONDecoder().decode(GitHubReleasePayload.self, from: data)
            let versionString = release.tagName.trimmingCharacters(in: CharacterSet(charactersIn: "vV \t\n"))

            if Self.isVersion(versionString, greaterThan: currentVersion) {
                let dmgAsset = release.assets.first(where: { $0.name.hasSuffix(".dmg") })
                let downloadUrl = dmgAsset.flatMap { URL(string: $0.browserDownloadUrl) }
                    ?? URL(string: release.htmlUrl)

                let info = AppReleaseInfo(
                    version: versionString,
                    tagName: release.tagName,
                    releaseNotes: release.body ?? "",
                    publishedAt: ISO8601DateFormatter().date(from: release.publishedAt ?? ""),
                    htmlUrl: URL(string: release.htmlUrl) ?? url,
                    downloadUrl: downloadUrl,
                    assetName: dmgAsset?.name
                )

                self.latestRelease = info
                self.status = .updateAvailable(info)

                if autoDownload, dmgAsset != nil {
                    await downloadUpdate(release: info)
                }
            } else {
                status = manual ? .upToDate : .idle
            }
        } catch {
            status = manual ? .error(error.localizedDescription) : .idle
        }
    }

    // MARK: - Download Update

    func downloadUpdate(release: AppReleaseInfo) async {
        guard let downloadUrl = release.downloadUrl else {
            NSWorkspace.shared.open(release.htmlUrl)
            return
        }

        guard downloadUrl.pathExtension.lowercased() == "dmg" else {
            NSWorkspace.shared.open(downloadUrl)
            return
        }

        status = .downloading(progress: 0.0)

        let assetName = release.assetName ?? "KawalPrayer-\(release.version).dmg"
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("KawalPrayer_Update_\(UUID().uuidString)")
        let tempDestination = tempDir.appendingPathComponent(assetName)

        do {
            try FileManager.default.createDirectory(
                at: tempDir,
                withIntermediateDirectories: true
            )

            let (asyncBytes, response) = try await URLSession.shared.bytes(from: downloadUrl)
            let totalBytes = response.expectedContentLength
            var receivedBytes: Int64 = 0

            var fileData = Data()
            if totalBytes > 0 {
                fileData.reserveCapacity(Int(totalBytes))
            }

            var lastReportedTime = Date()
            for try await byte in asyncBytes {
                fileData.append(byte)
                receivedBytes += 1

                let now = Date()
                if now.timeIntervalSince(lastReportedTime) > 0.25 || receivedBytes == totalBytes {
                    lastReportedTime = now
                    let progress = totalBytes > 0 ? Double(receivedBytes) / Double(totalBytes) : 0.5
                    self.status = .downloading(progress: progress)
                }
            }

            try fileData.write(to: tempDestination)
            self.status = .readyToInstall(release: release, localPath: tempDestination)
        } catch {
            self.status = .error(error.localizedDescription)
        }
    }

    // MARK: - Install & Relaunch

    func installUpdate(localURL: URL) {
        let currentPID = ProcessInfo.processInfo.processIdentifier
        let bundlePath = Bundle.main.bundleURL.path
        let targetAppPath = bundlePath.hasPrefix("/Applications")
            ? "/Applications/KawalPrayer.app"
            : bundlePath

        let script = """
        #!/bin/bash
        set -e
        # Wait for old app process to terminate
        while kill -0 \(currentPID) 2>/dev/null; do
            sleep 0.5
        done

        MOUNT_DIR=$(mktemp -d /tmp/kawal_mount.XXXXXX)
        hdiutil attach "\(localURL.path)" -nobrowse -mountpoint "$MOUNT_DIR" -quiet

        if [ -d "$MOUNT_DIR/KawalPrayer.app" ]; then
            rm -rf "\(targetAppPath)"
            cp -R "$MOUNT_DIR/KawalPrayer.app" "\(targetAppPath)"
            xattr -cr "\(targetAppPath)" 2>/dev/null || true
            codesign --force --deep --sign - "\(targetAppPath)" 2>/dev/null || true
        fi

        hdiutil detach "$MOUNT_DIR" -quiet 2>/dev/null || true
        rm -rf "$MOUNT_DIR"
        rm -rf "\(localURL.deletingLastPathComponent().path)"

        open "\(targetAppPath)"
        exit 0
        """

        let scriptURL = FileManager.default.temporaryDirectory.appendingPathComponent("install_kawal_update.sh")
        do {
            try script.write(to: scriptURL, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptURL.path)

            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = [scriptURL.path]
            try process.run()

            NSApplication.shared.terminate(nil)
        } catch {
            // Fallback: reveal DMG directly
            NSWorkspace.shared.open(localURL)
        }
    }
}
