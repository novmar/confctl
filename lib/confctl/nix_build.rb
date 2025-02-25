module ConfCtl
  class NixBuild
    # @param args [Array<String>]
    # @param swpin_paths [Hash<String>]
    def initialize(args, swpin_paths)
      @args = args
      @swpin_paths = swpin_paths
      @build_progress = 0
      @build_total = 0
      @fetch_progress = 0
      @fetch_total = 0
    end

    # @yieldparam type [:build, :fetch]
    # @yieldparam progress [Integer]
    # @yieldparam total [Integer]
    # @yieldparam path [String]
    def run(&block)
      cmd = SystemCommand.new

      line_buf = LineBuffer.new do |out, err|
        parse_line(err, &block) if err && block
      end

      ret = cmd.run(
        'nix-build',
        *args,
        env: {'NIX_PATH' => build_nix_path(swpin_paths)},
        &line_buf.feed_block
      )

      line_buf.flush
      ret
    end

    protected
    attr_reader :args, :swpin_paths

    def parse_line(line)
      # Beware that nix-build can fetch/build stuff even before those two
      # summary lines are printed. Therefore we report progress with total=0
      # (indeterminate) until the total becomes known.

      if /^these derivations will be built:/ =~ line
        @in_derivation_list = true
        @in_fetch_list = false
        return
      elsif /^these paths will be fetched / =~ line
        @in_derivation_list = false
        @in_fetch_list = true
        return
      end

      if @in_derivation_list
        if /^\s+\/nix\/store\// =~ line
          @build_total += 1
          return
        else
          @in_derivation_list = false
          @build_total += @build_progress
        end

      elsif @in_fetch_list
        if /^\s+\/nix\/store\// =~ line
          @fetch_total += 1
          return
        else
          @in_fetch_list = false
          @fetch_total += @fetch_progress
        end
      end

      if /^building '([^']+)/ =~ line
        @build_progress += 1
        yield(:build, @build_progress, @build_total, $1)
      elsif/^copying path '([^']+)/ =~ line
        @fetch_progress += 1
        yield(:fetch, @fetch_progress, @fetch_total, $1)
      end
    end

    def build_nix_path(swpins)
      paths = []
      paths << "confctl=#{ConfCtl.root}"
      paths.concat(swpins.map { |k, v| "#{k}=#{v}" })
      paths.concat(Settings.instance.nix_paths)
      paths.join(':')
    end
  end
end
