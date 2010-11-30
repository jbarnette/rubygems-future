require "rubygems/test"
require "rubygems/installable/file"

class TestGemInstallableFile < Gem::Test
  def test_install
    repo do |source|
      foo = gem "foo", "1.0.0", :cache => true

      repo do |target|
        assert target.gems.empty?

        file = File.join source.cachedir, "#{foo.id}.gem"
        inst = Gem::Installable::File.new file

        inst.install target
        installed = target.gems.first

        assert_equal inst.gem, installed

        assert File.file?(installed.spec.loaded_from)
        assert File.directory?(File.join(target.gemdir, installed.id))
      end
    end
  end

  def test_spec
    repo do |r|
      foo = gem "foo", "1.0.0", :cache => true
      inst = Gem::Installable::File.new File.join(r.cachedir, "#{foo.id}.gem")
      assert_equal foo, inst.gem
    end
  end
end
