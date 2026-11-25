# frozen_string_literal: true

RSpec.describe ViewComponent::Storybook::Stories do
  # Docs source is covered in preview_stories_spec; these compare the DSL's controls and parameters.
  def without_docs(csf_params)
    csf_params.merge(stories: csf_params[:stories].map { |story| story.deep_dup.tap { |s| s[:parameters].delete(:docs) } })
  end

  describe ".to_csf_params" do
    it "converts" do
      expect(without_docs(ContentComponentStories.to_csf_params)).to eq(
        title: "Content Component",
        stories: [
          {
            name: "With String Content",
            parameters: {
              server: { id: "content_component/with_string_content" }
            }
          },
          {
            name: "With Control Content",
            parameters: {
              server: { id: "content_component/with_control_content" }
            },
            args: {
              content: "Hello World!"
            },
            argTypes: {
              content: { control: { type: :text }, name: "Content" }
            }
          },
          {
            name: "With Described Control",
            parameters: {
              server: { id: "content_component/with_described_control" }
            },
            args: {
              content: "Hello World!"
            },
            argTypes: {
              content: { control: { type: :text }, description: "My first computer program.", name: "Content" }
            }
          },

          {
            name: "With Helper Content",
            parameters: {
              server: { id: "content_component/with_helper_content" }
            }
          }
        ]
      )
    end

    it "converts kwargs" do
      expect(without_docs(KwargsComponentStories.to_csf_params)).to eq(
        title: "Kwargs Component",
        stories: [
          {
            name: "Default",
            parameters: {
              server: { id: "kwargs_component/default" }
            },
            args: {
              message: "Hello World!",
              param: 1,
              other_param: true
            },
            argTypes: {
              message: { control: { type: :text }, name: "Message" },
              param: { control: { type: :number }, name: "Param" },
              other_param: { control: { type: :boolean }, name: "Other Param" }
            }
          },
          {
            name: "Fixed Args",
            parameters: {
              server: { id: "kwargs_component/fixed_args" }
            },
            args: {
              message: "Hello World!"
            },
            argTypes: {
              message: { control: { type: :text }, name: "Message" }
            }
          },
          {
            name: "Custom Param",
            parameters: {
              server: { id: "kwargs_component/custom_param" }
            },
            args: {
              my_message: "Hello World!",
              param: 1
            },
            argTypes: {
              my_message: { control: { type: :text }, name: "My Message" },
              param: { control: { type: :number }, name: "Param" }
            }
          }
        ]
      )
    end

    it "converts args" do
      expect(without_docs(ArgsComponentStories.to_csf_params)).to eq(
        title: "Args Component",
        stories: [
          {
            name: "Default",
            parameters: {
              server: { id: "args_component/default" }
            },
            args: {
              items0: "Hello World!",
              items1: "How you doing?"
            },
            argTypes: {
              items0: { control: { type: :text }, name: "Items0" },
              items1: { control: { type: :text }, name: "Items1" }
            }
          },
          {
            name: "Fixed Args",
            parameters: {
              server: { id: "args_component/fixed_args" }
            },
            args: {
              items0: "Hello World!"
            },
            argTypes: {
              items0: { control: { type: :text }, name: "Items0" }
            }
          },
          {
            name: "Custom Param",
            parameters: {
              server: { id: "args_component/custom_param" }
            },
            args: {
              message: "Hello World!",
              items1: "How you doing?"
            },
            argTypes: {
              message: { control: { type: :text }, name: "Message" },
              items1: { control: { type: :text }, name: "Items1" }
            }
          }
        ]
      )
    end

    it "converts mixed args" do
      expect(without_docs(MixedArgsComponentStories.to_csf_params)).to eq(
        title: "Mixed Args Component",
        stories: [
          {
            name: "Default",
            parameters: {
              server: { id: "mixed_args_component/default" }
            },
            args: {
              title: "Hello World!",
              message: "How you doing?"
            },
            argTypes: {
              title: { control: { type: :text }, name: "Title" },
              message: { control: { type: :text }, name: "Message" }
            }
          },
          {
            name: "Fixed Args",
            parameters: {
              server: { id: "mixed_args_component/fixed_args" }
            }
          }
        ]
      )
    end

    it "converts controls with default" do
      expect(without_docs(ControlDefaultStories.to_csf_params)).to eq(
        title: "Control Default",
        stories: [
          {
            name: "Example",
            parameters: {
              server: { id: "control_default/example" }
            },
            args: {
              content: "Hello World!"
            },
            argTypes: {
              content: { control: { type: :text }, name: "Content" }
            }
          }
        ]
      )
    end

    it "converts kitchen sink" do
      expect(without_docs(KitchenSinkComponentStories.to_csf_params)).to eq(
        title: "Kitchen Sink Component",
        stories: [
          {
            name: "Jane Doe",
            parameters: {
              server: { id: "kitchen_sink_component/jane_doe" }
            },
            args: {
              name: "Jane Doe",
              birthday: Time.utc(1950, 3, 26).iso8601,
              favorite_color: "red",
              like_people: true,
              number_pets: 2,
              sports: %w[football baseball],
              favorite_food: "Ice Cream",
              mood: :happy,
              other_things: { eyes: "Blue", hair: "Brown" }

            },
            argTypes: {
              name: { control: { type: :text }, name: "Name" },
              birthday: { control: { type: :date }, name: "Birthday" },
              favorite_color: { control: { type: :color }, name: "Favorite Color" },
              like_people: { control: { type: :boolean }, name: "Like People" },
              number_pets: { control: { type: :number }, name: "Number Pets" },
              sports: { control: { type: :object }, name: "Sports" },
              favorite_food: {
                control: {
                  type: :select
                },
                name: "Favorite Food",
                options: ["Burgers", "Hot Dog", "Ice Cream", "Pizza"]
              },
              mood: {
                control: {
                  type: :radio,
                  labels: { happy: "Happy", sad: "Sad", angry: "Angry", content: "Content" }
                },
                name: "Mood",
                options: %i[happy sad angry content]
              },
              other_things: { control: { type: :object }, name: "Other Things" }
            }
          }
        ]
      )
    end

    it "converts Stories with namespaces" do
      expect(without_docs(Demo::ButtonComponentStories.to_csf_params)).to eq(
        title: "Demo/Button Component",
        stories: [
          {
            name: "Short Button",
            parameters: {
              server: { id: "demo/button_component/short_button" }
            },
            args: {
              button_text: "OK"
            },
            argTypes: {
              button_text: { control: { type: :text }, name: "Button Text" }
            }
          },
          {
            name: "Medium Button",
            parameters: {
              server: { id: "demo/button_component/medium_button" }
            },
            args: {
              button_text: "Push Me!"
            },
            argTypes: {
              button_text: { control: { type: :text }, name: "Button Text" }
            }
          },
          {
            name: "Long Button",
            parameters: {
              server: { id: "demo/button_component/long_button" }
            },
            args: {
              button_text: "Really Really Long Button Text"
            },
            argTypes: {
              button_text: { control: { type: :text }, name: "Button Text" }
            }
          }
        ]
      )
    end

    context "with a custom story title defined" do
      it "converts Stories" do
        expect(without_docs(Demo::HeadingComponentStories.to_csf_params)).to eq(
          title: "Heading Component",
          stories: [
            {
              name: "Default",
              parameters: {
                server: { id: "demo/heading_component/default" }
              },
              args: {
                heading_text: "Heading"
              },
              argTypes: {
                heading_text: { control: { type: :text }, name: "Heading Text" }
              }
            }
          ]
        )
      end
    end

    context "with a custom story title generator defined" do
      let(:custom_story_title) { "CustomStoryTitle" }
      let(:component_class) do
        Class.new(described_class) do
          class << self
            def name
              "Demo::MoreButtonComponentStories"
            end
          end
        end
      end

      around do |example|
        original_generator = ViewComponent::Storybook.stories_title_generator
        ViewComponent::Storybook.stories_title_generator = ->(_stories) { custom_story_title }
        example.run
        ViewComponent::Storybook.stories_title_generator = original_generator
      end

      before do
        # stories_title_generator is triggered when a class is declared.
        # To test this behavior we have to create a new class dynamically onew we've
        # configured the stories_title_generator in the around block above

        stub_const("Demo::MoreButtonComponentStories", component_class)
      end

      it "converts Stories" do
        expect(without_docs(Demo::MoreButtonComponentStories.to_csf_params)).to eq(
          title: custom_story_title,
          stories: []
        )
      end

      it "allows compoents to override the title" do
        expect(Demo::HeadingComponentStories.to_csf_params[:title]).to eq("Heading Component")
      end
    end

    it "converts Stories with parameters" do
      expect(without_docs(ParametersStories.to_csf_params)).to eq(
        title: "Parameters",
        parameters: { size: :small },
        stories: [
          {
            name: "Stories Parameters",
            parameters: {
              server: { id: "parameters/stories_parameters" }
            },
            args: {
              button_text: "OK"
            },
            argTypes: {
              button_text: { control: { type: :text }, name: "Button Text" }
            }
          },
          {
            name: "Stories Parameter Override",
            parameters: {
              server: { id: "parameters/stories_parameter_override" },
              size: :large,
              color: :red
            },
            args: {
              button_text: "OK"
            },
            argTypes: {
              button_text: { control: { type: :text }, name: "Button Text" }
            }
          },
          {
            name: "Additional Parameters",
            parameters: {
              server: { id: "parameters/additional_parameters" },
              color: :red
            },
            args: {
              button_text: "OK"
            },
            argTypes: {
              button_text: { control: { type: :text }, name: "Button Text" }
            }
          }
        ]
      )
    end

    it "converts Stories with combined controls" do
      expect(without_docs(CombinedControlStories.to_csf_params)).to eq(
        title: "Combined Control",
        stories: [
          {
            name: "Combined Text",
            parameters: {
              server: { id: "combined_control/combined_text" }
            },
            args: {
              greeting: "Hi",
              name: "Sarah"
            },
            argTypes: {
              greeting: { control: { type: :text }, name: "Greeting" },
              name: { control: { type: :text }, name: "Name" }
            }
          },
          {
            name: "Combined Rest Args",
            parameters: {
              server: { id: "combined_control/combined_rest_args" }
            },
            args: {
              verb_one: "Big",
              noun_one: "Car",
              verb_two: "Small",
              noun_two: "Boat"
            },
            argTypes: {
              verb_one: { control: { type: :text }, name: "Verb One" },
              noun_one: { control: { type: :text }, name: "Noun One" },
              verb_two: { control: { type: :text }, name: "Verb Two" },
              noun_two: { control: { type: :text }, name: "Noun Two" }
            }
          },
          {
            name: "Described Control",
            args: {
              button_text: "DO NOT PUSH!"
            },
            argTypes: {
              button_text: { control: { type: :text }, description: "Make this irresistible.", name: "Button Text" }
            },
            parameters: {
              server: { id: "combined_control/described_control" }
            }
          }
        ]
      )
    end

    it "converts Stories with slots" do
      expect(without_docs(SlotsStories.to_csf_params)).to eq(
        title: "Slots",
        stories: [
          {
            name: "Default",
            parameters: {
              server: { id: "slots/default" }
            },
            args: {
              classes: "mt-4",
              title: "This is my title!",
              subtitle: "This is my subtitle!",
              tab2: "Tab B",
              item2_highlighted: true,
              item3: "Item C",
              footer_classes: "text-blue"
            },
            argTypes: {
              classes: { control: { type: :text }, name: "Classes" },
              title: { control: { type: :text }, name: "Title" },
              subtitle: { control: { type: :text }, name: "Subtitle" },
              tab2: { control: { type: :text }, name: "Tab2" },
              item2_highlighted: { control: { type: :boolean }, name: "Item2 Highlighted" },
              item3: { control: { type: :text }, name: "Item3" },
              footer_classes: { control: { type: :text }, name: "Footer Classes" }
            }
          }
        ]
      )
    end
  end

  describe ".write_csf_json" do
    subject { ContentComponentStories.write_csf_json }

    after do
      File.delete(subject)
    end

    it "writes file" do
      expect(subject).to eq(Rails.root.join("test/components/stories/content_component_stories.stories.json").to_s)
      expect(File.exist?(subject)).to be(true)
    end

    it "writes stories to json files" do
      json = JSON.parse(File.read(subject))
      expect(json).to eq(JSON.parse(ContentComponentStories.to_csf_params.to_json))
      expect(json["stories"].first).to include(
        "name" => "With String Content",
        "parameters" => include("server" => { "id" => "content_component/with_string_content" })
      )
    end
  end
end
