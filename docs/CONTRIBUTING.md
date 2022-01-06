# Contributing to Variants

## Code style

We follow codestyle guidelines from Swift's official documentation. Details can be found [here](https://swift.org/documentation/api-design-guidelines/). All rules are enforced except for third party dependencies.

## Version control

We use Git for source control hosted at GitHub.

### Commit messages

We recommend to follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#summary) specification when naming your commits but it's not strictly imposed as we use a squash merge strategy when merging code.

### Branching strategy

We use a simplified git-flow branching model, on which there are the following types of branches:

- **main**: This branch only contains code that has been released. It represents the public stable release. Release tags are added for versioning control in this branch. Only `develop` or `hotfix` can be merged to this branch.

- **develop**: This is an integration branch. Its purpose is to have a staging place where changes can be tested thoroughly before being released publicly (merged into the `main` branch). All branches should base from `develop` except for `hotfix`.

- **hotfix**: Critical solutions or additions that requires to be released as soon as possible. This type of branch should alwasy base on latest `main` and can be merged directly without passing through `develop`. In some cases it's advised to also merge the `hotfix` to `develop` for parity sake. Due to its critical nature, `hotfix` branchs needs to **get approval from at least one of the repo admins**.

- **feature**: Any new functionality or improvement to be added to the codebase should be created as a `feature` branch. It will always base from `develop` and merges to `develop` as well.

- **fix**: Any issue to be fixed in the codebase. It follows same guidelines as `feature` branches. It will always base from `develop` and merges to `develop` as well.

When defining your branch name, try to provide a quick summary about what is it aiming to do. When applicable, try to include the issue number in the branch name as well.

Examples:

	hotfix/144-fix-xcode-dependency-issue
	feature/145-add-appstore-deliver
	fix/146-failing-test-case

### Merging strategy

After getting all necessary approvals and fixing any requested change, always go for a **squash merge** strategy. This avoid poluting our commit history while keeping it legible for history searches. 

Before merging, check the generated commit message and look for any necessary update. Keep in mind that it will be used when generating the automatic version changelog at each release.

## Creating a Pull Request

When opening a PR, try to make its title as meaningful as possible. Try to include the issue number when applicable as well.

The PR description will come with a template that needs to be filled accordingly. When a section from the description template is not applicable please leave it with *"Not applicable"* in its content.

There is a checklist in the template which needs to be completed in order for the PR to be ready for review.

When it's ready for review, request review from repo reviewers and set the PR assignee as yourself.

PR description example:

	### What does this PR do
	Releases Variants 0.9.4

	### How can it be tested
	Not applicable

	### Task
	Not applicable

	### Checklist:

	- [x] I ran `make validation` locally with success
	- [x] I have not introduced new bugs
	- [x] My code follows the style guidelines of this project
	- [x] I have performed a self-review of my own code
	- [x] I have commented on my code, particularly in hard-to-understand areas
	- [x] I have made corresponding changes to the documentation
	- [x] My changes generate no new errors
