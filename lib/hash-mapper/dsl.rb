# frozen_string_literal: true

require_relative './combinder'

class HashMapper
  class Dsl
    attr_reader :keys

    def initialize(&block)
      @keys = []
      evaluate(&block) if block_given?
    end

    def each_key
      @keys.each { |k| yield(k) }
    end

    def evaluate(&block)
      case block.arity
      when 0
        Combinder.new(self, block.binding).instance_eval(&block)
      when 1
        yield self
      else
        raise "Too many args for block"
      end
    end

    class Key
      attr_reader *%i[name source create then_block merge allow_nil if_key value]

      def initialize(name: nil, source: nil, create: nil, then_block: nil, merge: nil, allow_nil: nil, if_key: nil, value: nil)
        @name = name
        @source = source
        @create = create
        @then_block = then_block
        @merge = merge
        @allow_nil = allow_nil
        @if_key = if_key
        @value = value
      end
    end

    def merge(*opts, &block)
      hash_opts = opts.select { |v| v.kind_of?(Hash) }.inject(&:merge) || {}
      source = hash_opts.fetch(:source) { [] }
      then_block = block || hash_opts[:then]

      # Normalize source
      source =  case source
                when Array
                  source
                when Symbol
                  [source]
                end

      @keys.push Key.new(merge: true, then_block: then_block, source: source)
    end

    # opts -
    #   source - Symbol | [Symbol]
    #   create - Symbol
    #   allow_nil - Symbol
    #
    def key(name, *opts)
      hash_opts = opts.select { |v| v.kind_of?(Hash) }.inject(&:merge) || {}
      source = hash_opts[:source]
      then_block = hash_opts[:then]
      value = hash_opts[:eq]
      if_key = hash_opts.fetch(:if_key) { [] }
      create = opts.empty? || opts.include?(:create) || opts.include?(:allow_nil)
      allow_nil = opts.include?(:allow_nil)

      # TODO: validate the option keys.

      # Normalize source
      source =  case source
                when Array
                  source
                when Symbol
                  [source]
                else
                  # Use the key as value source when source is missing
                  [name]
                end

      # Normalize if_key
      if_key =  case if_key
                when Array
                  if_key
                when Symbol
                  [if_key]
                end

      # -- Sanity check
      raise ArgumentError.new("A :then block is required if a key has multiple sources.") if source.size > 1 && !then_block

      @keys.push Key.new(
        name: name,
        source: source,
        create: create,
        allow_nil: allow_nil,
        then_block: then_block,
        if_key: if_key,
        value: value
      )
    end
  end
end
