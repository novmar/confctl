module ConfCtl
  class Swpins::Specs::Base
    class << self
      attr_reader :type

      # @param name [Symbol]
      def handle(name)
        @type = name
        Swpins::Spec.register(name, self)
      end
    end

    # @return [String]
    attr_reader :name

    # @param [String]
    # @return [String, nil]
    attr_accessor :channel

    # @param name [String]
    # @param gopts [Hash]
    # @param spec_opts [Hash]
    # @param fetcher_opts [Hash]
    def initialize(name, gopts, spec_opts, fetcher_opts = {})
      @name = name
      @gopts = gopts
      @spec_opts = spec_opts
      @fetcher_opts = fetcher_opts
      @channel = gopts[:channel]
    end

    def type
      self.class.type
    end

    def version
      raise NotImplementedError
    end

    def prefetch(override_opts = {})
      raise NotImplementedError
    end

    def as_json
      ret = {}
      ret[:channel] = channel if channel
      ret[:type] = type.to_s
      ret[:fetcher] = gopts[:fetcher]
      ret[:handler] = gopts[:handler] if gopts[:handler]
      ret[:spec_options] = spec_opts
      ret[:fetcher_options] = fetcher_opts
      ret
    end

    def to_json(*args)
      as_json.to_json(*args)
    end

    protected
    # @return [Hash]
    attr_reader :gopts

    # @return [Hash]
    attr_reader :spec_opts

    # @return [Hash]
    attr_reader :fetcher_opts
  end
end
