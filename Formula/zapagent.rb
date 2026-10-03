class Zapagent < Formula
  desc "Terminal AI agent with bundled local VM for Apple Silicon"
  homepage "https://github.com/JackCaow/zapcode-releases"
  url "https://github.com/JackCaow/zapcode-releases/releases/download/v1.14.6/zapAgent-macos-arm64-1.14.6-sparse.tar.gz"
  version "1.14.6"
  sha256 "797839952562ec309b920fd80e2f69a434b5bd6dd1dd5a72fd4486915c47c190"

  depends_on arch: :arm64
  depends_on :macos
  skip_clean "libexec"

  def install
    libexec.install Dir["*"]
    # Supply top-level metadata so Homebrew does not move the checksum-covered
    # README out of libexec during its automatic metadata installation.
    cp libexec/"README.md", prefix/"README.md"
    (bin/"zapAgent").write_env_script libexec/"start-local-vm.command", {}
    %w[zap zapcode].each { |command| bin.install_symlink "zapAgent" => command }
  end

  def caveats
    <<~EOS
      Apple Silicon only. Start from your project directory: zapAgent, zap or zapcode
      Configure your model with /connect. Data defaults to ~/.zapcode-vm.
      Commands run under the host OS sandbox by default; the bundled VM is opt-in (ZAPCODE_EXECUTION=vm). File tools and
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
    %w[zapAgent zap zapcode].each do |command|
      assert_match "zapAgent v1.14.6", shell_output("#{bin}/#{command} --version")
      assert_match "Usage:", shell_output("#{bin}/#{command} --help")
    end
    system "/usr/bin/codesign", "--verify", "--strict", libexec/"zap"
    system "/usr/bin/codesign", "--verify", "--strict", libexec/"zapvm-runtime/bin/zapvm"
    assert_match "virtualization-entitlement", shell_output("#{libexec}/zapvm-runtime/bin/zapvm doctor")
    cd libexec do
      system "/usr/bin/shasum", "-a", "256", "-c", "SHA256SUMS"
    end
  end
end
