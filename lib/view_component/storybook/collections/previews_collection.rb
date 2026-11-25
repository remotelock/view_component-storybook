# frozen_string_literal: true

module ViewComponent
  module Storybook
    module Collections
      # Every preview class ViewComponent knows, each with its YARD code object for the tags, the
      # declaration order of its examples and their keyword defaults.
      class PreviewsCollection
        include Enumerable

        def self.load
          classes = preview_classes
          new(classes, code_objects(classes))
        end

        def self.load_stories_files
          Storybook.stories_paths.each do |path|
            Dir["#{path}/**/*_stories.rb"].each { |file| require file }
          end
        end

        def self.preview_classes
          ViewComponent::Preview.all.select { |klass| preview_class?(klass) }.uniq
        end

        def self.preview_class?(klass)
          # By name: comparing with the constant would load the deprecated base, and
          # every other list of previews (ViewComponent's, Lookbook's) would show it.
          return false if klass.name.nil? || klass.name == "ViewComponent::Storybook::Stories"
          return false if klass.respond_to?(:abstract_class) && klass.abstract_class

          true
        end

        def self.code_objects(classes)
          files = classes.filter_map { |klass| Object.const_source_location(klass.name)&.first }.uniq
          # Parsed into YARD's shared registry without clearing it, so another YARD user in the process
          # (Lookbook) keeps its objects. Stories come from the live examples, so stale entries don't show.
          YARD.parse(files, [], Logger::ERROR)
          classes.index_with { |klass| YARD::Registry.at(klass.name) }
        end

        def initialize(classes, code_objects)
          @previews = classes.map { |klass| PreviewStories.new(klass, code_objects[klass]) }
        end

        def each(&)
          @previews.each(&)
        end

        def find(preview_class)
          @previews.find { |preview| preview.preview_class.name == preview_class.name }
        end

        def find_story(preview_class, example)
          find(preview_class)&.find_story(example)
        end
      end
    end
  end
end
