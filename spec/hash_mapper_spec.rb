require "spec_helper"

describe HashMapper do
  describe '#process_initializer' do
    describe 'passing keys of object via initializer argument' do
      describe 'without arguments' do
        subject { HashMapper.new.run({ foo: 1, bar: 2 }) }
        it { is_expected.to_not include(:foo) }
        it { is_expected.to_not include(:bar) }
      end
      describe 'with arguments' do
        subject { HashMapper.new([:foo]).run({foo: 1, bar: 2}) }
        it { is_expected.to include(:foo) }
        it { is_expected.to_not include(:bar) }
      end
    end
  end

  describe 'Dsl' do
    let(:opts) { {} }
    let(:state) { {} }
    let(:input) { {} }
    subject { HashMapper.new(opts, &block).run(input, state) }
    describe 'maps source keys to target key' do
      let(:input) { { foo: 1, bar: 2 } }
      let(:block) {
        proc do
          key :foo
          key :bar
        end
      }
      it { is_expected.to include(:foo => 1, :bar => 2) }
    end

    describe 'uses the return value of the block when a block is given' do
      let(:input) { { foo: 1 } }
      let(:block) {
        proc do
          key :foo, then: proc { |o| o.value + 2  }
        end
      }
      it { is_expected.to include(:foo => 3) }
    end

    describe 'assigns values statically using :eq option' do
      let(:input) { { foo: 1 } }
      let(:block) {
        proc do
          key :foo, eq: :bar
        end
      }
      it { is_expected.to include(:foo => :bar) }
    end

    describe 'conditionally assigns the value if a key is present in the input' do
      describe 'present' do
        let(:input) { { bar: 1 } }
        let(:block) {
          proc do
            key :foo, eq: :bar, if_key: :bar
          end
        }
        it { is_expected.to include(:foo => :bar) }
      end

      describe 'not present' do
        let(:block) {
          proc do
            key :foo, eq: :bar, if_key: :bar
          end
        }
        it { is_expected.to be_empty }
      end
    end

    describe 'assigns values statically using :eq option' do
      let(:block) {
        proc do
          key :foo, :create, eq: :bar
        end
      }
      it { is_expected.to include(:foo => :bar) }
    end

    describe 'threads state through the transformers' do
      let(:block) {
        proc do
          key :foo, :create, eq: :bar
          key :bar, :create, then: proc { |o| o.state[:foo] }
        end
      }
      it { is_expected.to include(:foo => :bar, :bar => :bar) }
    end

    describe 'allows deletion of keys from state inside a proc' do
      let(:block) {
        proc do
          key :foo, eq: :bar
          key :bar, then: proc { |o| delete o.state[:foo] }
        end
      }
      it { is_expected.to include(:foo => :bar) }
    end

    describe 'allows passing prior state to `run` method' do
      let(:block) {
        proc do
          key :bar, :create, then: proc { |o| o.state[:foo] }
        end
      }
      let(:state) { { :foo => 1 } }
      it { is_expected.to include(:foo => 1, :bar => 1) }
    end

    describe 'omits nil values by default' do
      let(:block) {
        proc do
          key :bar, :create, then: proc { nil }
        end
      }
      it { is_expected.to be_empty }
    end

    describe 'allows nil values with :allow_nil' do
      let(:block) {
        proc do
          key :bar, :create, :allow_nil, then: proc { nil }
        end
      }
      it { is_expected.to include(:bar => nil) }
    end

    describe 'merges the result of block when merge is used' do
      let(:block) {
        proc do
          merge { |o| { bar: o.state[:foo] + 1 } }
        end
      }
      let(:state) { { :foo => 1 } }
      it { is_expected.to include(:bar => 2) }
    end

    describe 'accepts source for merge' do
      let(:input) { { qu: 4 } }
      let(:block) {
        proc do
          merge source: :qu, then: proc { |o| { bar: o.value + 1 } }
        end
      }
      it { is_expected.to include(:bar => 5) }
    end

    describe 'accepts multiple sources' do
      let(:block) {
        proc do
          key :foo, source: [:foo, :bar], then: proc { |o| o.value.compact.join(',') }
        end
      }
      describe 'both sources present' do
        let(:input) { { foo: 'a', bar: 'b' } }
        it { is_expected.to include(:foo => 'a,b') }
      end

      describe 'one source present' do
        let(:input) { { foo: 'a' } }
        it { is_expected.to include(:foo => 'a') }
      end

      describe 'no source present' do
        let(:input) { {} }
        it { is_expected.to_not include(:foo) }
      end
    end
  end
end
