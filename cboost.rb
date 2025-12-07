class Cboost < Formula
  desc "A C++ Library for making complex games with high graphics (supports shaders)"
  homepage "https://github.com/Chayce22315/CBoost"
  url "https://github.com/Chayce22315/CBoost/archive/refs/tags/REAL-1.0.1.tar.gz"
  version "1.0.1"
  sha256 "c79f29641755b860de91a97581611db2a1d1918c6c53c6ab854766c2a5419c05"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "openssl"

  resource "glfw" do
    url "https://github.com/glfw/glfw/releases/download/3.3.10/glfw-3.3.10.zip"
    sha256 "f9d3c4e10ec7a448c92e1f1e3b82ed8b6c0ff82d6ed5b0f9283c38ef0e1f3f0a"
  end

  resource "glad" do
    url "https://github.com/Dav1dde/glad/archive/refs/tags/v0.1.36.tar.gz"
    sha256 "8c172fb3d2b07d7d1281f9112a0f4a1d0e8d985a7a94f810ecb87df1b5d6d4e0"
  end

  def install
    # Build GLFW
    resource("glfw").stage do
      mkdir "build" do
        system "cmake", "..", *std_cmake_args, "-DBUILD_SHARED_LIBS=OFF"
        system "cmake", "--build", "."
        system "cmake", "--install", ".", "--prefix=#{buildpath}/glfw-install"
      end
    end

    # Build GLAD
    resource("glad").stage do
      mkdir "build" do
        system "cmake", "..", *std_cmake_args
        system "cmake", "--build", "."
        system "cmake", "--install", ".", "--prefix=#{buildpath}/glad-install"
      end
    end

    # Build CBoost
    mkdir "build" do
      system "cmake", "..",
             "-DGLFW_INCLUDE_DIR=#{buildpath}/glfw-install/include",
             "-DGLFW_LIBRARY=#{buildpath}/glfw-install/lib/libglfw3.a",
             "-DGLAD_INCLUDE_DIR=#{buildpath}/glad-install/include",
             "-DGLAD_LIBRARY=#{buildpath}/glad-install/lib/libglad.a",
             *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <cboost/engine.hpp>
      int main() {
        cboost::Engine engine;
        return 0;
      }
    EOS

    system ENV.cxx, "test.cpp", "-std=c++17", "-o", "test"
    system "./test"
  end
endp