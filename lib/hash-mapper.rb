# frozen_string_literal: true

require "bundler/setup"
require "hashie"
require "hash-mapper/dsl"

class HashMapper
  VERSION = "0.0.1"

  def initialize(opts = [], &blk)
    @opts = case opts
            when Array
              { keep: opts }
            when Hash
              opts
            end
    @mapper = Dsl.new
    @mapper.evaluate(&blk) unless blk.nil?
  end

  def run(object = {}, state = {})
    object = object
    state = state.dup
    state = process_initializer(object, state)
    _run(object, state)
  end
  alias call run

  private

    def process_initializer(object, state)
      keep = @opts[:keep] || []
      exclude = @opts[:except] || []

      # Sanity check
      raise ArgumentError.new('The option :keep must be an array.') unless keep.kind_of?(Array)

      # Sanity check
      raise ArgumentError.new('The option :except must be an array.') unless exclude.kind_of?(Array)

      unless keep.empty?
        # Ensure we only pick the keys that are in the input object.
        keep.select { |k| object.has_key?(k) }.each do |k|
          state[k] = object[k]
        end
      end

      unless exclude.empty?
        object.each do |k, v|
          state[k] = k unless exclude.include?(v)
        end
      end

      state
    end

    class Context
      attr_reader :input, :value, :state
      attr_writer :state

      def initialize(input, state, value)
        @input = input
        @state = state
        @value = value
      end
    end

    class Input < Hashie::Mash
      disable_warnings
    end

    def _run(input, state)
      input = Input.new(input)

      @mapper.each_key do |config|
        name = config.name
        source = config.source
        then_block = config.then_block
        create = config.create
        allow_nil = config.allow_nil
        merge = config.merge
        if_key = config.if_key
        value = config.value

        # Skip the iteration if the if_key condition is not met.
        next if if_key && if_key.all? { |k| input.key?(k) } == false

        if merge
          # TODO: test
          next if source && !source.all? { |k| input.key?(k) }

          # If the source has only one element, just take its value.
          value = if source.size == 1
                    input.send(source.first)
                  elsif source.size > 1
                    source.map { |k| input.send(k) }
                  end

          ctx = Context.new(input, state, value)

          res = then_block.call(ctx)
          state.merge!(res) if res.kind_of?(Hash)

          next
        # If the keys in the source are present OR key is creatable...
        elsif source.any? { |k| input.key?(k) } && value.nil?
          # If the source has only one element, just take its value.
          value = if source.size == 1
                    input.send(source.first)
                  elsif source.size > 1
                    source.map { |k| input.send(k) }
                  end

          ctx = Context.new(input, state, value)

          # If there is a then_block, pass it the ctx. And assign its outcome
          # to the key.
          value = then_block.call(ctx) unless then_block.nil?
        elsif create
          ctx = Context.new(input, state, nil)

          # if there is a then_block, pass it the ctx. And assign its outcome
          # to the key.
          value = then_block.call(ctx) unless then_block.nil?
        end

        # If the key is creatable or the value is non-nil,
        # assign value to the key in the state.
        state[name] = value if allow_nil || !value.nil?
      end

      state
    end
end
