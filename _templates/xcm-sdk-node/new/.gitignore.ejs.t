---
to: .gitignore
---
node_modules
dist

# Local secrets — never commit a PRIVATE_KEY, mnemonic, or RPC key.
.env
.env.local
.env.*.local

*.log
.DS_Store
