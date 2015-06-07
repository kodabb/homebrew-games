require "language/haskell"

class Hedgewars < Formula
  include Language::Haskell::Cabal

  desc "A turn based strategy/artillery/action and comedy game"
  homepage "http://www.hedgewars.org"
  version "0.9.21"

  stable do
    url "http://download.gna.org/hedgewars/hedgewars-src-0.9.21.1.tar.bz2"
    sha256 "590a9458d2123c5550d5eb39edfed28d0663703d76e13c8987237c92ca41f3f8"

    patch do
      url "http://hedgewars.org/files/patches/all.php"
      sha256 "ee8f4e702197b7908e7fd8124fbbb54a4c7cf3792b1de2ff29a4e709ce721cbd"
    end
  end

  head "https://code.google.com/p/hedgewars/", :using => :hg

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
    # homebrew fpc does not set this path in /etc/fpc.cfg
    fpcversion = `fpc -iW`.chomp
    fpcpath = "#{Formula["fpc"].opt_lib}/fpc/"
    args << "-DCMAKE_Pascal_FLAGS=-Fu" + fpcpath + fpcversion + "/units/x86_64-darwin/*/"

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
