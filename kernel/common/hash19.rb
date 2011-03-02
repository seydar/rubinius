class Hash

  # Used to store the order of elements as they were initially inserted
  # Note that this is INSERTION, not UPDATING.
  ORDER = []

  def self.try_convert(x)
    return nil unless x.respond_to? :to_hash
    x.to_hash
  end

  alias_method :key, :index

  # Sets the default proc to be executed on each key lookup
  def default_proc=(proc)
    @default = Type.coerce_to(proc, Proc, :to_proc)
    @default_proc = true
  end

  # Alias the old method so that should the original implementation
  # change, the insertion order preservation trick won't have to be
  # changed as well.
  alias_method :__new_entry__, :new_entry

  # Keep track of the insertion order
  def new_entry(key, key_hash, value)
    entry = __new_entry__(key, key_hash, value)

    @order ||= []
    @order << entry
    entry.order = @order.size - 1

    entry
  end

  # Add the +@order+ ivar.
  # This will default to +nil+, which is obviously no good. But since it
  # should always be set in the 1.9 definition of +new_entry+, this will
  # highlight any errors, moreso than defaulting it to 0 would.
  class Entry
    attr_accessor :order
  end

  # Iterate over all of the elements in the hash, the oldest elements first.
  class Iterator
    attr_reader :order

    # The big change here is the addition of the +order+ parameter,
    # which specifies an array of elements in order from oldest to youngest.
    def initialize(entries, order, capacity)
      @entries  = entries
      @order    = order
      @capacity = capacity
      @index    = -1
    end

    def next(entry)
      @order[entry.index + 1]
    end
  end

  def to_iter
    Iterator.new @entries, @order, @capacity
  end

  # This is one of the basic methods for iterating over a Hash.
  # Enumerate over each entry in their insertion order, from oldest to newest.
  def each_entry
    return @order.to_enum :each unless block_given?

    @order.each { |x| yield x }
  end
end
