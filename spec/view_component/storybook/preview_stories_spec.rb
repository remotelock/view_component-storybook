# frozen_string_literal: true

RSpec.describe ViewComponent::Storybook::PreviewStories do
  subject(:preview) { ViewComponent::Storybook.previews.find(preview_class) }

  let(:preview_class) { PillComponentPreview }
  let(:csf) { preview.to_csf_params }

  it "reads plain ViewComponent previews" do
    expect(ViewComponent::Storybook.previews.map(&:preview_class))
      .to include(PillComponentPreview, BadgePreview, TagChip::Preview, ContentComponentStories)
  end

  it "leaves out abstract previews" do
    expect(ViewComponent::Storybook.previews.map(&:preview_class)).not_to include(ViewComponentContrib::Preview::Base)
  end

  describe "#title" do
    it "comes from the @title tag" do
      expect(csf[:title]).to eq("Data/Pill")
    end

    context "without a tag" do
      let(:preview_class) { TagChip::Preview }

      it "comes from the generator" do
        expect(csf[:title]).to eq("Tag Chip")
      end
    end
  end

  describe "stories" do
    it "keeps the order the examples are declared in" do
      expect(csf[:stories].pluck(:name)).to eq(["Default", "Every tone", "With Size"])
    end

    it "uses the preview route's path as the server id" do
      expect(csf[:stories].map { |story| story.dig(:parameters, :server, :id) })
        .to eq(%w[pill_component/default pill_component/tones pill_component/with_size])
    end

    it "takes the args from the keyword defaults" do
      expect(csf[:stories].first[:args]).to eq(label: "New", tone: :neutral, count: 0, dismissible: false)
      expect(csf[:stories].last[:args])
        .to eq(label: "Small", size: "sm", since: "2026-01-02T00:00:00Z", data: { id: 1 })
    end

    it "has no args for an example without keywords" do
      expect(csf[:stories].second).not_to have_key(:args)
    end
  end

  describe "docs source" do
    def source(story) = story.dig(:parameters, :docs, :source)

    it "is the example's template when it has one" do
      expect(source(csf[:stories].second)).to eq(
        code: Rails.root.join("test/components/previews/pill_component_preview/tones.html.erb").read.strip,
        language: "erb"
      )
      expect(source(csf[:stories].second)[:code]).to start_with(%(<%= render PillComponent.new(label: "Neutral") %>))
    end

    it "is the method body otherwise" do
      expect(source(csf[:stories].first)).to eq(
        code: "render PillComponent.new(label: label, tone: tone, count: count, dismissible: dismissible)",
        language: "ruby"
      )
    end

    it "dedents a body over several lines" do
      stories = ViewComponent::Storybook.previews.find(KitchenSinkComponentStories).to_csf_params[:stories]
      code = source(stories.first)[:code]
      expect(code.lines.first(2)).to eq(["render KitchenSinkComponent.new(\n", "  name: name,\n"])
      expect(code.lines.last).to eq(")")
    end

    context "with a view_component-contrib sidecar preview" do
      let(:preview_class) { TagChip::Preview }

      it "finds the example's template under previews/" do
        expect(source(csf[:stories].second)).to eq(
          code: %(<%= render TagChip::Component.new(variant: :outlined, label: "Outlined") %>),
          language: "erb"
        )
      end

      it "lists its examples, render_with and empty ones included" do
        expect(csf[:stories].pluck(:name)).to eq(["Default", "Outlined", "With Locals"])
        expect(csf[:stories].last[:args]).to eq(label: "From locals")
        expect(source(csf[:stories].last)[:language]).to eq("erb")
      end

      it "uses the method body when only the shared template applies" do
        expect(source(csf[:stories].first)).to eq(code: "render_component(variant: variant, label: label)", language: "ruby")
      end
    end
  end

  describe "#json_path" do
    it "is next to the preview by default" do
      expect(preview.json_path).to eq(Rails.root.join("test/components/previews/pill_component_preview.stories.json").to_s)
    end

    context "with stories_json_path set" do
      around do |example|
        original = ViewComponent::Storybook.stories_json_path
        ViewComponent::Storybook.stories_json_path = Rails.root.join("tmp/stories")
        example.run
      ensure
        ViewComponent::Storybook.stories_json_path = original
      end

      it "nests the file by preview name" do
        expect(ViewComponent::Storybook.previews.find(Demo::ButtonComponentStories).json_path)
          .to eq(Rails.root.join("tmp/stories/demo/button_component.stories.json").to_s)
      end
    end
  end

  describe "#write_csf_json" do
    around do |example|
      original = ViewComponent::Storybook.stories_json_path
      Dir.mktmpdir do |dir|
        ViewComponent::Storybook.stories_json_path = dir
        example.run
      end
    ensure
      ViewComponent::Storybook.stories_json_path = original
    end

    it "writes the CSF JSON" do
      path = preview.write_csf_json

      expect(path).to end_with("/pill_component.stories.json")
      expect(JSON.parse(File.read(path))).to eq(JSON.parse(csf.to_json))
    end
  end
end
