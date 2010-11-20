require "rubygems/future/test"
require "rubygems/installable/file"

class TestGemInstallableFile < Gem::Future::Test
  def test_install
    repo do |source|
      foo = gem "foo", "1.0.0", :cache => true

      repo do |target|
        assert target.specs.empty?

        file = File.join(source.cachedir, foo.file_name)
        inst = Gem::Installable::File.new file

        inst.install target
        installed = target.specs.first

        assert_equal inst.spec, installed

        assert File.file?(installed.loaded_from)
        assert File.directory?(File.join(target.gemdir, installed.full_name))
      end
    end
  end

  def test_spec
    repo do |r|
      foo = gem "foo", "1.0.0", :cache => true
      inst = Gem::Installable::File.new File.join(r.cachedir, foo.file_name)
      assert_equal foo, inst.spec
    end
  end
end
