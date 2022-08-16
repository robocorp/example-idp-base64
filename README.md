# Intelligent document processing (IDP) with Base64.ai

This robot demonstrates the usage of [Base64.ai](https://base64.ai) API for detecting document types and extracting the structured data from any of their supported document types.

- The robot is divided in a producer and consumer tasks:
  - The producer parses email attachements and converts files to base64 encoding and sends the extraction request to Base64.ai API. The first task produces a work item for each supported attachment that has the JSON response from Base64.ai API as the payload.
  - Consumer processes each work item, and for the demonstration purposes sends the information of the document type to a Slack channel. This is where one would implement the business logic for each document type.
- Example implementation supports only `.png`  and `.jpg`/`.jpeg` attachment types, all the rest are omitted.
- There are size limitations of the work item payload size (100 000 bytes), the implementation will not handle the over the max size situations.
- The implementation demonstrates parallel processing capabilities of Robocorp platform, as each output work item from the producer is realeased for the processing by Consumer immediately when ready, and there can be multiple parallel executions of Consumer robots.

## Prerequisites

-


Recommended further reading:
- The [Producer-consumer](https://en.wikipedia.org/wiki/Producer%E2%80%93consumer_problem) model is not limited to two steps.
- [Using work items](https://robocorp.com/docs/development-guide/control-room/work-items)
- [Work item exception handling](https://robocorp.com/docs/development-guide/control-room/work-items#work-item-exception-handling)