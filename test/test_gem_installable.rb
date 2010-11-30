require "rubygems/test"
require "rubygems/installable"

class TestGemInstallable < Gem::Test
  include Gem::Installable

  def test_install
    ex = assert_raises RuntimeError do
      install nil
    end

    assert_match(/implement/, ex.message)
  end

  def test_spec
    ex = assert_raises RuntimeError do
      gem
    end

    assert_match(/implement/, ex.message)
  end
end
