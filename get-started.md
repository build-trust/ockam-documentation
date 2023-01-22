# Get Started

### Install Ockam Command

If you use Homebrew, you can install Ockam using brew.

```bash
brew install build-trust/ockam/ockam
```

Otherwise, you can download our latest architecture specific pre-compiled binary by running:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/build-trust/ockam/develop/install.sh | sh
```

After the binary downloads, please move it to a location in your shell's $PATH, like /usr/local/bin.

#### Check Your Install

Check that your install has worked successfully by enrolling with the Ockam Orchestrator:

```bash
ockam enroll
```
