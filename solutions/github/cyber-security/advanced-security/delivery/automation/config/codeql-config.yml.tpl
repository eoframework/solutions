name: "CodeQL Configuration"

# Languages to analyze
languages:
%{ for lang in split(",", languages) ~}
  - ${trimspace(lang)}
%{ endfor ~}

# Query suites
queries:
  - uses: ${query_suites}

# Paths to exclude from analysis
paths-ignore:
  - '**/test/**'
  - '**/tests/**'
  - '**/spec/**'
  - '**/node_modules/**'
  - '**/vendor/**'
  - '**/build/**'
  - '**/dist/**'
  - '**/target/**'
  - '**/*.min.js'
  - '**/*.bundle.js'

# Paths to include
paths:
  - 'src/**'
  - 'lib/**'
  - 'app/**'

%{ if custom_queries_repo != "" ~}
# Custom queries
packs:
  - ${custom_queries_repo}
%{ endif ~}
