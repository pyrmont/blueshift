class Blues < Formula
  desc "Archive Bluesky posts to GitHub"
  homepage "https://github.com/pyrmont/blueshift"
  version "0.1.0"

  on_macos do
    on_arm do
      url "https://github.com/pyrmont/blueshift/releases/download/v#{version}/blueshift-v#{version}-macos-aarch64.tar.gz"
      sha256 "939b7a00ce5626daa45dadd624f87e8ce5debda69892fb9de3ee5d21cd68f007"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/pyrmont/blueshift/releases/download/v#{version}/blueshift-v#{version}-linux-aarch64.tar.gz"
      sha256 "58b1b6689f78929c3a37c30eacd50261f45b41521c08506d6dc525efa80fdd22"
    end

    on_intel do
      url "https://github.com/pyrmont/blueshift/releases/download/v#{version}/blueshift-v#{version}-linux-x86_64.tar.gz"
      sha256 "dd3417c492838ba1a7f2b89bb26ceb0aa17bf3f53cfd6b188f52343eb4bd3d8d"
    end
  end

  def install
    bin.install "blues"
    man1.install "blues.1"
    doc.install "README.md", "LICENSE"
  end

  test do
    assert_match "blues", shell_output("#{bin}/blues --help")
  end
end
