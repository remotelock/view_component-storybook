# frozen_string_literal: true

RSpec.describe ViewComponent::Storybook::Inference do
  def control(param, type = nil, default: nil)
    described_class.control(param, type: type, default: default)
  end

  describe ".component_class" do
    def component_for(preview_class)
      described_class.component_class(preview_class, ViewComponent::Storybook.previews.find(preview_class)&.code_object)
    end

    it "follows FooComponentPreview to FooComponent" do
      expect(component_for(PillComponentPreview)).to eq(PillComponent)
    end

    it "follows Foo::Preview to Foo::Component" do
      expect(component_for(TagChip::Preview)).to eq(TagChip::Component)
    end

    it "follows FooComponentStories to FooComponent" do
      expect(component_for(Demo::ButtonComponentStories)).to eq(Demo::ButtonComponent)
    end

    it "takes the @component tag first" do
      expect(component_for(BadgePreview)).to eq(PillComponent)
    end

    it "is nil when nothing matches" do
      expect(component_for(LayoutStories)).to be_nil
    end
  end

  describe ".control" do
    it "makes an enum a select of its values" do
      result = control(:tone, Types::Symbol.enum(:neutral, :success), default: :neutral)

      expect(result).to have_attributes(class: ViewComponent::Storybook::Controls::Options, type: :select,
                                        options: %i[neutral success])
      expect(result.parse_param_value("success")).to eq(:success)
    end

    it "sees an enum through optional and default" do
      result = control(:size, Types::String.enum("sm", "md").optional.default(nil))

      expect(result).to have_attributes(type: :select, options: %w[sm md])
      expect(result.parse_param_value("md")).to eq("md")
    end

    it "makes Bool a boolean" do
      expect(control(:on, Types::Bool).parse_param_value("true")).to be(true)
      expect(control(:on, Types::Params::Bool)).to be_a(ViewComponent::Storybook::Controls::Boolean)
    end

    it "makes Integer and Float numbers" do
      expect(control(:count, Types::Coercible::Integer)).to have_attributes(type: :number)
      expect(control(:ratio, Types::Float.constrained(gt: 0)).parse_param_value("0.5")).to eq(0.5)
    end

    it "makes String text and Symbol text that comes back a Symbol" do
      expect(control(:label, Types::String).parse_param_value("Hi")).to eq("Hi")
      expect(control(:key, Types::Symbol).parse_param_value("hi")).to eq(:hi)
    end

    it "makes Date a date that comes back a Date" do
      result = control(:on, Types::Date.optional)

      expect(result).to be_a(ViewComponent::Storybook::Controls::Date)
      expect(result.parse_param_value("2026-03-04T00:00:00.000Z")).to eq(Date.new(2026, 3, 4)).and be_a(Date)
    end

    it "makes Hash and Array objects" do
      expect(control(:data, Types::Hash).parse_param_value('{"id":1}')).to eq(id: 1)
      expect(control(:list, Types::Array.of(Types::String))).to be_a(ViewComponent::Storybook::Controls::Object)
    end

    it "falls back to the default's class when the type says nothing" do
      expect(control(:anything, Types::Any, default: true)).to be_a(ViewComponent::Storybook::Controls::Boolean)
      expect(control(:untyped, default: 3)).to be_a(ViewComponent::Storybook::Controls::Number)
      expect(control(:untyped, default: :solid).parse_param_value("outlined")).to eq(:outlined)
    end

    it "has no control for a default it can't send to Storybook" do
      expect(control(:author, default: Author.new(first_name: "A", last_name: "B"))).to be_nil
    end
  end

  describe "a story's controls" do
    let(:story) { ViewComponent::Storybook.previews.find_story(PillComponentPreview, :default) }

    it "infers one per keyword, in signature order, with the option's description" do
      expect(story.controls.map { |c| [c.param, c.class.name.demodulize] })
        .to eq([[:label, "Text"], [:tone, "Options"], [:count, "Number"], [:dismissible, "Boolean"]])
      expect(story.controls.first.description).to eq("The pill's words")
    end

    it "lets the DSL override inference" do
      story = ViewComponent::Storybook.previews.find_story(KwargsComponentStories, :custom_param)

      expect(story.controls.map(&:param)).to eq(%i[my_message param])
    end
  end
end
