# frozen_string_literal: true

RSpec.describe "Coercing Storybook's args", type: :request do
  it "gives a plain preview the values its dry types expect" do
    get "/rails/view_components/pill_component/default", params: { tone: "danger", count: "3", dismissible: "true", label: "Go" }

    expect(response.body).to have_css("span.pill.pill--danger.pill--dismissible", text: "Go (3)")
  end

  it "parses dates and JSON objects" do
    get "/rails/view_components/pill_component/with_size",
        params: { size: "md", since: "2026-03-04T00:00:00.000Z", data: '{"id":7}' }

    expect(response.body).to have_css("span.pill--md[data-id='7']", text: "Small (0) since 2026-03-04")
  end

  it "works for a view_component-contrib sidecar preview" do
    get "/rails/view_components/tag_chip/default", params: { variant: "outlined", label: "Hi" }

    expect(response.body).to have_css("span.tag-chip--outlined", text: "Hi")
  end

  it "passes coerced args to a contrib example's template through render_with" do
    get "/rails/view_components/tag_chip/with_locals", params: { label: "Hello" }

    expect(response.body).to have_css("span.tag-chip--solid", text: "Hello")
  end

  it "renders an example's template" do
    get "/rails/view_components/tag_chip/outlined"

    expect(response.body).to have_css("span.tag-chip--outlined", text: "Outlined")
  end
end
