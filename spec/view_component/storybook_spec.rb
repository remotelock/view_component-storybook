# frozen_string_literal: true

RSpec.describe ViewComponent::Storybook do
  it "has a version number" do
    expect(ViewComponent::Storybook::VERSION).to eq("2.0.0")
  end

  describe "configuration" do
    around do |example|
      original = described_class.stories_json_path
      example.run
    ensure
      described_class.stories_json_path = original
    end

    it "applies the app's options" do
      described_class::Engine.apply(stories_json_path: "/tmp/stories")

      expect(described_class.stories_json_path).to eq("/tmp/stories")
    end

    it "warns about the options 2.0 removed and ignores them" do
      allow(described_class.deprecator).to receive(:warn)

      described_class::Engine.apply(show_stories: true, stories_route: "/stories")

      expect(described_class.deprecator).to have_received(:warn).with(/show_stories is ignored/)
      expect(described_class.deprecator).to have_received(:warn).with(/stories_route is ignored/)
    end

    it "defaults the static HTML directory under tmp" do
      expect(described_class.static_html_path).to eq(Rails.root.join("tmp/storybook/html").to_s)
    end
  end

  it "adds test/components/stories to ViewComponent's preview paths" do
    expect(ViewComponent::Base.config.previews.paths).to include(Rails.root.join("test/components/stories").to_s)
  end
end
