# frozen_string_literal: true

require "rake"

RSpec.describe "view_component_storybook rake tasks" do
  let(:dir) { Dir.mktmpdir }

  def run(name, *args)
    Rails.application.load_tasks unless Rake::Task.task_defined?("view_component_storybook:#{name}")
    task = Rake::Task["view_component_storybook:#{name}"]
    task.reenable
    expect { task.invoke(*args) }.to output.to_stdout
  end

  around do |example|
    original = ViewComponent::Storybook.stories_json_path
    ViewComponent::Storybook.stories_json_path = File.join(dir, "stories")
    example.run
  ensure
    ViewComponent::Storybook.stories_json_path = original
    FileUtils.rm_rf(dir)
  end

  it "writes and removes the stories JSON" do
    run(:write_stories_json)
    expect(Dir["#{dir}/stories/**/*.stories.json"]).to include("#{dir}/stories/pill_component.stories.json",
                                                               "#{dir}/stories/demo/button_component.stories.json")

    run(:remove_stories_json)
    expect(Dir["#{dir}/stories/**/*.stories.json"]).to be_empty
  end

  it "writes the static HTML into the directory it's given" do
    run(:write_static_html, File.join(dir, "html"))

    expect(File).to exist(File.join(dir, "html/tag_chip/outlined.html"))
  end
end
