# frozen_string_literal: true

namespace :view_component_storybook do
  desc "Write a CSF *.stories.json for every ViewComponent preview"
  task write_stories_json: :environment do
    puts "Writing Stories JSON"
    exceptions = []
    ViewComponent::Storybook.previews.each do |preview|
      puts "#{preview.preview_class.name} => #{preview.write_csf_json}"
    rescue StandardError => e
      exceptions << "#{preview.preview_class.name}: #{e.message}"
    end

    raise StandardError, exceptions.join(", ") if exceptions.present?

    puts "Done"
  end

  desc "Remove the *.stories.json files write_stories_json wrote"
  task remove_stories_json: :environment do
    puts "Removing Stories JSON"
    ViewComponent::Storybook.previews.each do |preview|
      next unless File.exist?(preview.json_path)

      puts preview.json_path
      File.unlink(preview.json_path)
    end

    puts "Done"
  end

  desc "Render every story at its default args to <dir>/<story id>.html, for a static Storybook"
  task :write_static_html, [:dir] => :environment do |_task, args|
    dir = args[:dir].presence || ViewComponent::Storybook.static_html_path
    files = ViewComponent::Storybook::StaticHtml.write(dir)
    puts "Wrote #{files.size} stories to #{dir}"
  end
end
