class Zapagent < Formula
  desc "Terminal AI agent with bundled local VM for Apple Silicon"
  homepage "https://github.com/JackCaow/zapcode-releases"
  url "https://github.com/JackCaow/zapcode-releases/releases/download/v1.13.0/zapAgent-macos-arm64-1.13.0.tar.gz"
  version "1.13.0"
  sha256 "e220ab2105828fd4f48b60f0a6c5605014b930c5d511b6e8257c975607c72ea3"

  depends_on arch: :arm64
  depends_on :macos
  skip_clean "libexec"

  def install
    libexec.install Dir["*"]
    (bin/"zapAgent").write_env_script libexec/"start-local-vm.command", {}
  end

  def caveats
    <<~EOS
      Apple Silicon only. Start from your project directory: zapAgent
      Configure your model with /connect. Data defaults to ~/.zapcode-vm.
      The Host Agent uses the bundled VM for process tools; file tools and
      MCP are not whole-Agent isolated. No model or API key is included.
      Signed with Developer ID and notarized by Apple. The tar package is
      not stapled; first-launch Gatekeeper verification requires connectivity.
      Existing zapdev and the separate zap-vm-preview package are unchanged.
      Stop active tasks and the VM daemon before upgrading or uninstalling:
        #{libexec}/zapvm-runtime/bin/zapvm daemon stop --endpoint "$HOME/.zapcode-vm/runtime-state/zapvm/daemon.sock"
    EOS
  end

  test do
    ENV["ZAPCODE_DATA_DIR"] = (testpath/"profile").to_s
    %w[ZAPCODE_ZAPVM_CLOUD_CONFIG ZAPCODE_DISABLE_ZAPVM ZAPCODE_RESIDENT_AGENT ZAPCODE_ZAPVM_RUNTIME_DIR].each { |name| ENV.delete name }
    assert_match "zapAgent v1.13.0", shell_output("#{bin}/zapAgent --version")
    system "/usr/bin/codesign", "--verify", "--strict", libexec/"zap"
    system "/usr/bin/codesign", "--verify", "--strict", libexec/"zapvm-runtime/bin/zapvm"
    assert_match "virtualization-entitlement", shell_output("#{libexec}/zapvm-runtime/bin/zapvm doctor")
    cd libexec do
      system "/usr/bin/shasum", "-a", "256", "-c", "SHA256SUMS"
    end
  end
end
