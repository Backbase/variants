//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import ArgumentParser

struct Variants: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "variants",
        abstract: "A command-line tool to setup deployment variants and full CI/CD pipelines",
        version: "0.1.0",
        subcommands: [
            Initializer.self,
            Setup.self,
            Switch.self
        ]
    )
}

Variants.main(["init", "--platform", "ios"])
