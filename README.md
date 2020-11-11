#  Essential Feed iOS Application

<p align="center">
  <img src="https://raw.githubusercontent.com/AlfredoHernandez/AlfredoHernandez/main/alfredo_hdz.png" />
</p>

![CI-macOS](https://github.com/AlfredoHernandez/EssentialFeed/workflows/CI-macOS/badge.svg)
![CI-iOS](https://github.com/AlfredoHernandez/EssentialFeed/workflows/CI-iOS/badge.svg)

## App Architecture

![EssentialFeed](./images/architecture_overview.png)

## Architecture 

The `FeedLoader` protocol doesn't exists anymore, so we reject dependencies. Now, our architecture looks like this:

![Dependency Rejection](./images/dependency-rejection.png)

## App Requirements

[BDD Specs](./docs/BDD_specs.md)

[Model Specs](./docs/model_specs.md)

[Feed Use Cases](./docs/use_cases.md)

[Feed Image Use Cases](./docs/feed_image_use_cases.md)

---
