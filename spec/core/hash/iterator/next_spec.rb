require File.expand_path('../../../../spec_helper', __FILE__)

describe "Hash::Iterator#next" do
  it "returns each non-nil entry from the storage vector" do
    h = Hash.new
    a = h.new_entry 1, 2, 3
    c = h.new_entry 7, 8, 9
    b = h.new_entry 4, 5, 6
    e = h.instance_variable_get :@entries
    e[2] = a
    e[7] = c
    e[4] = b

    iter = h.to_iter

    values = []
    while entry = iter.next(entry)
      values << entry
    end
    values.should == [a, c, b]
  end
end
