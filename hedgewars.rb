require "language/haskell"

class Hedgewars < Formula
  include Language::Haskell::Cabal

  desc "Turn-based strategy/artillery/action and comedy game"
  homepage "http://www.hedgewars.org"
  url "http://download.gna.org/hedgewars/hedgewars-src-0.9.22.tar.bz2"
  sha256 "b699c8971ff420c3edd6533527ae2e99040f1e79207c9140826945bcf0e62192"
  head "https://code.google.com/p/hedgewars/", :using => :hg

  bottle do
    cellar :any
    sha256 "610d40fdded988fe751f9fbae0ff88101b6bb3280ffa1887ed42988d607cdf1f" => :el_capitan
    sha256 "5747caf4e9d9fc043ef5293e8f4f738aa90f83b72a14113e5193bfcfdb3bf306" => :yosemite
    sha256 "9ab2e4f4c7bf03944110c77c3215d9349f047af408d97bf7be2c996162adf34b" => :mavericks
  end

  option "with-server", "Enable local LAN play"
  option "with-videorec", "Enable video recording"

  depends_on "cmake" => :build
  depends_on "fpc" => :build
  depends_on "qt"
  depends_on "physfs"
  depends_on "libpng"
  depends_on "lua51"
  depends_on "sdl"
  depends_on "sdl_image"
  depends_on "sdl_net"
  depends_on "sdl_mixer" => "with-libvorbis"
  depends_on "sdl_ttf"
  depends_on "ffmpeg" if build.with? "videorec"

  if build.with? "server"
    depends_on "ghc" => :build
    depends_on "cabal-install" => :build
    depends_on "gmp"
    setup_ghc_compilers
  end

  def install
    # rely on homebrew update, packaging, and source system
    args = %w[-DNOAUTOUPDATE=1 -DSKIPBUNDLE=1 -DPHYSFS_SYSTEM=1 -DLUA_SYSTEM=1]

    args << "-DGL2=1" if build.with? "gl2"
    args << "-DNOSERVER=1" if build.without? "server"
    args << "-DNOVIDEOREC=1" if build.without? "videorec"
    args << "-DCMAKE_BUILD_TYPE=Debug" if build.head?

    # this will prepare all server dependencies
    if build.with? "server"
      cabal_sandbox do
        cabal_install "--only-dependencies", "gameServer/hedgewars-server.cabal"
      end
      cabal_clean_lib
    end
    system "cmake", ".", *(std_cmake_args + args)
    system "make", "install"
    prefix.install "Hedgewars.app"
  end

  test do
    system prefix/"Hedgewars.app/Contents/MacOS/hedgewars", "--help"
  end
end
