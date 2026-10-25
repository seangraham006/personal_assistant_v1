# Project Handoff: Personal AI Task & Reminder System

## 1. Objective

Help me build a low-cost, low-maintenance personal automation system that reduces the mental load of managing emails and tasks, particularly when I'm ill or have limited energy.

I want to experiment with n8n before buying any hardware. My immediate goal is to get a working local prototype on my Lenovo Yoga 6, then gradually build towards an automated email-to-task workflow.

## 2. Proposed Architecture

- **Workflow automation:** n8n Community Edition, self-hosted locally.
- **Development machine:** Lenovo Yoga 6 running Windows, with a Ryzen 5 5500U and 8 GB RAM.
- **AI classification:** Potentially Mistral using an available free API allowance, subject to checking current pricing and limits.
- **Task management:** Todoist as the single source of truth for actionable tasks.
- **Email sources:** Personal Gmail and Outlook accounts.
- **Future hosting:** Potentially a Raspberry Pi for always-on execution, but only if the prototype proves useful.

The intended workflow is approximately:

Personal Gmail / Outlook → n8n → AI identifies important emails and required actions → actionable items become Todoist tasks.

Eventually, I want the workflow to run approximately twice daily.

**Important:** Do not integrate UBS/work email.

## 3. Constraints and Preferences

- I do not want a paid n8n subscription or a solution dependent on a free trial.
- I want to minimise ongoing costs and avoid unnecessary subscriptions.
- I want to experiment before purchasing a Raspberry Pi or any other hardware.
- I am not particularly experienced with Docker or self-hosting, so guide me through setup incrementally.
- Keep the system simple and reliable rather than introducing unnecessary infrastructure.
- I want to minimise maintenance and manual intervention once the system is running.
- I have limited energy outside work, so prioritise a small working prototype over a complicated architecture.

## 4. Implementation Plan

### Stage 1: Check the Environment

First, establish whether Docker Desktop and WSL 2 are already installed on my Lenovo Yoga 6.

Then check the current official n8n documentation to determine the simplest supported method of running n8n locally on Windows.

Do not assume an installation method without verifying the current guidance.

### Stage 2: Run n8n Locally

Get n8n running locally without a subscription.

Help me access its workflow editor in my browser, typically at `http://localhost:5678`.

Explain any important implications of local hosting, including that the laptop generally needs to be running and awake for scheduled workflows to execute.

### Stage 3: Build a Simple Test Workflow

Before connecting real accounts, teach me the basics through a small workflow that:

1. Starts with a manual trigger.
2. Processes a sample email represented as test data.
3. Applies a basic condition or classification.
4. Produces a clear output.

Explain the relevant n8n concepts as we go, without turning this into a lengthy theoretical tutorial.

### Stage 4: Integrate Todoist

Connect Todoist using its supported authentication method.

Create a test task from the workflow and verify that it appears correctly.

Keep the initial integration simple. Explain any relevant account-plan limitations before relying on particular features.

### Stage 5: Add AI Classification

Investigate whether Mistral currently offers a suitable free API allowance.

Use AI to classify sample messages into categories such as:

- Requires action
- Important information
- No action required

Test the quality of the classifications before connecting real email.

Explain privacy implications before sending any real email content to an external AI provider.

### Stage 6: Connect Personal Email

Integrate Gmail and Outlook separately.

Start with read-only access and a small, controlled test set. Do not automatically create tasks from every email until the classification works reliably.

The desired outcome is to identify actionable emails and create useful Todoist tasks containing enough context to understand what needs doing.

### Stage 7: Automate and Evaluate Hosting

Once the workflow is reliable when triggered manually:

- Schedule it to run approximately twice daily.
- Prevent duplicate tasks when the same email is processed more than once.
- Add sensible error handling and logging.
- Evaluate whether moving the workflow to a Raspberry Pi would be worthwhile.

Do not recommend buying hardware until there is a demonstrated need for always-on execution.

## 5. Privacy and Reliability Requirements

- Never connect UBS/work email.
- Never expose API keys, OAuth secrets, passwords or access tokens in source control or chat.
- Use synthetic data during initial development.
- Before transmitting real email content to an external AI service, explain what data will be shared.
- Initially keep email operations read-only.
- Do not automatically send, delete, archive or modify emails.
- Implement deduplication before enabling scheduled runs.
- Store credentials using appropriate credential management rather than hardcoding them in workflows.
- Remember that local n8n hosting does not make external API calls local: Gmail, Outlook, Todoist and the selected AI provider may still receive requests or data.
- Keep costs transparent and verify current free-tier limits rather than assuming an API is free indefinitely.

## 6. How I Want You to Work With Me

Act as a practical technical collaborator.

- Give me one manageable step at a time.
- Start with the simplest working solution.
- Explain commands before asking me to run them.
- Do not assume I have installed software or configured services unless confirmed.
- Verify current documentation when installation procedures, pricing or service capabilities may have changed.
- Do not overengineer the prototype.
- Avoid paid services unless there is a clear reason and I explicitly agree.
- Distinguish between what is confirmed and what still needs investigation.

## 7. Immediate Next Step

**Start by asking whether Docker Desktop is already installed on my Lenovo Yoga 6.**

Then verify the current official n8n installation instructions and help me get a free local instance running.

Do not jump ahead to email integrations, Raspberry Pi purchases or production deployment. First, get n8n working and help me build a small test workflow.

## Stage 2: Local n8n Prototype

This repository contains a repeatable local n8n setup. It pins n8n to `2.42.6`
in [`compose.yml`](./compose.yml), exposes the editor only on this laptop at
`http://localhost:5678`, and stores n8n's SQLite data, encryption key,
workflows, and credentials in the Docker volume `personal-assistant-n8n-data`.
The volume survives stops and container recreation.

### Start it

1. Start Docker Desktop. If running from WSL, enable this distribution in
   **Docker Desktop → Settings → Resources → WSL Integration**, then open a new
   WSL terminal.
2. From this repository, run:

   ```bash
   ./local-run.sh start
   ```

3. Open <http://localhost:5678> and complete n8n's local owner-account setup.
   This is the free self-hosted Community Edition; it does not need an n8n
   subscription.

The runner checks Docker, starts the pinned container, and waits for n8n's
health endpoint before reporting success. Other useful commands are:

```bash
./local-run.sh status
./local-run.sh logs
./local-run.sh restart
./local-run.sh stop
```

To change n8n versions, edit the explicit image tag in
[`compose.yml`](./compose.yml), review the release notes, then run
`./local-run.sh restart`. This avoids unreviewed automatic upgrades.

### Local-hosting implications

- Workflows run only while Docker Desktop and this laptop are running and
  awake. Scheduled workflows do not run during sleep, shutdown, or Docker
  Desktop downtime.
- The editor is deliberately bound to `127.0.0.1`, so it is not exposed to the
  local network.
- The setup uses Docker's named volume rather than a Windows-mounted data
  directory. This prevents the WSL/Windows file-permission and performance
  issues that can affect bind mounts.
- Do not remove `personal-assistant-n8n-data` unless intentionally discarding
  all local n8n data. Stage 2 does not connect email, Todoist, or AI services.