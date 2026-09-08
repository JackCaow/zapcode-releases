class ZapVmPreview < Formula
  desc "Terminal AI agent with bundled VM (Apple Silicon preview)"
  homepage "https://github.com/JackCaow/zapcode-releases"
  url "https://github.com/JackCaow/zapcode-releases/releases/download/v1.12.0-vm-preview.1/zap-macos-arm64-full-local-20260908.tar.gz"
  version "1.12.0-vm-preview.1"
  sha256 "3bdb45755fcef9c4464821c34b793bdab038115bf3b9ff227775d30ea433f59b"

  depends_on arch: :arm64
  depends_on :macos

  # Preserve signed binaries and image manifest hashes byte-for-byte.
  skip_clean "libexec"

  def install
    libexec.install Dir["*"]
    # A direct symlink would make the launcher resolve its runtime beside bin/.
    (bin/"zap-vm-preview").write_env_script libexec/"start-local-vm.command", {}
  end

  def caveats
    <<~EOS
      Developer preview for Apple Silicon; not Apple-notarized.
      Start from your project directory:
        zap-vm-preview

      Configure your model with /connect on first launch.
      Data defaults to ~/.zapcode-local-vm; existing zap/zapdev are unchanged.
      The VM image is bundled. Remote model APIs still require connectivity.
      Host Agent process tools use the VM; this is not whole-Agent isolation.
      Stop active preview tasks and their VM daemon before upgrading/uninstalling.
      For the default profile, the stop command is:
        #{libexec}/zapvm-runtime/bin/zapvm daemon stop --endpoint "$HOME/.zapcode-local-vm/runtime-state/zapvm/daemon.sock"

      Guest error classification and the old embedded Resident Runner remain
      known limitations. See README-local.md, build-info.json, and the Guest
      SBOM/source-offer under #{libexec} for details.
    EOS
  end

  test do
    ENV["ZAPCODE_DATA_DIR"] = (testpath/"profile").to_s
    ENV.delete "ZAPCODE_ZAPVM_CLOUD_CONFIG"
    ENV.delete "ZAPCODE_DISABLE_ZAPVM"
    ENV.delete "ZAPCODE_RESIDENT_AGENT"
    ENV.delete "ZAPCODE_ZAPVM_RUNTIME_DIR"

    assert_match "zapcode v1.12.0", shell_output("#{bin}/zap-vm-preview --version")
    system "/usr/bin/codesign", "--verify", "--strict", libexec/"zapvm-runtime/bin/zapvm"
    assert_match "virtualization-entitlement", shell_output("#{libexec}/zapvm-runtime/bin/zapvm doctor")
    cd libexec do
      system "/usr/bin/shasum", "-a", "256", "-c", "SHA256SUMS"
    end
  end
end
