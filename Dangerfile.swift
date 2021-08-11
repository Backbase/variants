import Danger

fileprivate extension Danger.File {
    var isInSources: Bool { hasPrefix("Sources/") }
    var isInTests: Bool { hasPrefix("Tests/") }
    
    var isSourceFile: Bool {
        hasSuffix(".swift") || hasSuffix(".h") || hasSuffix(".m")
    }
    
    var isSwiftPackageDefintion: Bool {
        hasPrefix("Package") && hasSuffix(".swift")
    }
    
    var isDangerfile: Bool {
        self == "Dangerfile.swift"
    }
}

let danger = Danger()
let git = danger.git

// Sometimes it's a README fix, or something like that - which isn't relevant for
// including in a project's CHANGELOG for example
let isDeclaredTrivial = danger.github?.pullRequest.title.contains("#trivial") ?? false
let changedFiles = (git.modifiedFiles + git.createdFiles).filter { $0.isInSources || $0.isInTests }
let hasSourceChanges = (git.modifiedFiles + git.createdFiles).contains { $0.isInSources }

let allSourceFiles = danger.git.modifiedFiles + danger.git.createdFiles
var bigPRThreshold = 500

let swiftFilesWithoutCopyright = changedFiles.filter {
    $0.fileType == .swift
        && !danger.utils.readFile($0).contains(
            """
            //
            //  Variants
            //
            //  Copyright (c) Backbase B.V. - https://www.backbase.com
            """)
}

if swiftFilesWithoutCopyright.count > 0 {
    let files = swiftFilesWithoutCopyright.joined(separator: ", ")
    fail("Copyright header is missing in files: \(files)")
}

// Make it more obvious that a PR is a work in progress and shouldn't be merged yet
if danger.github?.pullRequest.title.contains("WIP") == true {
    warn("PR is marked as Work in Progress")
}

// Warn when there is a big PR
if let additions = danger.github?.pullRequest.additions,
   let deletions = danger.github?.pullRequest.deletions, additions + deletions > bigPRThreshold {
    warn("""
        Pull request is relatively big. If this PR contains multiple changes,
        consider splitting it into separate PRs for easier reviews.
        """)
}

//  Changelog entries are required for changes to library files.
//  TODO: Enabled prior to 1.0.0 release
//  if hasSourceChanges && !isDeclaredTrivial && !git.modifiedFiles.contains("CHANGELOG.md") {
//      warn("Any changes to library code should be reflected in the CHANGELOG. Please consider adding a note there about your change.")
//  }

// Warn when library files has been updated but not tests.
if hasSourceChanges && !git.modifiedFiles.contains(where: { $0.isInTests }) {
    warn("""
        The library files were changed, but the tests remained unmodified.
        Consider updating or adding to the tests to match the library changes.
        """)
}
