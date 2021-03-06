# typed: false
# frozen_string_literal: true

# UniversalCtags
class UniversalCtags < Formula
  desc "Maintained ctags implementation"
  homepage "https://github.com/universal-ctags/ctags"
  url "https://github.com/universal-ctags/ctags/archive/p5.9.20201018.0.tar.gz"
  sha256 "1ec29b2f2fb6eced99181931c3ed28dfe19f56466a43835c783af45dbf7b9e0f"
  license "GPL-2.0-or-later"
  head "https://github.com/universal-ctags/ctags.git"
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "docutils" => [:build, :optional]
  depends_on "pkg-config" => :build
  depends_on "jansson" => :optional
  depends_on "libyaml" => :optional
  conflicts_with "ctags", :because => "this formula installs the same executable as the ctags formula"

  def install
    opts = []
    if OS.linux?
      py_formula = Formula["docutils"].recursive_dependencies.map(&:name).find { |n| n.include?("python") }
      py_ldflags = `#{Formula[py_formula].opt_bin}/python3-config --ldflags`
      opts << "PYTHON_EXTRA_LDFLAGS=#{py_ldflags.chomp}"
    end
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", *opts
    system "make"
    system "make", "install"
  end

  def caveats
    <<~EOS
      Under some circumstances, emacs and ctags can conflict. By default,
      emacs provides an executable `ctags` that would conflict with the
      executable of the same name that ctags provides. To prevent this,
      Homebrew removes the emacs `ctags` and its manpage before linking.
      However, if you install emacs with the `--keep-ctags` option, then
      the `ctags` emacs provides will not be removed. In that case, you
      won't be able to install ctags successfully. It will build but not
      link.
    EOS
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <stdlib.h>

      void func()
      {
        printf("Hello World!");
      }

      int main()
      {
        func();
        return 0;
      }
    EOS
    system "#{bin}/ctags", "-R", "."
    assert_match(/func.*test\.c/, File.read("tags"))
  end
end
