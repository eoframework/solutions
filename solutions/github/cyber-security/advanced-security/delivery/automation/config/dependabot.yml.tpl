version: 2
updates:
%{ for ecosystem in split(",", package_ecosystems) ~}
  - package-ecosystem: "${trimspace(ecosystem)}"
    directory: "/"
    schedule:
      interval: "${schedule}"
    open-pull-requests-limit: 10
    reviewers:
      - "security-team"
    labels:
      - "dependencies"
      - "security"
    commit-message:
      prefix: "chore"
      include: "scope"
    ignore:
      # Ignore major version updates for stable dependencies
      - dependency-name: "*"
        update-types: ["version-update:semver-major"]
%{ endfor ~}
