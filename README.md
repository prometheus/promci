# Prometheus Github Actions

Set of GitHub actions shared by GitHub projects in the Prometheus Ecosystem.

### Usage

```yaml
jobs:
  build:
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - uses: prometheus/promci/build@<sha> # v0.6.0

  publish_main:
    needs: [build]
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        uses: prometheus/promci/publish_main@<sha> # v0.6.0
        with:
          docker_hub_password: ${{ secrets.docker_hub_password }}
          quay_io_password: ${{ secrets.quay_io_password }}

  publish_release:
    needs: [build]
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        uses: prometheus/promci/publish_release@<sha> # v0.6.0
        with:
          docker_hub_password: ${{ secrets.docker_hub_password }}
          quay_io_password: ${{ secrets.quay_io_password }}
          github_token: ${{ secrets.PROMBOT_GITHUB_TOKEN }}
```
