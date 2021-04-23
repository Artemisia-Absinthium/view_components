# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "yard"
require "yard/renders_one_handler"
require "yard/renders_many_handler"
require "yaml"
require "pathname"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList.new(ENV["TESTS"] || "test/**/*_test.rb")
end

Rake::TestTask.new(:bench) do |t|
  t.libs << "test"
  t.test_files = FileList["test/benchmarks/**/bench_*.rb"]
  t.verbose = true
end

YARD::Rake::YardocTask.new

# Custom tags for yard
YARD::Tags::Library.define_tag("Accessibility", :accessibility)

namespace :coverage do
  task :report do
    require "simplecov"
    require "simplecov-console"

    SimpleCov.minimum_coverage 100

    SimpleCov.collate Dir["simplecov-resultset-*/.resultset.json"], "rails" do
      formatter SimpleCov::Formatter::Console
    end
  end
end

namespace :statuses do
  task :dump do
    require File.expand_path("demo/config/environment.rb", __dir__)
    require "primer/view_components"
    # Loads all components for `.descendants` to work properly
    Dir["./app/components/primer/**/*.rb"].sort.each { |file| require file }

    Primer::ViewComponents.dump_statuses
  end
end

namespace :docs do
  task :livereload do
    require "listen"

    Rake::Task["docs:build"].execute

    puts "Listening for changes to documentation..."

    listener = Listen.to("app") do |modified, added, removed|
      puts "modified absolute path: #{modified}"
      puts "added absolute path: #{added}"
      puts "removed absolute path: #{removed}"

      Rake::Task["docs:build"].execute
    end
    listener.start # not blocking
    sleep
  end

  def one_of(enumerable, lower: false)
    values =
      case enumerable
      when Hash
        enumerable.map do |key, value|
          "#{pretty_value(key)} (#{pretty_value(value)})"
        end
      else
        enumerable.map do |key|
          pretty_value(key)
        end
      end

    prefix = "One of"
    prefix = prefix.downcase if lower

    "#{prefix} #{values.to_sentence(last_word_connector: ', or ')}."
  end

  def link_to_system_arguments_docs
    "[System arguments](/system-arguments)"
  end

  def link_to_component(component)
    short_name = component.name.gsub(/Primer|::|Component/, "")
    "[#{short_name}](/components/#{short_name.downcase})"
  end

  def pretty_value(val)
    case val
    when nil
      "`nil`"
    when Symbol
      "`:#{val}`"
    else
      "`#{val}`"
    end
  end

  task :build do
    require File.expand_path("demo/config/environment.rb", __dir__)
    require "primer/view_components"
    require "view_component/test_helpers"
    include ViewComponent::TestHelpers

    Dir["./app/components/primer/**/*.rb"].sort.each { |file| require file }

    puts "Building YARD documentation."
    Rake::Task["yard"].execute

    puts "Converting YARD documentation to Markdown files."

    # Rails controller for rendering arbitrary ERB
    view_context = ApplicationController.new.tap { |c| c.request = ActionDispatch::TestRequest.create }.view_context

    registry = YARD::RegistryStore.new
    registry.load!(".yardoc")
    components = [
      Primer::LinkButton,
      Primer::AutoComplete,
      Primer::AutoComplete::Item,
      Primer::AvatarComponent,
      Primer::AvatarStackComponent,
      Primer::BaseButton,
      Primer::BlankslateComponent,
      Primer::BorderBoxComponent,
      Primer::BoxComponent,
      Primer::BreadcrumbComponent,
      Primer::ButtonComponent,
      Primer::ButtonGroupComponent,
      Primer::ButtonMarketingComponent,
      Primer::ClipboardCopy,
      Primer::CloseButton,
      Primer::CounterComponent,
      Primer::DetailsComponent,
      Primer::DropdownComponent,
      Primer::DropdownMenuComponent,
      Primer::FlashComponent,
      Primer::FlexComponent,
      Primer::FlexItemComponent,
      Primer::HeadingComponent,
      Primer::HiddenTextExpander,
      Primer::LabelComponent,
      Primer::LayoutComponent,
      Primer::LinkComponent,
      Primer::MarkdownComponent,
      Primer::MenuComponent,
      Primer::Navigation::TabComponent,
      Primer::OcticonComponent,
      Primer::PopoverComponent,
      Primer::ProgressBarComponent,
      Primer::StateComponent,
      Primer::SpinnerComponent,
      Primer::SubheadComponent,
      Primer::TabContainerComponent,
      Primer::TabNavComponent,
      Primer::TextComponent,
      Primer::TimeAgoComponent,
      Primer::TimelineItemComponent,
      Primer::TooltipComponent,
      Primer::Truncate,
      Primer::UnderlineNavComponent
    ]

    js_components = [
      Primer::AutoComplete,
      Primer::TimeAgoComponent,
      Primer::TabContainerComponent,
      Primer::TabNavComponent,
      Primer::UnderlineNavComponent
    ]

    all_components = Primer::Component.descendants - [Primer::BaseComponent]
    components_needing_docs = all_components - components

    components_without_examples = []
    args_for_components = []

    components.each do |component|
      documentation = registry.get(component.name)

      # Primer::AvatarComponent => Avatar
      short_name = component.name.gsub(/Primer|::|Component/, "")

      path = Pathname.new("docs/content/components/#{short_name.downcase}.md")
      path.dirname.mkdir unless path.dirname.exist?
      File.open(path, "w") do |f|
        f.puts("---")
        f.puts("title: #{short_name}")
        f.puts("status: #{component.status.to_s.capitalize}")
        f.puts("source: https://github.com/primer/view_components/tree/main/app/components/primer/#{component.to_s.demodulize.underscore}.rb")
        f.puts("storybook: https://primer.style/view-components/stories/?path=/story/primer-#{short_name.underscore.dasherize}-component")
        f.puts("---")
        f.puts
        f.puts("import Example from '../../src/@primer/gatsby-theme-doctocat/components/example'")

        if js_components.include?(component)
          f.puts("import RequiresJSFlash from '../../src/@primer/gatsby-theme-doctocat/components/requires-js-flash'")
          f.puts
          f.puts("<RequiresJSFlash />")
        end

        f.puts
        f.puts("<!-- Warning: AUTO-GENERATED file, do not edit. Add code comments to your Ruby instead <3 -->")
        f.puts
        f.puts(view_context.render(inline: documentation.base_docstring))
        f.puts

        if documentation.tags(:accessibility).any?
          f.puts("## Accessibility")
          f.puts
          documentation.tags(:accessibility).each do |tag|
            f.puts view_context.render(inline: tag.text)
            f.puts
          end
        end

        initialize_method = documentation.meths.find(&:constructor?)

        if initialize_method.tags(:example).any?
          f.puts("## Examples")
          f.puts
        else
          components_without_examples << component
        end

        initialize_method.tags(:example).each do |tag|
          (name, description) = tag.name.split("|")

          f.puts("### #{name}")
          if description
            f.puts
            f.puts(description)
          end
          f.puts
          html = view_context.render(inline: tag.text)

          f.puts("<Example src=\"#{html.tr('"', "\'").delete("\n")}\" />")
          f.puts
          f.puts("```erb")
          f.puts(tag.text.to_s)
          f.puts("```")
          f.puts
        end

        f.puts("## Arguments")
        f.puts
        f.puts("| Name | Type | Default | Description |")
        f.puts("| :- | :- | :- | :- |")

        args = []
        initialize_method.tags(:param).each do |tag|
          params = tag.object.parameters.find { |param| [tag.name.to_s, tag.name.to_s + ":"].include?(param[0]) }

          default =
            if params && params[1]
              constant_name = "#{component.name}::#{params[1]}"
              constant_value = constant_name.safe_constantize
              if constant_value.nil?
                pretty_value(params[1])
              else
                pretty_value(constant_value)
              end
            else
              "N/A"
            end

          args << {
            "name" => tag.name,
            "type" => tag.types.join(", "),
            "default" => default,
            "description" => view_context.render(inline: tag.text)
          }

          f.puts("| `#{tag.name}` | `#{tag.types.join(', ')}` | #{default} | #{view_context.render(inline: tag.text)} |")
        end

        component_args = {
          "component" => short_name,
          "source" => "https://github.com/primer/view_components/tree/main/app/components/primer/#{component.to_s.demodulize.underscore}.rb",
          "parameters" => args
        }

        args_for_components << component_args

        # Slots V2 docs
        slot_v2_methods = documentation.meths.select { |x| x[:renders_one] || x[:renders_many] }

        if slot_v2_methods.any?
          f.puts
          f.puts("## Slots")

          slot_v2_methods.each do |slot_documentation|
            f.puts
            f.puts("### `#{slot_documentation.name.to_s.capitalize}`")

            if slot_documentation.base_docstring.present?
              f.puts
              f.puts(view_context.render(inline: slot_documentation.base_docstring))
            end

            param_tags = slot_documentation.tags(:param)
            if param_tags.any?
              f.puts
              f.puts("| Name | Type | Default | Description |")
              f.puts("| :- | :- | :- | :- |")
            end

            param_tags.each do |tag|
              params = tag.object.parameters.find { |param| [tag.name.to_s, tag.name.to_s + ":"].include?(param[0]) }

              default =
                if params && params[1]
                  "`#{params[1]}`"
                else
                  "N/A"
                end

              f.puts("| `#{tag.name}` | `#{tag.types.join(', ')}` | #{default} | #{view_context.render(inline: tag.text)} |")
            end
          end
        end
      end
    end

    File.open("static/arguments.yml", "w") do |f|
      f.puts YAML.dump(args_for_components)
    end

    # Build system arguments docs from BaseComponent
    documentation = registry.get(Primer::BaseComponent.name)
    File.open("docs/content/system-arguments.md", "w") do |f|
      f.puts("---")
      f.puts("title: System arguments")
      f.puts("---")
      f.puts
      f.puts("<!-- Warning: AUTO-GENERATED file, do not edit. Add code comments to your Ruby instead <3 -->")
      f.puts
      f.puts(documentation.base_docstring)
      f.puts

      initialize_method = documentation.meths.find(&:constructor?)

      f.puts(view_context.render(inline: initialize_method.base_docstring))
    end

    puts "Markdown compiled."

    if components_without_examples.any?
      puts
      puts "The following components have no examples defined: #{components_without_examples.map(&:name).join(', ')}. Consider adding an example?"
    end

    if components_needing_docs.any?
      puts
      puts "The following components needs docs. Care to contribute them? #{components_needing_docs.map(&:name).join(', ')}"
    end
  end
end

task default: :test
