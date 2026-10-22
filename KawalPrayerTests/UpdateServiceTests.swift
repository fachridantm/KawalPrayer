import XCTest
@testable import KawalPrayer

final class UpdateServiceTests: XCTestCase {

    func testVersionComparison() {
        // Newer versions
        XCTAssertTrue(UpdateService.isVersion("1.0.1", greaterThan: "1.0.0"))
        XCTAssertTrue(UpdateService.isVersion("v1.1.0", greaterThan: "1.0.9"))
        XCTAssertTrue(UpdateService.isVersion("v2.0.0", greaterThan: "v1.9.9"))
        XCTAssertTrue(UpdateService.isVersion("1.0.0.1", greaterThan: "1.0.0"))
        XCTAssertTrue(UpdateService.isVersion("v1.2.3", greaterThan: "1.2.2"))

        // Equal versions
        XCTAssertFalse(UpdateService.isVersion("1.0.0", greaterThan: "1.0.0"))
        XCTAssertFalse(UpdateService.isVersion("v1.0.0", greaterThan: "1.0.0"))
        XCTAssertFalse(UpdateService.isVersion("1.0.0", greaterThan: "v1.0.0"))

        // Pre-release and build metadata suffixes
        XCTAssertTrue(UpdateService.isVersion("v1.0.1-beta.1", greaterThan: "1.0.0"))
        XCTAssertTrue(UpdateService.isVersion("v1.0.1+2", greaterThan: "1.0.0+1"))
        XCTAssertFalse(UpdateService.isVersion("v1.0.0+5", greaterThan: "1.0.0"))

        // Older versions
        XCTAssertFalse(UpdateService.isVersion("0.9.9", greaterThan: "1.0.0"))
        XCTAssertFalse(UpdateService.isVersion("1.0.0", greaterThan: "1.0.1"))
        XCTAssertFalse(UpdateService.isVersion("v0.5.0", greaterThan: "v1.0.0"))
    }

    @MainActor
    func testVersionAndBuildDisplayFormatting() {
        let service = UpdateService.shared
        XCTAssertFalse(service.currentVersion.isEmpty)
        XCTAssertFalse(service.currentBuild.isEmpty)
        XCTAssertEqual(
            service.displayVersion,
            "\(service.currentVersion) (\(service.currentBuild))"
        )
    }

    func testUpdateSettingsDefaultValues() {
        let settings = PrayerSettings()
        XCTAssertTrue(settings.autoUpdateEnabled)
        XCTAssertTrue(settings.autoCheckUpdates)
    }

    func testUpdateSettingsEncodingDecoding() throws {
        var settings = PrayerSettings()
        settings.autoUpdateEnabled = false
        settings.autoCheckUpdates = false

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(PrayerSettings.self, from: data)

        XCTAssertFalse(decoded.autoUpdateEnabled)
        XCTAssertFalse(decoded.autoCheckUpdates)
    }

    func testGitHubPayloadDecoding() throws {
        let json = """
        {
            "tag_name": "v1.0.1",
            "name": "KawalPrayer 1.0.1",
            "body": "Bug fixes and improvements",
            "html_url": "https://github.com/fachridantm/KawalPrayer/releases/tag/v1.0.1",
            "published_at": "2026-10-18T00:00:00Z",
            "assets": [
                {
                    "name": "KawalPrayer-v1.0.1.dmg",
                    "browser_download_url": "https://github.com/fachridantm/KawalPrayer/releases/download/v1.0.1/KawalPrayer-v1.0.1.dmg",
                    "size": 15000000
                }
            ]
        }
        """.data(using: .utf8)!

        let release = try JSONDecoder().decode(GitHubReleasePayload.self, from: json)
        XCTAssertEqual(release.tagName, "v1.0.1")
        XCTAssertEqual(release.name, "KawalPrayer 1.0.1")
        XCTAssertEqual(release.assets.count, 1)
        XCTAssertEqual(release.assets.first?.name, "KawalPrayer-v1.0.1.dmg")
    }

    @MainActor
    func testUpdateStatusFlags() {
        let service = UpdateService.shared
        service.status = .idle
        XCTAssertFalse(service.isUpdateAvailable)

        service.status = .checking
        XCTAssertFalse(service.isUpdateAvailable)

        service.status = .upToDate
        XCTAssertFalse(service.isUpdateAvailable)

        let sampleRelease = AppReleaseInfo(
            version: "1.0.1",
            tagName: "v1.0.1",
            releaseNotes: "New features",
            publishedAt: Date(),
            htmlUrl: URL(string: "https://github.com/fachridantm/KawalPrayer")!,
            downloadUrl: nil,
            assetName: nil
        )

        service.status = .updateAvailable(sampleRelease)
        XCTAssertTrue(service.isUpdateAvailable)

        service.status = .downloading(progress: 0.5)
        XCTAssertTrue(service.isUpdateAvailable)

        service.status = .readyToInstall(
            release: sampleRelease,
            localPath: URL(fileURLWithPath: "/tmp/sample.dmg")
        )
        XCTAssertTrue(service.isUpdateAvailable)

        // Reset
        service.status = .idle
    }
}
