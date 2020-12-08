#  Essential Feed iOS Application

<p align="center">
  <img src="https://raw.githubusercontent.com/AlfredoHernandez/AlfredoHernandez/main/alfredo_hdz.png" />
</p>

![CI-macOS](https://github.com/AlfredoHernandez/EssentialFeed/workflows/CI-macOS/badge.svg)
![CI-iOS](https://github.com/AlfredoHernandez/EssentialFeed/workflows/CI-iOS/badge.svg)

## App Architecture

![EssentialFeed](./images/architecture_overview.png)

## Architecture 

### Business Logic (loaders)

The `FeedLoader` protocol doesn't exists anymore, we reject dependencies. Now, our architecture for business logic looks like this:

![Dependency Rejection](./images/dependency-rejection.png)

### Presentation

We are reusing the presentation for both `Feed` and `Image Comments`

![Reusable Presentation](./images/reusable-presentation.png)

## UI

We are reusing the same table view to display the feed and comments


![Reusable UI](./images/reusable-ui.png)

## Snapshot Testing

**Please make sure use an `iPhone 12 Mini` simulator to run the snapshot tests. Otherwise tests will fail.**

## App Requirements

[BDD Specs](./docs/BDD_specs.md)

[Model Specs](./docs/model_specs.md)

[Feed Use Cases](./docs/use_cases.md)

[Feed Image Use Cases](./docs/feed_image_use_cases.md)

---
