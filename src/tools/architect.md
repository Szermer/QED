### ArchitectTool: Software Architecture Planning

ArchitectTool serves as a specialized planning assistant that helps break down technical requirements into clear implementation plans.

#### Implementation

- Uses Zod for validating a simple schema with two parameters:
  - `prompt`: The technical request or coding task to analyze (required)
  - `context`: Optional additional context information
- Operates as a read-only tool that doesn't modify any files
- Disabled by default, requiring explicit enablement via configuration

#### Prompt Engineering

- Uses a detailed system prompt that defines its role as an "expert software architect"
- Follows a three-step process for analyzing requirements:
  1. Analyze requirements for core functionality and constraints
  2. Define technical approach with specific technologies and patterns
  3. Break implementation into concrete, actionable steps
- Explicitly avoids writing code or using string modification tools

ArchitectTool represents a specialized use case of Claude's planning capabilities, focusing on high-level architecture design rather than direct code implementation.

