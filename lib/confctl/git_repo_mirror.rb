require 'digest'
require 'fileutils'

module ConfCtl
  class GitRepoMirror
    attr_reader :url, :name

    # @param url [String]
    # @param quiet [Boolean]
    def initialize(url, quiet: false)
      @url = url
      @quiet = quiet
      @name = Digest::SHA256.hexdigest(url)
    end

    def setup
      begin
        File.stat(mirror_path)
      rescue Errno::ENOENT
        FileUtils.mkdir_p(mirror_path)
        git("clone", args: ["--mirror", "\"#{url}\"", "\"#{mirror_path}\""])
      else
        git_repo('fetch')
      end
    end

    def revision_parse(str)
      git_repo("rev-parse", args: [str])
    end

    protected
    attr_reader :quiet

    def git_repo(cmd, *args, **kwargs)
      kwargs[:gopts] ||= []
      kwargs[:gopts] << "-C \"#{mirror_path}\""
      git(cmd, *args, **kwargs)
    end

    def git(cmd, args: [], opts: [], gopts: [])
      opts << '--quiet' if quiet

      full_cmd = (['git'] + gopts + [cmd] + opts + args).join(' ')
      ret = `#{full_cmd}`.strip

      if $?.exitstatus != 0
        fail "#{full_cmd} failed with exit status #{$?.exitstatus}"
      end

      ret
    end

    def mirror_path
      File.join(mirror_dir, name)
    end

    def mirror_dir
      File.join(ConfCtl.cache_dir, 'git-mirrors')
    end
  end
end
