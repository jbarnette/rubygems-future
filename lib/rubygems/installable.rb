module Gem

  # A protocol representing the ability to install a gem into a
  # <tt>Gem::Repo</tt>. The method of installation is intentionally
  # opaque: <tt>Gem::Installable::File</tt> unpacks a <tt>.gem</tt>
  # file into the repo, but other sources may just symlink an existing
  # directory, update and change refs in an SCM, etc.

  module Installable

    # The Gem::Info this instance knows how to install.

    def gem
      raise "#{self.class.name} needs to implement gem."
    end

    # Install the gem into +repo+.

    def install repo
      raise "#{self.class.name} needs to implement install."
    end
  end
end
