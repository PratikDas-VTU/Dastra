name: Feature Request
description: Suggest an idea or new tool for Dastra
title: "[FEATURE] "
labels: ["enhancement"]
assignees: []
body:
  - type: markdown
    attributes:
      value: |
        Thanks for your interest in improving Dastra! Please describe your feature request below.
  - type: textarea
    id: description
    attributes:
      label: Feature Description
      description: A clear and concise description of what you want to achieve or the new tool you'd like to see.
      placeholder: Describe your feature idea...
    validations:
      required: true
  - type: textarea
    id: usecase
    attributes:
      label: Use Case
      description: Why is this feature needed? How does it improve the offline workflow?
      placeholder: This feature would allow users to...
    validations:
      required: true
  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives Considered
      description: Have you considered any alternative solutions or workarounds?
  - type: textarea
    id: context
    attributes:
      label: Additional Context
      description: Add any other context or screenshots about the feature request here.
