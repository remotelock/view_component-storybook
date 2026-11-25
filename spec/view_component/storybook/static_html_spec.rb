# frozen_string_literal: true

RSpec.describe ViewComponent::Storybook::StaticHtml, type: :request do
  let(:dir) { Dir.mktmpdir }

  after { FileUtils.rm_rf(dir) }

  it "writes every story's HTML exactly as the preview route returns it" do
    written = described_class.write(dir)
    stories = ViewComponent::Storybook.previews.flat_map(&:stories)

    expect(written.size).to eq(stories.size)

    get "/rails/view_components/pill_component/default"
    expect(File.read(File.join(dir, "pill_component/default.html"))).to eq(response.body)

    get "/rails/view_components/tag_chip/outlined"
    expect(File.read(File.join(dir, "tag_chip/outlined.html"))).to eq(response.body)
  end

  it "reports the stories it couldn't render" do
    allow(ViewComponent::Storybook.previews.find(BadgePreview).stories.first).to receive(:id).and_return("badge/missing")

    expect { described_class.write(dir) }.to raise_error(described_class::RenderError, %r{badge/missing})
  end
end
