class Vcpkg < Formula
  desc "C++ Library Manager from Microsoft"
  homepage "https://github.com/microsoft/vcpkg"
  url "https://github.com/microsoft/vcpkg.git",
      tag:      "2025.04.09", # You can pin a tag or use HEAD
      revision: " ce613c4"     # Optional: pin to a commit
  version "2025.04.09"
  head "https://github.com/microsoft/vcpkg.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "fmt" => :build


  def install
    system "./bootstrap-vcpkg.sh"
    bin.install "vcpkg"
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      To use vcpkg with CMake, set:
        export VCPKG_ROOT=#{opt_prefix}
        export PATH=#{opt_bin}:$PATH

      And run cmake with:
        cmake -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake
    EOS
  end


  def post_uninstall
    vcpkg_root = ENV["VCPKG_ROOT"] || "#{Dir.home}/.vcpkg"
    
    ohai "Removing VCPKG_ROOT directory at #{vcpkg_root}..."
    system "rm", "-rf", vcpkg_root if File.directory?(vcpkg_root)

    ohai "Removing ~/.vcpkg directory..."
    system "rm", "-rf", "#{Dir.home}/.vcpkg" if File.directory?("#{Dir.home}/.vcpkg")

    # Unset env var only affects current shell, so just print reminder
    ohai "Reminder: Unset VCPKG_ROOT in your shell environment manually if needed."
  end

  def caveats
    <<~EOS
      To fully clean your environment after uninstalling vcpkg:
        - Remove any leftover directories: ~/.vcpkg and $VCPKG_ROOT if customized
        - Unset environment variables like VCPKG_ROOT manually, for example:
            unset VCPKG_ROOT
            export PATH=$(echo $PATH | tr ':' '\\n' | grep -v vcpkg | paste -sd ':' -)
    EOS
  end
end
