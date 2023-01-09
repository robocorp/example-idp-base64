# Intelligent document processing (IDP) with Base64.ai

This robot demonstrates the usage of [Base64.ai](https://base64.ai) library `RPA.DocumentAI.Base64AI` for detecting document types and extracting structured data from any of their supported document types.

## What you'll learn with this reference architecture

- Using `RPA.DocumentAI.Base64AI` for categorising document types and extracting structured data
- Working with Work Data Management with Producer/Consumer robot template
- Triggering robots with emails
- Using `RPA.Notifier` to send Slack messages

The reference architecture splits tasks into separate steps, allowing for the hyperscaling of the automation operations. The example simplifies the tasks of document extraction and simply has a case-by-case handler per document type that sends the document’s key details to Slack.

![image](https://user-images.githubusercontent.com/40179958/191695046-bb38e294-6693-4a66-b50c-a1cfef592611.png)

## How does it work

- The robot is divided in a producer and consumer tasks:
  - The Producer parses email attachments and sends the extraction request to the Base64.ai API. The first task produces a work item for each supported attachment that has the JSON response from the Base64.ai API as the work item file, and model details as a payload.
  - The Consumer processes each work item, and for demonstration purposes, sends the document type information to a Slack channel. This is where one would implement the business logic for each document type.
- The implementation demonstrates the parallel processing capabilities of the Robocorp platform, as each work item output from the Producer is released for processing by the Consumer immediately when ready - and there can be multiple parallel executions of Consumer robots.

## Prerequisites

- Get a free (or paid) API key from [Base64.ai](https://base64.ai).
- Create a Vault in [Control Room](https://cloud.robocorp.com) called `Base64` that has two secrets called `email` and `api-key`.
- Create a [Slack webhook](https://slack.com/help/articles/115005265063-Incoming-webhooks-for-Slack) that allows posting to your workspace.
- Create a Vault in [Control Room](https://cloud.robocorp.com) called `Slack` that has two secrets: `webhook` that contains the webhook URL that you got from Slack, and `channel`, which is the channel where the messages are posted.

![image](https://user-images.githubusercontent.com/40179958/191694637-fcbb2ab6-798d-413a-8fd2-3f47a07c74ed.png)

## Running the robot

While it's possible to run the robot in your development environment with the provided example data, it's meant to be used with email as a trigger. Once you have uploaded the robot code to the Control Room, configure a new process with two steps following the example in the picture.

![image](https://user-images.githubusercontent.com/40179958/184806054-9959b998-6e2d-4e8a-aaf9-8efe02889a68.png)

Then add a new email trigger under the Schedules & Triggers tab, and make sure to have both Parse email and Trigger process checkboxes selected. It should be set up like in the screenshot.

![image](https://user-images.githubusercontent.com/40179958/184806318-f0ad25de-932d-47bc-9022-8fd68e18c0e2.png)

Running the process is easy. Just send an email with some attachments to the email address shown in Control Room and wait for the results. The easiest way to view the full response of the Base64.ai API is to look for Work Data in each run of the Consumer task through Control Room. See the details in the screenshot.

![image](https://user-images.githubusercontent.com/40179958/184807403-4b5dc10c-4a67-40d6-a312-f74516d7803e.png)

## Recommended further reading

- The [Producer-consumer](https://en.wikipedia.org/wiki/Producer%E2%80%93consumer_problem) model is not limited to two steps.
- [Using work items](https://robocorp.com/docs/development-guide/control-room/work-items)
- [Work item exception handling](https://robocorp.com/docs/development-guide/control-room/work-items#work-item-exception-handling)
