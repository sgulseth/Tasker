//
// Copyright 2017 Ali Akhtarzada
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//

import Nimble
import Quick
import Swooft

class LoggerTests: QuickSpec {

    override func spec() {

        describe("logger") {

            it("should log tags if requested") {
                let tags = ["tag1", "tag2"]
                var log = ""

                let logger = Logger()
                logger.outputTags = true

                logger.addTransport { log += $0 }
                logger.log("something", tags: tags, force: true)

                logger.waitTillAllLogsTransported()

                expect(log).to(contain(tags))
                print(log)
            }

            it("should not log tags if not requested") {
                let tags = ["tag1", "tag2"]
                var log = ""

                let logger = Logger()
                logger.outputTags = false

                logger.addTransport { log += $0 }
                logger.log("something", tags: tags)

                logger.waitTillAllLogsTransported()

                expect(log).toNot(contain(tags))
            }

            it("should filter logs unless tagged") {
                let tag1 = "tag1"
                let tag2 = "tag2"
                let log1 = "\(tag1) log"
                let log2 = "\(tag2) log"

                var log = ""

                let logger = Logger()
                logger.addTransport { log += $0 }
                logger.filterUnless(tag: tag1)
                logger.log(log1, tag: tag1)
                logger.log(log2, tag: tag2)

                logger.waitTillAllLogsTransported()

                expect(log).to(contain(log1))
                expect(log).toNot(contain(log2))
            }

            it("should filter logs if tagged") {
                let tag1 = "tag1"
                let tag2 = "tag2"
                let log1 = "\(tag1) log"
                let log2 = "\(tag2) log"

                var log = ""

                let logger = Logger()
                logger.addTransport { log += $0 }
                logger.filterIf(tag: tag1)
                logger.log(log1, tag: tag1)
                logger.log(log2, tag: tag2)

                logger.waitTillAllLogsTransported()

                expect(log).toNot(contain(log1))
                expect(log).to(contain(log2))
            }

            it("should filter logs correctly") {
                let tag1 = "tag1"
                let tag2 = "tag2"
                let tag3 = "tag3"
                let log1 = "\(tag1) log"
                let log2 = "\(tag2) log"
                let log3 = "\(tag3) log"

                var log = ""

                let logger = Logger()
                logger.addTransport { log += $0 }
                logger.filterIf(tag: tag1)
                logger.filterIf(tag: tag3)
                logger.filterUnless(tag: tag2)
                logger.filterUnless(tag: tag3)
                logger.log(log1, tag: tag1)
                logger.log(log2, tag: tag2)
                logger.log(log3, tag: tag3)

                logger.waitTillAllLogsTransported()

                expect(log).toNot(contain(log1))
                expect(log).to(contain(log2))
                expect(log).toNot(contain(log3))
            }
        }
    }
}
