---
title: "19 Acceptance Criteria Examples for Different Products, Formats and Scenarios "
description: "See our best practice acceptance criteria examples to help you get your ACs right so you save bags of time and deliver faster."
keywords: ""
source: "https://www.prodpad.com/blog/acceptance-criteria-examples/?utm_source=tldrproduct"
---

Want to ship features that actually work—and pass [QA testing](https://www.prodpad.com/glossary/qa-testing/) without blood, sweat, and tears? The secret lies in nailing your acceptance criteria. And the best way to hone your acceptance criteria writing skills is to understand what good acceptance criteria examples look like. 

So that’s what I’ll cover here today—13 best practice acceptance criteria examples so you fully understand what acceptance criteria look like when they’re at their best. I’ll break down exactly what makes good acceptance criteria, why they’re crucial, how they fit with user stories, and (most importantly) take you through these 13 real-world acceptance criteria examples from SaaS, e-commerce, IoT, mobile, and even regulated industries. 

Plus, I’ll show you what _not_ to do—because nothing tanks a release faster than “The system should be user-friendly.”

I’ll cover:

* What are acceptance criteria?
* Why are acceptance criteria important?
* How do acceptance criteria relate to user stories?
* Acceptance criteria examples for the gherkin-style format
* AC examples for the checklist-style format
* AC examples for the rules-based format
* AC examples for the scenario-based format
* AC examples for negative paths and edge cases
* Acceptance criteria for quantitative/measurable targets
* Acceptance criteria example for B2B SaaS
* Acceptance criteria example for e-commerce
* Acceptance criteria example for IoT device
* Acceptance criteria example for mobile app
* Acceptance criteria example for fintech
* Acceptance criteria example for healthcare
* What does bad acceptance criteria look like? With 4 examples
* How to write better acceptance criteria
* Acceptance criteria best practices

So, let’s get on with it…

## What are acceptance criteria?

[Acceptance criteria](https://www.prodpad.com/glossary/acceptance-criteria/) are clear, specific conditions that must be met for a user story or feature to be considered complete. They define the boundaries of scope and ensure shared understanding between Product, Design, and Development Teams. Often written by a member of the Product team, they outline the expectations of the work being delivered by the Development Team. 

Acceptance criteria are where ambiguity goes to die. They answer the all-important question: “How will we know this is done—and done right?” Without them, your team is left guessing (and you’re left fielding angry emails from QA and stakeholders). Good acceptance criteria give everyone—Dev, QA, PM, and even the customer—a shared contract for success.

## Why are acceptance criteria important?

If you’ve ever seen a user story that sounded perfect in planning but blew up in [UAT](https://www.techtarget.com/searchsoftwarequality/definition/user-acceptance-testing-UAT), you know why acceptance criteria exist. Here’s what they prevent (or at least, dramatically reduce):

* **Scope Creep:** No more “Couldn’t we just add X while we’re here?” Acceptance criteria draw the line.  
    
* **Ambiguity:** They force clarity—no more wishy-washy “Make it better” tickets.  
    
* **Testing:** QA gets a checklist for what _actually_ needs to work. No guessing, no “I assumed…”  
    
* **Team Alignment:** Engineers, Designers, and PMs can finally speak the same language. Less rework, fewer arguments.  
    

**Best practice tip:** Make acceptance criteria mandatory. If you’re shipping user stories without them, you’re gambling with your [roadmap](https://www.prodpad.com/guides/product-roadmaps/).

## How do acceptance criteria relate to user stories?

Let’s get practical: user stories and acceptance criteria are PB&J. The user story frames the _what_ and _why_; the acceptance criteria spell out the _how you’ll know it’s done_. No acceptance criteria? Your story is half-baked.

**Standard User Story Format:**_As a [persona], I want [goal] so that [reason/benefit]._

**Acceptance criteria:**Specific, testable conditions—usually written as a checklist, Given/When/Then scenario, or rule.

### Acceptance Criteria Example _with_ User Story Example 1 (SaaS onboarding):

Here’s an example of a good pairing for a user story example and an acceptance criteria example specifically relevant to a SaaS product. 

**User Story Example:**_As a new user, I want to complete onboarding so that I can start using the product right away._

**Acceptance Criteria Example:**

* * User sees a welcome message after sign-up.

* * System guides the user through a 3-step tutorial.

* * “Skip tutorial” is available on every step.

* * User profile is marked as “onboarded” when tutorial is complete or skipped.

### Acceptance Criteria Example _with_ User Story Example 2 – (E-commerce)

Next let’s look at an example of a good pairing for a user story example and an acceptance criteria example appropriate for an e-commerce site. 

**User Story Example:**_As a customer, I want to save my shopping cart so I can complete my purchase later._

**Acceptance Criteria Example:**

* * Cart contents persist for at least 30 days.

* * Cart is available across devices when logged in.

* * User receives a reminder email after 7 days of inactivity if the cart isn’t checked out.

**Takeaway:** Without these acceptance criteria examples, both of these user stories leave _way_ too much to interpretation. With the ACs, everyone knows what “done” actually means.

## Types of Acceptance Criteria Formats (with Examples)

Let’s break down the main ways Product Teams write acceptance criteria—complete with paired user stories and clear, boxed examples for each.

### 1. Given/When/Then (Gherkin-style)

Best for: test automation, detailed scenarios, [BDD](https://agilealliance.org/glossary/bdd/) teams.

**User Story Example:**_As a user, I want to reset my password so I can regain access if I forget it._

**Acceptance Criteria Example (Given/When/Then):**

* * **Given** I’m on the login page  
        **When** I click “Forgot password” and enter a registered email  
        **Then** I receive a reset link within 5 minutes

* * **Given** I use the reset link  
        **When** I set a new password  
        **Then** I can log in with the new password

### 2. Checklist-Style

Best for: simple flows, small features, teams new to acceptance criteria.

**User Story Example:**_As an admin, I want to export user data to CSV so I can analyze usage._

**Acceptance Criteria Example (Checklist):**

* * Export includes all active users

* * Columns: name, email, signup date, last login

* * File is in CSV format, UTF-8 encoded

* * Exported file downloads in < 5 seconds for up to 10,000 users

### 3. Rules-Based (“If X, then Y”)

Best for: business logic, integrations, or edge cases.

**User Story Example:**_As a finance manager, I want failed payments to trigger alerts so I can respond quickly._

**Acceptance Criteria Example (Rules-based):**

* * **If** a payment fails **then** send an alert to the billing team

* * **If** three consecutive failures occur **then** lock the account and notify the user

* * **If** the payment succeeds after retry, **then** remove any lock and send confirmation

### 4. Scenario-Based

Best for: features with multiple flows, especially e-commerce, onboarding, or settings.

**User Story Example:**_As a customer, I want to change my delivery address so my order arrives at the right place._

**Acceptance Criteria Example (Scenarios):**

* * Scenario 1: Address change before shipment updates order and sends confirmation email

* * Scenario 2: Address change after shipment not allowed; user sees error message

* * Scenario 3: Address change available only for orders not yet processed

### 5. Negative Paths and Edge Cases

Best for: QA, regulated industries, robust products.

**User Story Example:**_As a healthcare provider, I want to access patient records so I can provide accurate care._

**Acceptance Criteria Example (Negative/Edge Cases):**

* * Access is denied if user role ≠ “Provider” (unauthorized roles see error)

* * Access is logged for all views and downloads

* * Access is blocked if patient has revoked consent (show consent error)

### 6. Quantitative/Measurable Targets

Best for: performance, security, compliance.

**User Story Example:**_As a user, I want to upload a profile picture so my account feels personal._

**Acceptance Criteria Example (Quantitative):**

* * Max file size: 5MB

* * Acceptable formats: JPG, PNG, GIF

* * Upload completes in < 3 seconds on standard broadband

* * Image appears in profile within 2 seconds after upload

## Acceptance Criteria Examples by Product Type

Let’s get real: acceptance criteria _change shape_ depending on your product. Here’s how to tailor your acceptance criteria for different industries:

### Acceptance Criteria Example: B2B SaaS – Onboarding Flow

**User Story Example:**_As a new team lead, I want to invite team members during onboarding so we can collaborate from day one._

**Acceptance Criteria Example:**

* * “Invite team” step is present in onboarding

* * Invites send emails with unique links

* * Team members show as “pending” until they accept

* * Onboarding can be completed without inviting anyone

### Acceptance Criteria Example: E-commerce – Checkout

**User Story Example:**_As a shopper, I want to apply a discount code at checkout so I can save money._

**Acceptance Criteria Example:**

* * Valid code applies discount and updates total instantly

* * Invalid code shows clear error

* * Discount applies only to eligible items

* * Only one code can be used per order

### Acceptance Criteria Example: IoT Device – Settings

**User Story Example:**_As a homeowner, I want to set my smart thermostat to “Vacation Mode” so I save energy while away._

**Acceptance Criteria Example:**

* * User can activate “Vacation Mode” via app or device

* * Confirmation message appears when activated

* * System sets temp to preset “away” value

* * Device status updates in user dashboard within 1 minute

### Acceptance Criteria Example: Mobile App – Push Notifications

**User Story Example:**_As a mobile user, I want to receive push notifications for new messages so I stay informed._

**Acceptance Criteria Example:**

* * Notification sent within 30 seconds of new message arrival

* * Notification opens app to message thread

* * User can disable notifications in settings

### Acceptance Criteria Example: B2C / Consumer App – Content Upload

**User Story Example:**_As a creator, I want to upload videos from my phone so I can share content instantly._

**Acceptance Criteria Example:**

* * Videos up to 2GB are accepted

* * Upload works on WiFi and mobile data

* * User sees upload progress bar

* * Failed uploads show retry option

### Acceptance Criteria Example: Regulated Industry – Fintech

**User Story Example:**_As a banking user, I want to view my transaction history so I can track my spending._

**Acceptance Criteria Example:**

* * Only show transactions from the past 24 months

* * Downloadable statement available as PDF

* * Transactions labeled with merchant, amount, date

* * Privacy notice appears on first access

### Acceptance Criteria Example: Healthcare (GovTech/EdTech/Mediatech) – Consent Management

**User Story Example:**_As a patient, I want to grant or revoke consent for my data so I control my privacy._

**Acceptance Criteria Example:**

* * Consent status is clearly visible and editable

* * Revoking consent removes access for all providers within 24 hours

* * All changes are timestamped and logged

* * User receives confirmation after any change

## What does bad acceptance criteria look like? (And how to fix it)

Let’s be honest: most acceptance criteria mistakes are avoidable. Thanks to our examples so far you now know what good looks like, but it’s equally as important to understand what bad looks like.

 ![Acceptance criteria examples showing good versus bad from ProdPad product management software](data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20viewBox='0%200%201012%20852'%3E%3C/svg%3E)

Here’s what _not_ to do:

### Bad Acceptance Criteria Example 1: Vague as fog

“The system should be user-friendly.”

**Why it’s bad:**Zero testability. What does “user-friendly” mean? To whom? Based on what standard?  
**How to fix:**Specify _what_ makes it user-friendly: “All form fields have placeholder text and error messages appear within 1 second of invalid input.”

### Bad Acceptance Criteria Example 2: Gold-plated detail

“The button should be blue, 14px Arial, with 8px margin, and animate in 0.3s with cubic-bezier curve.”

**Why it’s bad:**You’re writing a design spec, not acceptance criteria. Let the designers design.  
**How to fix:**Stick to outcomes: “The button is clearly visible and labeled ‘Submit’; meets brand style guide.”

### Bad Acceptance Criteria Example 3: Missing outcomes

“Form submits successfully.”

**Why it’s bad:**Successful _how_? What does the user see or receive?  
**How to fix:**“After submitting the form, user sees a confirmation page and receives a confirmation email.”

### Bad Acceptance Criteria Example 4: Hidden business logic

“Export works.”

**Why it’s bad:**Works… for whom? What is “works”?  
**How to fix:**“Exported file contains all user records, in CSV format, downloadable within 10 seconds.”

**Tip:** Review your acceptance criteria style in [retros](https://www.prodpad.com/glossary/retrospective/)—different teams and features need different levels of detail. There’s no shame in iterating your style!

## How to write better acceptance criteria

Writing good ACs isn’t just for the Product Manager. It’s a team sport. Here’s how the best teams do it:

* **Collaborate early:** Bring Product Manager, Developers, and QA Testers together before a story starts. Don’t let one person write all acceptance criteria in a vacuum.  
    
* **Align to the outcome:** Acceptance criteria must tie directly to the story’s “so that.” If you can’t trace it, you’re doing it wrong.  
    
* **Stay specific, not prescriptive:** Specify what needs to happen—not _how_ it’s implemented.  
    
* **Retros are your friend:** Review what’s working and what isn’t. Evolve your acceptance criteria style as your team grows.  
    

## Final Tips: Acceptance Criteria Best Practices

Let’s land this with a lightning round of best practices:

* **Keep criteria testable:** If you can’t test it, it’s not done.  
    
* **Reuse good formats:** Steal from yourself—if a format works, make it your default.  
    
* **Don’t gold-plate:** Focus on outcomes, not endless detail.  
    
* **Include edge cases:** QA will love you forever.  
    
* **Make acceptance criteria visible:** Don’t hide them in a doc no one reads. Put them on the ticket, the board, within the Idea in ProdPad, wherever your team lives.  
    

Ready to up your user story game? Start every story with clear, shared, and testable acceptance criteria—your users (and your team) will thank you.

With ProdPad as the single source of truth for all your Product Management work, you can keep your acceptance criteria within your complete feature Idea record. Everything all together, visible to everyone and easily accessible.

See the power of a central, single source of truth for all things Product