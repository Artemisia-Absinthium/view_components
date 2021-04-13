# frozen_string_literal: true

require "test_helper"

class PrimerButtonBaseTest < Minitest::Test
  include Primer::ComponentTestHelpers

  def test_renders_content
    render_inline(Primer::Button::Base.new) { "content" }

    assert_text("content")
  end

  def test_renders_a_as_a_button
    render_inline(Primer::Button::Base.new(tag: :a)) { "content" }

    assert_selector("a[role='button']")
    refute_selector("a[type]")
  end

  def test_renders_summary_as_a_button
    render_inline(Primer::Button::Base.new(tag: :summary)) { "content" }

    assert_selector("summary[role='button']")
    refute_selector("summary[type]")
  end

  def test_renders_href
    render_inline(Primer::Button::Base.new(href: "www.example.com")) { "content" }

    assert_selector("button[href='www.example.com']")
  end

  def test_renders_button_block
    render_inline(Primer::Button::Base.new(block: true)) { "content" }

    assert_selector(".btn-block")
  end
end
