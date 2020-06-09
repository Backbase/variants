//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Arthur Alves
//

import SwiftCLI

let cli = CLI(
    name: "variants",
    version: "0.1.0",
    description: "A command-line tool to setup deployment variants and full CI/CD pipelines"
)

cli.commands = [
    Initializer(),
    iOSSetup(),
    AndroidSetup()
]

cli.globalOptions.append(VerboseFlag)

_ = cli.go()
