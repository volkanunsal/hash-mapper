# frozen_string_literal: true

# see: http://djellemah.com/blog/2013/10/09/instance-eval-with-access-to-outside-scope/
class Combinder < BasicObject
  def initialize(obj, saved_binding)
    @obj, @saved_binding = obj, saved_binding
  end

  def __bound_self__
    @saved_binding.eval('self')
  end

  def method_missing(meth, *args, &blk)
    # methods in dsl object are called in preference to self outside the block
    if @obj.respond_to?(meth)
      # dsl method, so call it
      @obj.send meth, *args, &blk
    else
      __bound_self__.send meth, *args, &blk
    end
  end

  def respond_to_missing?(meth, _include_all)
    __bound_self__.respond_to?(meth) || @obj.respond_to?(meth)
  end
end
