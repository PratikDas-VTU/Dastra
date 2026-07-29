name: Bug Report
description: Create a report to help us improve Dastra
title: "[BUG] "
labels: ["bug"]
assignees: []
body:
  - type: markdown
    attributes:
      value: |
        Thanks for taking the time to fill out this bug report! Please ensure the bug has not already been reported in the issue tracker.
  - type: input
    id: version
    attributes:
      label: Dastra Version
      description: What version of Dastra are you using? (e.g., v1.0 RC1)
      placeholder: v1.0 RC1
    validations:
      required: true
  - type: dropdown
    id: os
    attributes:
      label: Operating System
      description: Which OS are you running Dastra on?
      options:
        - Windows 11
        - Windows 10
        - Android 14
        - Android 13
        - Other (please specify below)
    validations:
      required: true
  - type: textarea
    id: description
    attributes:
      label: Description
      description: A clear and concise description of what the bug is.
      placeholder: Describe the issue...
    validations:
      required: true
  - type: textarea
    id: reproduction
    attributes:
      label: Steps to Reproduce
      description: Steps to reproduce the behavior.
      placeholder: |
        1. Go to '...'
        2. Click on '....'
        3. Scroll down to '....'
        4. See error
    validations:
      required: true
  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
      description: A clear and concise description of what you expected to happen.
    validations:
      required: true
  - type: textarea
    id: screenshots
    attributes:
      label: Screenshots / Logs
      description: If applicable, add screenshots or logs to help explain your problem.
