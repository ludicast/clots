require File.dirname(__FILE__) + '/spec_helper'

class ChildModel
  def parent
    "parent"
  end

  def tags
    ["tag1", "tag2"]
  end

  def tag_ids
    [1, 2]
  end

end

describe "A Drop" do
  before do

  end


  context "when belongs to an item" do
    it "should delegate belong_to calls to its source object" do
      class BaseDropWithBelongsTo
        extend Clot::DropAssociation

        def initialize
          @source = ChildModel.new
        end

        belongs_to :parent
      end
      drop = BaseDropWithBelongsTo.new
      drop.parent.should == "parent"

    end

  end

  context "when has many of an item" do

    before(:all) do
      class BaseDropWithHasMany
        extend Clot::DropAssociation

        def initialize
          @source = ChildModel.new
        end

        has_many :tags
      end

    end

    it "should delegate has_many calls to its source object" do
      drop = BaseDropWithHasMany.new
      drop.tags.should == ["tag1", "tag2"]
    end

    it "should delegate has_many calls to its source object" do
      drop = BaseDropWithHasMany.new
      drop.tag_ids.should == [1, 2]
    end
  end
end


