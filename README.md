# Prometheus Github Actions

Set of GitHub actions shared by GitHub projects in the Prometheus Ecosystem.

### Usage

For a full working release example, see [examples/ci.yml](examples/ci.yml).

```yaml
jobs:
  build:
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - uses: prometheus/promci/build@<sha> # v0.6.0

  publish_main:
    needs: [build]
    steps:
        uses: prometheus/promci/publish_main@<sha> # v0.6.0
        with:
          docker_hub_password: ${{ secrets.docker_hub_password }}
          quay_io_password: ${{ secrets.quay_io_password }}

  publish_release:
    needs: [build]
    permissions:
      contents: write
    steps:
        uses: prometheus/promci/publish_release@<sha> # v0.6.0
        with:
          docker_hub_password: ${{ secrets.docker_hub_password }}
          quay_io_password: ${{ secrets.quay_io_password }}
          github_token: ${{ github.token }}
```

### Approving pull request workflows

The workflow approval action lets a trusted collaborator approve CI runs from
public forks when the collaborator comments `/workflow-approve` on
the pull request. The commenter must have triage access or higher.

Use the action from a workflow triggered by `issue_comment`:

```yaml
jobs:
  approve:
    runs-on: ubuntu-latest
    permissions:
      actions: write
      contents: read
      pull-requests: write
    steps:
      - uses: prometheus/promci/approve_workflows@<sha>
        with:
          github_token: ${{ github.token }}
```

Pin the action to a full commit SHA.
