//
// Copyright 2017 Ali Akhtarzada
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//

public struct GenericError {
}

extension GenericError {
    public struct CannotComply: Error {}
}

extension GenericError {
    public struct Failed: Error, CustomStringConvertible {
        public let description: String
        public init(_ string: String = "failed") {
            self.description = string
        }
    }
}
