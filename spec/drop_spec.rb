require File.dirname(__FILE__) + '/spec_helper'

class ChildModel
  def parent
    "parent"
  end

  def parent_id
    15
  end

  def tags
    ["tag1", "tag2"]
  end

  def tag_ids
    [1, 2]
  end
end

describe "A Drop" do
  context "which has associations" do
    context "when belongs to an item" do
      before(:all) do
        class BaseDropWithBelongsTo
          extend Clot::DropAssociation

          def initialize
            @source = ChildModel.new
          end

          belongs_to :parent
        end
      end

      it "should delegate object calls to its source object" do
        drop = BaseDropWithBelongsTo.new
        drop.parent.should == "parent"
      end

      it "should delegate id calls to its source object" do
        drop = BaseDropWithBelongsTo.new
        drop.parent_id.should == 15
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

      it "should delegate object calls to its source object" do
        drop = BaseDropWithHasMany.new
        drop.tags.should == ["tag1", "tag2"]
      end

      it "should delegate id calls to its source object" do
        drop = BaseDropWithHasMany.new
        drop.tag_ids.should == [1, 2]
      end
    end
  end
end


