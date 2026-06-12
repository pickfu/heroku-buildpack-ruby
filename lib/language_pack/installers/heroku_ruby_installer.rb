require 'language_pack/installers/ruby_installer'
require 'language_pack/base'
require 'language_pack/shell_helpers'
require 'fileutils'

class LanguagePack::Installers::HerokuRubyInstaller
  include LanguagePack::ShellHelpers, LanguagePack::Installers::RubyInstaller

  BASE_URL = LanguagePack::Base::VENDOR_URL

  def initialize(stack)
    @fetcher = LanguagePack::Fetcher.new(BASE_URL, stack)
  end

  def fetch_unpack(ruby_version, install_dir, build = false)
    FileUtils.mkdir_p(install_dir)
    Dir.chdir(install_dir) do
      file = "#{ruby_version.version_for_download}.tgz"
      if build
        file.sub!("ruby", "ruby-build")
      end
      @fetcher.fetch_untar(file)
      # PickFu: the heroku-16 ruby-2.3.6 binary links libreadline.so.6, which
      # heroku-18 doesn't ship — shim the stack's .so.7 in under that name.
      # Native heroku-18 rubies (2.6.10+, M2) link the stack readline directly
      # and have no 2.3.0 ABI dir, so skip when absent.
      legacy_readline_dir = "#{Dir.pwd}/lib/ruby/2.3.0/x86_64-linux"
      if File.directory?(legacy_readline_dir)
        FileUtils.cp("/lib/x86_64-linux-gnu/libreadline.so.7.0", "#{legacy_readline_dir}/libreadline.so.6")
      end
    end
  end
end

