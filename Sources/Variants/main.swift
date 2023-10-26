//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import ArgumentParser
import VariantsCore

struct Variants: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "variants",
        abstract: "A command-line tool to setup deployment variants and working CI/CD setup",
        version: "1.2.1",
        subcommands: [
            Initializer.self,
            Setup.self,
            Switch.self,
            List.self
        ]
    )
}

Variants.main()
